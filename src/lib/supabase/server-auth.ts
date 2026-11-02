import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";

/**
 * Session-only client (anon key + user's cookies). Used to find out *who*
 * is logged in. Never used to query app data tables directly.
 */
export async function createAuthServerClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // Called from a Server Component render; middleware refreshes
            // the session cookie on the way in, so this is safe to ignore.
          }
        },
      },
    }
  );
}

export async function getCurrentUserEmail(): Promise<string | null> {
  const supabase = await createAuthServerClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user?.email ?? null;
}
