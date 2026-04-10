import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase'

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()
    const { email, firstName, interest, sourcePage } = body

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return NextResponse.json({ error: 'Valid email required' }, { status: 400 })
    }

    const supabase = createServiceClient()

    const { error } = await supabase.schema('babyquest').from('email_leads').upsert(
      {
        email: email.toLowerCase().trim(),
        first_name: firstName?.trim() || null,
        interest: interest || 'general',
        source_page: sourcePage || '/',
        subscribed_at: new Date().toISOString(),
      },
      { onConflict: 'email', ignoreDuplicates: false }
    )

    if (error) {
      console.error('Email lead insert error:', error)
      return NextResponse.json({ error: 'Could not save — please try again.' }, { status: 500 })
    }

    return NextResponse.json({ success: true })
  } catch (err) {
    console.error('Subscribe route error:', err)
    return NextResponse.json({ error: 'Server error' }, { status: 500 })
  }
}
