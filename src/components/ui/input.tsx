import * as React from "react";
import { cn } from "@/lib/utils";

export const Input = React.forwardRef<
  HTMLInputElement,
  React.InputHTMLAttributes<HTMLInputElement>
>(({ className, type, ...props }, ref) => {
  return (
    <input
      type={type}
      ref={ref}
      className={cn(
        "flex h-8 w-full rounded-md border border-neutral-300 bg-white px-2 py-1 text-sm text-right shadow-sm outline-none transition-colors focus:border-neutral-500 focus:ring-1 focus:ring-neutral-400 disabled:cursor-not-allowed disabled:bg-neutral-50 disabled:text-neutral-400",
        className
      )}
      {...props}
    />
  );
});
Input.displayName = "Input";
