import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import {
  ENV_VARS,
  REMEMBER_ME_COOKIE,
  REMEMBER_ME_MAX_AGE,
} from '../constants';

/**
 * Especially important if using Fluid compute: Don't put this client in a
 * global variable. Always create a new client within each function when using
 * it.
 */
export async function createClient() {
  const cookieStore = await cookies();
  const remembered = cookieStore.get(REMEMBER_ME_COOKIE)?.value === '1';

  return createServerClient(
    process.env[ENV_VARS.SUPABASE_URL]!,
    process.env[ENV_VARS.SUPABASE_ANON_KEY]!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => {
              // Keep removals as removals; scope writes by remember-me marker
              // (absent marker -> session cookie, cleared on browser close)
              const maxAge =
                options.maxAge === 0
                  ? 0
                  : remembered
                    ? REMEMBER_ME_MAX_AGE
                    : undefined;
              const cookieOptions = { ...options };
              if (maxAge === undefined) delete cookieOptions.maxAge;
              else cookieOptions.maxAge = maxAge;
              cookieStore.set(name, value, cookieOptions);
            });
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing
            // user sessions.
          }
        },
      },
    }
  );
}
