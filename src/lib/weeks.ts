import { addWeeks, format, startOfWeek } from "date-fns";

export const DAY_FIELDS = [
  "1_monday",
  "2_tuesday",
  "3_wednesday",
  "4_thursday",
  "5_friday",
  "6_saturday",
  "7_sunday",
] as const;

export type DayField = (typeof DAY_FIELDS)[number];

export const DAY_LABELS: Record<DayField, string> = {
  "1_monday": "MON",
  "2_tuesday": "TUE",
  "3_wednesday": "WED",
  "4_thursday": "THU",
  "5_friday": "FRI",
  "6_saturday": "SAT",
  "7_sunday": "SUN",
};

export function mondayOf(date: Date): Date {
  return startOfWeek(date, { weekStartsOn: 1 });
}

export function toDateKey(date: Date): string {
  return format(date, "yyyy-MM-dd");
}

/** Ascending list of Monday dates, `weeksBack` weeks before today through `weeksForward` weeks after. */
export function generateWeekList(
  weeksBack: number,
  weeksForward: number,
  today: Date = new Date()
): Date[] {
  const thisMonday = mondayOf(today);
  const weeks: Date[] = [];
  for (let i = -weeksBack; i <= weeksForward; i++) {
    weeks.push(addWeeks(thisMonday, i));
  }
  return weeks;
}
