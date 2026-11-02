"use client";

import Link from "next/link";
import { cn } from "@/lib/utils";

export function WeekSidebar({
  weeks,
  selectedWeek,
  totals,
}: {
  weeks: string[];
  selectedWeek: string;
  totals: Record<string, number>;
}) {
  return (
    <aside className="w-56 shrink-0 overflow-y-auto border-r border-neutral-200 bg-white">
      <div className="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-neutral-400">
        Week of
      </div>
      <nav className="flex flex-col">
        {weeks.map((week) => {
          const isSelected = week === selectedWeek;
          const total = totals[week] ?? 0;
          return (
            <Link
              key={week}
              href={`/time-entry?week=${week}`}
              className={cn(
                "flex items-center justify-between px-4 py-2 text-sm",
                isSelected
                  ? "bg-neutral-100 font-medium text-neutral-900"
                  : "text-neutral-600 hover:bg-neutral-50"
              )}
            >
              <span>
                {new Date(week).toLocaleDateString("en-GB", {
                  day: "2-digit",
                  month: "2-digit",
                  year: "numeric",
                })}
              </span>
              <span className="text-xs text-neutral-400">
                {total.toFixed(2)}
              </span>
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
