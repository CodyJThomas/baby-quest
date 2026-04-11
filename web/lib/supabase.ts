import { createClient } from '@supabase/supabase-js'

// Server-side client with service role for API routes and server components
export function createServiceClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )
}
