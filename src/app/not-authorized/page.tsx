export default function NotAuthorizedPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-neutral-50 px-6 text-center">
      <div>
        <h1 className="text-lg font-semibold text-neutral-900">
          No team member record found
        </h1>
        <p className="mt-2 max-w-sm text-sm text-neutral-500">
          Your Google account signed in successfully, but there is no
          matching row in the team_members table for this email yet. Ask an
          admin to add one.
        </p>
        <form action="/auth/signout" method="post" className="mt-4">
          <button type="submit" className="text-sm underline">
            Sign out
          </button>
        </form>
      </div>
    </div>
  );
}
