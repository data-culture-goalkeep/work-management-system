"use server";

import { revalidatePath } from "next/cache";
import { getCurrentUserEmail } from "@/lib/supabase/server-auth";
import { getTeamMemberByEmail } from "@/lib/data/time-entries";
import { createDataClient } from "@/lib/supabase/data-client";
import { DAY_FIELDS, type DayField } from "@/lib/weeks";

export interface SaveEffortCellInput {
  deliverableId: number;
  weekStartDate: string;
  day: DayField;
  hours: number | null;
}

export async function saveEffortCell(input: SaveEffortCellInput) {
  if (!DAY_FIELDS.includes(input.day)) {
    throw new Error("Invalid day field");
  }
  if (
    input.hours != null &&
    (Number.isNaN(input.hours) || input.hours < 0 || input.hours > 24)
  ) {
    throw new Error("Hours must be between 0 and 24");
  }

  const email = await getCurrentUserEmail();
  if (!email) throw new Error("Not authenticated");

  const teamMember = await getTeamMemberByEmail(email);
  if (!teamMember) {
    throw new Error("No team member record is linked to this account");
  }

  const supabase = createDataClient();
  const { error } = await supabase.from("effort").upsert(
    {
      team_member_id: teamMember.id,
      deliverable_id: input.deliverableId,
      week_start_date: input.weekStartDate,
      [input.day]: input.hours,
      team_member_level: teamMember.level ?? 0,
      team_member_hourly_rate: teamMember.hourly_rate ?? 0,
    },
    { onConflict: "team_member_id,deliverable_id,week_start_date" }
  );
  if (error) throw error;

  revalidatePath("/time-entry");
}
