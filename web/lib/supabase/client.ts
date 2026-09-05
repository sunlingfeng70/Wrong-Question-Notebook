import { createBrowserClient } from '@supabase/ssr';
import { REMEMBER_ME_COOKIE, REMEMBER_ME_MAX_AGE } from '../constants';

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_OR_ANON_KEY!,
    {
      // Custom cookie adapter: @supabase/ssr forces a 400-day maxAge on auth
      // cookies, so the only way to honour "remember me" is to override it
      // here. Marker present -> 30-day cookie; absent -> session cookie.
      cookies: {
        getAll() {
          return document.cookie
            .split('; ')
            .filter(Boolean)
            .map(cookie => {
              const [name, ...value] = cookie.split('=');
              return { name, value: value.join('=') };
            });
        },
        setAll(cookiesToSet) {
          const remembered = document.cookie
            .split('; ')
            .some(c => c.startsWith(`${REMEMBER_ME_COOKIE}=1`));
          cookiesToSet.forEach(({ name, value, options }) => {
            const parts = [`${name}=${value}`, `Path=${options?.path ?? '/'}`];
            if (options?.sameSite) parts.push(`SameSite=${options.sameSite}`);
            if (options?.secure) parts.push('Secure');
            if (options?.maxAge === 0) {
              parts.push('Max-Age=0'); // cookie removal
            } else if (remembered) {
              parts.push(`Max-Age=${REMEMBER_ME_MAX_AGE}`);
            }
            // else: session cookie (no Max-Age) — transient login
            document.cookie = parts.join('; ');
          });
        },
      },
    }
  );
}
