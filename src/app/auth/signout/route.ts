import { NextResponse } from "next/server";
import { createAuthServerClient } from "@/lib/supabase/server-auth";

export async function POST(request: Request) {
  const supabase = await createAuthServerClient();
  await supabase.auth.signOut();
  return NextResponse.redirect(new URL("/login", request.url));
}
