import "server-only";
import { createDataClient } from "@/lib/supabase/data-client";
import { DAY_FIELDS, type DayField } from "@/lib/weeks";

export interface TeamMember {
  id: number;
  name: string | null;
  email: string | null;
  level: number | null;
  hourly_rate: number | null;
}

export interface DeliverableRow {
  deliverableId: number;
  deliverableName: string | null;
  projectId: number | null;
  projectName: string | null;
  notes: string | null;
  budgetRemaining: number | null;
  entries: Partial<Record<DayField, number | null>>;
}

export interface ProjectGroup {
  projectId: number | null;
  projectName: string;
  budgetRemaining: number | null;
  deliverables: DeliverableRow[];
}

// The `effort` table's day columns are quoted identifiers starting with a
// digit (e.g. "1_monday"), which trips up supabase-js's template-literal
// select-string type inference. We sidestep that by declaring the exact
// row shape ourselves and passing it via `.returns<...>()`.
type EffortDayValues = Record<DayField, number | null>;

interface WeekTotalsRow extends EffortDayValues {
  week_start_date: string;
}

interface WeekEffortRow extends EffortDayValues {
  id: number;
  deliverable_id: number;
  notes: string | null;
}

interface AllEffortRow extends EffortDayValues {
  deliverable_id: number;
  team_member_level: number | null;
}

export async function getTeamMemberByEmail(
  email: string
): Promise<TeamMember | null> {
  const supabase = createDataClient();
  const { data, error } = await supabase
    .from("team_members")
    .select("id, name, email, level, hourly_rate")
    .ilike("email", email)
    .maybeSingle();
  if (error) throw error;
  return data;
}

const DAY_FIELDS_SELECT: string = DAY_FIELDS.join(", ");

export async function getWeekTotals(
  teamMemberId: number,
  weekKeys: string[]
): Promise<Record<string, number>> {
  const supabase = createDataClient();
  const { data, error } = await supabase
    .from("effort")
    .select(`week_start_date, ${DAY_FIELDS_SELECT}`)
    .eq("team_member_id", teamMemberId)
    .in("week_start_date", weekKeys)
    .returns<WeekTotalsRow[]>();
  if (error) throw error;

  const totals: Record<string, number> = {};
  for (const row of data ?? []) {
    const key = row.week_start_date;
    const sum = DAY_FIELDS.reduce(
      (acc, day) => acc + (Number(row[day]) || 0),
      0
    );
    totals[key] = (totals[key] ?? 0) + sum;
  }
  return totals;
}

export async function getWeekGrid(
  teamMember: TeamMember,
  weekStartDate: string
): Promise<ProjectGroup[]> {
  const supabase = createDataClient();

  const { data: staffingRows, error: staffingErr } = await supabase
    .from("staffing")
    .select("deliverable")
    .eq("team_member", teamMember.id);
  if (staffingErr) throw staffingErr;

  const { data: weekEffortRows, error: effortErr } = await supabase
    .from("effort")
    .select(`id, deliverable_id, notes, ${DAY_FIELDS_SELECT}`)
    .eq("team_member_id", teamMember.id)
    .eq("week_start_date", weekStartDate)
    .returns<WeekEffortRow[]>();
  if (effortErr) throw effortErr;

  const deliverableIds = Array.from(
    new Set(
      [
        ...(staffingRows ?? []).map((r) => r.deliverable),
        ...(weekEffortRows ?? []).map((r) => r.deliverable_id),
      ].filter((v): v is number => v != null)
    )
  );

  if (deliverableIds.length === 0) return [];

  const { data: deliverables, error: delivErr } = await supabase
    .from("deliverables")
    .select(
      "id, name, project, planned_hours_level_0, planned_hours_level_1, planned_hours_level_2, planned_hours_level_3, planned_hours_level_4"
    )
    .in("id", deliverableIds);
  if (delivErr) throw delivErr;

  const projectIds = Array.from(
    new Set(
      (deliverables ?? [])
        .map((d) => d.project)
        .filter((v): v is number => v != null)
    )
  );
  const { data: projects, error: projErr } = await supabase
    .from("projects")
    .select("id, name")
    .in("id", projectIds.length ? projectIds : [-1]);
  if (projErr) throw projErr;
  const projectById = new Map((projects ?? []).map((p) => [p.id, p]));

  // All-time effort logged against these deliverables at this team member's
  // level, to compute "budget remaining" against the deliverable's planned
  // hours for that level. This is a simplification of the AppSheet formula
  // (confirm against the live budget view before relying on it).
  const levelHoursField = `planned_hours_level_${teamMember.level ?? 0}`;
  const { data: allEffort, error: allEffortErr } = await supabase
    .from("effort")
    .select(`deliverable_id, team_member_level, ${DAY_FIELDS_SELECT}`)
    .in("deliverable_id", deliverableIds)
    .eq("team_member_level", teamMember.level ?? 0)
    .returns<AllEffortRow[]>();
  if (allEffortErr) throw allEffortErr;

  const reportedByDeliverable = new Map<number, number>();
  for (const row of allEffort ?? []) {
    const id = row.deliverable_id;
    const sum = DAY_FIELDS.reduce(
      (acc, day) => acc + (Number(row[day]) || 0),
      0
    );
    reportedByDeliverable.set(id, (reportedByDeliverable.get(id) ?? 0) + sum);
  }

  const effortByDeliverable = new Map(
    (weekEffortRows ?? []).map((r) => [r.deliverable_id, r])
  );

  const groups = new Map<string, ProjectGroup>();

  for (const deliverable of deliverables ?? []) {
    const project = deliverable.project
      ? projectById.get(deliverable.project)
      : null;
    const groupKey = project ? String(project.id) : "unassigned";

    if (!groups.has(groupKey)) {
      groups.set(groupKey, {
        projectId: project?.id ?? null,
        projectName: project?.name ?? "No project",
        budgetRemaining: null,
        deliverables: [],
      });
    }

    const planned =
      (deliverable as Record<string, unknown>)[levelHoursField] != null
        ? Number((deliverable as Record<string, unknown>)[levelHoursField])
        : null;
    const reported = reportedByDeliverable.get(deliverable.id) ?? 0;
    const budgetRemaining = planned != null ? planned - reported : null;

    const weekRow = effortByDeliverable.get(deliverable.id);
    const entries: Partial<Record<DayField, number | null>> = {};
    for (const day of DAY_FIELDS) {
      entries[day] = weekRow?.[day] != null ? Number(weekRow[day]) : null;
    }

    groups.get(groupKey)!.deliverables.push({
      deliverableId: deliverable.id,
      deliverableName: deliverable.name,
      projectId: project?.id ?? null,
      projectName: project?.name ?? null,
      notes: weekRow?.notes ?? null,
      budgetRemaining,
      entries,
    });
  }

  return Array.from(groups.values()).sort((a, b) =>
    a.projectName.localeCompare(b.projectName)
  );
}
