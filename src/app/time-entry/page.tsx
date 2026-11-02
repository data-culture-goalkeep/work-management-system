import { redirect } from "next/navigation";
import { getCurrentUserEmail } from "@/lib/supabase/server-auth";
import {
  getTeamMemberByEmail,
  getWeekGrid,
  getWeekTotals,
} from "@/lib/data/time-entries";
import { generateWeekList, mondayOf, toDateKey } from "@/lib/weeks";
import { WeekSidebar } from "@/components/time-entry/week-sidebar";
import { EntryGrid } from "@/components/time-entry/entry-grid";

export default async function TimeEntryPage({
  searchParams,
}: {
  searchParams: Promise<{ week?: string }>;
}) {
  const email = await getCurrentUserEmail();
  if (!email) redirect("/login");

  const teamMember = await getTeamMemberByEmail(email);
  if (!teamMember) redirect("/not-authorized");

  const { week } = await searchParams;
  const selectedWeek = week ? mondayOf(new Date(week)) : mondayOf(new Date());
  const selectedWeekKey = toDateKey(selectedWeek);

  const weeks = generateWeekList(8, 2);
  const weekKeys = weeks.map(toDateKey);

  const [groups, totals] = await Promise.all([
    getWeekGrid(teamMember, selectedWeekKey),
    getWeekTotals(teamMember.id, weekKeys),
  ]);

  return (
    <div className="flex h-screen bg-neutral-50">
      <WeekSidebar
        weeks={weekKeys}
        selectedWeek={selectedWeekKey}
        totals={totals}
      />
      <div className="flex-1 overflow-auto">
        <header className="sticky top-0 z-10 flex items-center justify-between border-b border-neutral-200 bg-white px-6 py-3">
          <div>
            <h1 className="text-lg font-semibold text-neutral-900">
              My Time Entry
            </h1>
            <p className="text-sm text-neutral-500">
              {teamMember.name} · Week of{" "}
              {selectedWeek.toLocaleDateString("en-GB")}
            </p>
          </div>
          <form action="/auth/signout" method="post">
            <button
              type="submit"
              className="text-sm text-neutral-500 hover:text-neutral-900"
            >
              Sign out
            </button>
          </form>
        </header>
        <main className="p-6">
          <EntryGrid groups={groups} weekStartDate={selectedWeekKey} />
        </main>
      </div>
    </div>
  );
}
