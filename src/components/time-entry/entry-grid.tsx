"use client";

import { useState, useTransition } from "react";
import { saveEffortCell } from "@/app/actions/effort";
import { Input } from "@/components/ui/input";
import { DAY_FIELDS, DAY_LABELS, type DayField } from "@/lib/weeks";
import { cn } from "@/lib/utils";
import type { ProjectGroup } from "@/lib/data/time-entries";

type CellKey = `${number}:${DayField}`;

export function EntryGrid({
  groups,
  weekStartDate,
}: {
  groups: ProjectGroup[];
  weekStartDate: string;
}) {
  const [overrides, setOverrides] = useState<Record<CellKey, number | null>>(
    {}
  );
  const [savingKeys, setSavingKeys] = useState<Set<CellKey>>(new Set());
  const [errorKeys, setErrorKeys] = useState<Record<CellKey, string>>({});
  const [, startTransition] = useTransition();

  function cellValue(deliverableId: number, day: DayField, fallback: number | null) {
    const key: CellKey = `${deliverableId}:${day}`;
    return key in overrides ? overrides[key] : fallback;
  }

  function handleChange(deliverableId: number, day: DayField, raw: string) {
    const key: CellKey = `${deliverableId}:${day}`;
    const value = raw === "" ? null : Number(raw);
    setOverrides((prev) => ({ ...prev, [key]: value }));
  }

  function handleBlur(deliverableId: number, day: DayField) {
    const key: CellKey = `${deliverableId}:${day}`;
    if (!(key in overrides)) return;
    const hours = overrides[key];

    setSavingKeys((prev) => new Set(prev).add(key));
    setErrorKeys((prev) => {
      const next = { ...prev };
      delete next[key];
      return next;
    });

    startTransition(async () => {
      try {
        await saveEffortCell({ deliverableId, weekStartDate, day, hours });
      } catch (e) {
        setErrorKeys((prev) => ({
          ...prev,
          [key]: e instanceof Error ? e.message : "Failed to save",
        }));
      } finally {
        setSavingKeys((prev) => {
          const next = new Set(prev);
          next.delete(key);
          return next;
        });
      }
    });
  }

  if (groups.length === 0) {
    return (
      <p className="text-sm text-neutral-500">
        No deliverables are staffed for you yet. Once you&apos;re added to a
        project&apos;s staffing, it will show up here.
      </p>
    );
  }

  return (
    <div className="overflow-x-auto rounded-lg border border-neutral-200 bg-white">
      <table className="w-full min-w-[900px] border-collapse text-sm">
        <thead>
          <tr className="border-b border-neutral-200 text-left text-xs font-semibold uppercase tracking-wide text-neutral-400">
            <th className="w-64 px-4 py-2">Project / Deliverable</th>
            <th className="w-24 px-4 py-2 text-right">Budget Remaining</th>
            {DAY_FIELDS.map((day) => (
              <th key={day} className="w-20 px-2 py-2 text-center">
                {DAY_LABELS[day]}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {groups.map((group) => (
            <GroupRows
              key={group.projectId ?? group.projectName}
              group={group}
              cellValue={cellValue}
              onChange={handleChange}
              onBlur={handleBlur}
              savingKeys={savingKeys}
              errorKeys={errorKeys}
            />
          ))}
        </tbody>
      </table>
    </div>
  );
}

function GroupRows({
  group,
  cellValue,
  onChange,
  onBlur,
  savingKeys,
  errorKeys,
}: {
  group: ProjectGroup;
  cellValue: (deliverableId: number, day: DayField, fallback: number | null) => number | null;
  onChange: (deliverableId: number, day: DayField, raw: string) => void;
  onBlur: (deliverableId: number, day: DayField) => void;
  savingKeys: Set<CellKey>;
  errorKeys: Record<CellKey, string>;
}) {
  return (
    <>
      <tr className="bg-neutral-50">
        <td
          colSpan={9}
          className="px-4 py-2 text-sm font-semibold text-neutral-800"
        >
          {group.projectName}
        </td>
      </tr>
      {group.deliverables.map((deliverable) => (
        <tr key={deliverable.deliverableId} className="border-b border-neutral-100">
          <td className="px-4 py-2 text-neutral-700">
            {deliverable.deliverableName}
          </td>
          <td
            className={cn(
              "px-4 py-2 text-right tabular-nums",
              deliverable.budgetRemaining != null && deliverable.budgetRemaining < 0
                ? "text-red-600"
                : "text-emerald-600"
            )}
          >
            {deliverable.budgetRemaining != null
              ? deliverable.budgetRemaining.toFixed(2)
              : "—"}
          </td>
          {DAY_FIELDS.map((day) => {
            const key: CellKey = `${deliverable.deliverableId}:${day}`;
            const value = cellValue(
              deliverable.deliverableId,
              day,
              deliverable.entries[day] ?? null
            );
            return (
              <td key={day} className="px-1 py-1">
                <Input
                  type="number"
                  min={0}
                  max={24}
                  step={0.25}
                  value={value ?? ""}
                  onChange={(e) =>
                    onChange(deliverable.deliverableId, day, e.target.value)
                  }
                  onBlur={() => onBlur(deliverable.deliverableId, day)}
                  className={cn(
                    savingKeys.has(key) && "opacity-50",
                    errorKeys[key] && "border-red-500"
                  )}
                  title={errorKeys[key]}
                />
              </td>
            );
          })}
        </tr>
      ))}
    </>
  );
}
