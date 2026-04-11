'use client'
import { useState } from 'react'
import QRCode from 'react-qr-code'

const BQ_TEAL = '#3bbfbe'

export default function QRCodeShare({ url }: { url: string }) {
  const [modalOpen, setModalOpen] = useState(false)

  async function trackAndDownload() {
    await fetch('/api/track-share', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ platform: 'qr', sourcePage: '/' }),
    })
    const svg = document.getElementById('bq-qr-large')
    if (!svg) return
    const svgData = new XMLSerializer().serializeToString(svg)
    const blob = new Blob([svgData], { type: 'image/svg+xml' })
    const downloadUrl = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = downloadUrl
    a.download = 'babyquest-qr.svg'
    a.click()
    URL.revokeObjectURL(downloadUrl)
  }

  return (
    <>
      <button
        onClick={() => setModalOpen(true)}
        className="flex flex-col items-center gap-1.5 group cursor-pointer"
        aria-label="Enlarge QR code"
      >
        <div className="border border-[#e8e8e8] rounded-lg p-2 bg-white shadow-sm group-hover:border-[#3bbfbe] transition-colors">
          <QRCode value={url} size={72} fgColor={BQ_TEAL} bgColor="#ffffff" />
        </div>
        <span className="text-[10px] text-[#aaaaaa] font-medium">Tap to enlarge</span>
      </button>

      {modalOpen && (
        <div
          className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-6"
          onClick={() => setModalOpen(false)}
        >
          <div
            className="bg-white rounded-2xl p-8 shadow-xl max-w-sm w-full flex flex-col items-center gap-6"
            onClick={(e) => e.stopPropagation()}
          >
            <p className="text-xs font-semibold uppercase tracking-widest text-[#595959]">Scan to visit</p>
            <QRCode id="bq-qr-large" value={url} size={220} fgColor={BQ_TEAL} bgColor="#ffffff" />
            <p className="text-xs text-[#888888] text-center break-all">{url}</p>
            <div className="flex gap-3 w-full">
              <button
                onClick={trackAndDownload}
                className="flex-1 py-2.5 text-sm font-semibold text-white rounded-lg transition-opacity hover:opacity-90"
                style={{ backgroundColor: BQ_TEAL }}
              >
                Download SVG
              </button>
              <button
                onClick={() => setModalOpen(false)}
                className="flex-1 py-2.5 text-sm font-medium border border-[#e8e8e8] rounded-lg hover:border-[#3bbfbe] hover:text-[#3bbfbe] transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
