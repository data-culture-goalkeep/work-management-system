import "server-only";
import { createClient } from "@supabase/supabase-js";

/**
 * Service-role client for reading/writing app data tables. This key is
 * never exposed to the browser (no NEXT_PUBLIC_ prefix) — importing this
 * file from a Client Component is a build-time error thanks to `server-only`.
 *
 * There is no RLS on these tables yet, so every caller of this client is
 * responsible for applying its own authorization checks (e.g. always
 * deriving `team_member_id` from the authenticated session, never from
 * client input) before reading or writing.
 */
export function createDataClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { persistSession: false } }
  );
}
