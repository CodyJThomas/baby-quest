'use client'

import { useEffect } from 'react'

export default function PageViewTracker({ page }: { page: string }) {
  useEffect(() => {
    fetch('/api/track-pageview', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ page }),
    })
  }, [page])

  return null
}
