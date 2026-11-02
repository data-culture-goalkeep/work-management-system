import { redirect } from "next/navigation";
import { getCurrentUserEmail } from "@/lib/supabase/server-auth";

export default async function Home() {
  const email = await getCurrentUserEmail();
  redirect(email ? "/time-entry" : "/login");
}
