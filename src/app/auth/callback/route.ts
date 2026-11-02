import { NextResponse } from "next/server";
import { createAuthServerClient } from "@/lib/supabase/server-auth";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");

  if (code) {
    const supabase = await createAuthServerClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(`${origin}/time-entry`);
    }
  }

  return NextResponse.redirect(`${origin}/login`);
}
