import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase'

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()
    const { page } = body
    const supabase = createServiceClient()
    await supabase.schema('babyquest').from('page_views').insert({ page: page ?? '/' })
  } catch {
    // fire-and-forget — never surface errors to client
  }
  return NextResponse.json({ success: true })
}
