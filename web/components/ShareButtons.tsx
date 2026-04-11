'use client'

import { useState } from 'react'
import QRCodeShare from '@/components/QRCodeShare'

async function trackShare(platform: string, sourcePage: string) {
  await fetch('/api/track-share', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ platform, sourcePage }),
  })
}

export default function ShareButtons({
  sourcePage,
  shareUrl,
  shareText,
}: {
  sourcePage: string
  shareUrl: string
  shareText: string
}) {
  const [toast, setToast] = useState('')

  function showToast(msg: string) {
    setToast(msg)
    setTimeout(() => setToast(''), 2000)
  }

  async function handleFacebook() {
    await trackShare('facebook', sourcePage)
    window.open(
      `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`,
      '_blank',
      'noopener,noreferrer'
    )
  }

  async function handleTwitter() {
    await trackShare('twitter', sourcePage)
    window.open(
      `https://twitter.com/intent/tweet?url=${encodeURIComponent(shareUrl)}&text=${encodeURIComponent(shareText)}`,
      '_blank',
      'noopener,noreferrer'
    )
  }

  async function handleInstagram() {
    await trackShare('instagram', sourcePage)
    await navigator.clipboard.writeText(shareUrl)
    showToast('Link copied — paste it in your Instagram bio or story.')
  }

  async function handleCopy() {
    await trackShare('copy', sourcePage)
    await navigator.clipboard.writeText(shareUrl)
    showToast('Link copied!')
  }

  const btnClass =
    'border border-[#e8e8e8] text-xs font-medium rounded-full px-4 py-2.5 min-h-[44px] hover:border-[#3bbfbe] hover:text-[#3bbfbe] transition-colors text-[#666666]'

  return (
    <div>
      <div className="flex flex-wrap gap-2">
        <button onClick={handleFacebook} className={btnClass}>f Facebook</button>
        <button onClick={handleTwitter} className={btnClass}>𝕏 X</button>
        <button onClick={handleInstagram} className={btnClass}>📷 Instagram (copy link)</button>
        <button onClick={handleCopy} className={btnClass}>🔗 Copy link</button>
      </div>
      {toast && (
        <p className="text-xs text-[#3bbfbe] mt-2">{toast}</p>
      )}
      <div className="flex items-center gap-4 mt-4 pt-4 border-t border-[#e8e8e8]">
        <div className="flex-1">
          <p className="text-xs font-semibold text-[#333333] mb-0.5">Share via QR code</p>
          <p className="text-xs text-[#888888]">Print it, post it, or scan it anywhere.</p>
        </div>
        <QRCodeShare url={shareUrl} />
      </div>
    </div>
  )
}
