## Goalkeep WorkManage — time-entry PoC

A proof-of-concept rebuild of the time-entry screen from the AppSheet
system, on Next.js + Supabase, aimed at eventually replacing the AppSheet
front-end entirely (CRM, leave management, OKR tracking to follow).

### Stack

- Next.js (App Router) + TypeScript + Tailwind
- Supabase (Postgres + Auth). Schema restored verbatim from the existing
  pg_dump — see `supabase/migrations/0001_initial_schema.sql`.
- Google Workspace SSO via Supabase Auth, restricted to `goalkeep.net`.
- Deployed on Vercel.

### Data access model (read this before adding new queries)

There is **no Row-Level Security** on these tables yet (by design — this
was deferred, not skipped by accident). Instead:

- All reads/writes of app data go through server-side code
  (`src/lib/data/*`, `src/app/actions/*`) using the Supabase
  **service-role key** (`src/lib/supabase/data-client.ts`, guarded by the
  `server-only` package so it can never be imported into a Client
  Component).
- The migration revokes the default `anon`/`authenticated` grants on all
  `public` tables, so even though the anon key ships to the browser (for
  the Google OAuth flow), it cannot be used to query these tables directly
  via the Supabase REST API.
- Every server action re-derives the current user's `team_member_id` from
  their authenticated session (`getCurrentUserEmail()` → `team_members`
  lookup) — it never trusts a `team_member_id` passed from the client.

If/when you add a view where one person needs to see another's data (e.g.
a project manager's rollup), do that as another server-side query scoped
by an explicit permission check — don't just relax the REST grants.

### Local setup

1. Copy `.env.example` to `.env.local` and fill in:
   - `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` — from
     Supabase project settings → API.
   - `SUPABASE_SERVICE_ROLE_KEY` — same page, "service_role" key. Keep
     this secret.
2. Run the migration in `supabase/migrations/0001_initial_schema.sql`
   against your Supabase project (Supabase Dashboard → SQL Editor, or
   `psql "$DATABASE_URL" -f supabase/migrations/0001_initial_schema.sql`).
3. In Supabase Dashboard → Authentication → Providers → Google, enable the
   provider and paste in your Google OAuth client ID/secret (configured in
   GCP, not in this repo).
4. `npm install && npm run dev`

### What's in the PoC

- `/login` — Google SSO sign-in, restricted to `goalkeep.net`.
- `/time-entry` — grouped by project → deliverable, Mon–Sun hour entry,
  per-deliverable budget-remaining indicator, week picker sidebar.
  Deliverables shown are those the signed-in person is staffed on
  (`staffing` table) plus any deliverable they already logged time
  against for the selected week.

### Known simplifications (flag these to the team before relying on them)

- "Budget Remaining" = `deliverables.planned_hours_level_<N>` minus
  all-time reported hours at that level, where `<N>` is the signed-in
  user's `team_members.level`. The original AppSheet calc may differ
  (e.g. day-based via `deliverable_days_summary`) — worth confirming
  against a few real deliverables before trusting the number.
- No RLS yet (see above).
- Week list is a fixed ±N-week window around today, not driven by any
  "active sprint" concept.
