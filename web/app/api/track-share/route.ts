import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase'

const VALID_PLATFORMS = ['facebook', 'twitter', 'instagram', 'copy']

export async function POST(req: NextRequest) {
  const body = await req.json()
  const { platform, sourcePage } = body

  if (!VALID_PLATFORMS.includes(platform)) {
    return NextResponse.json({ error: 'Invalid platform' }, { status: 400 })
  }

  const supabase = createServiceClient()
  await supabase.schema('babyquest').from('share_events').insert({
    platform,
    source_page: sourcePage ?? '/',
  })

  return NextResponse.json({ success: true })
}
