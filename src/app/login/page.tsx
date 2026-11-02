"use client";

import { useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase/browser";
import { Button } from "@/components/ui/button";

export default function LoginPage() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function signInWithGoogle() {
    setLoading(true);
    setError(null);
    const supabase = createBrowserSupabaseClient();
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
        queryParams: {
          hd: "goalkeep.net",
          prompt: "select_account",
        },
      },
    });
    if (error) {
      setError(error.message);
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-neutral-50">
      <div className="w-full max-w-sm rounded-xl border border-neutral-200 bg-white p-8 shadow-sm">
        <h1 className="text-xl font-semibold text-neutral-900">
          Goalkeep WorkManage
        </h1>
        <p className="mt-1 text-sm text-neutral-500">
          Sign in with your Goalkeep Google account to log time.
        </p>
        <Button
          className="mt-6 w-full"
          onClick={signInWithGoogle}
          disabled={loading}
        >
          {loading ? "Redirecting…" : "Sign in with Google"}
        </Button>
        {error ? (
          <p className="mt-3 text-sm text-red-600">{error}</p>
        ) : null}
      </div>
    </div>
  );
}
