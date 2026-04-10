'use client'

import { useState } from 'react'

const BQ_TEAL = '#3bbfbe'

export default function EmailCapture({ sourcePage = '/' }: { sourcePage?: string }) {
  const [email, setEmail] = useState('')
  const [firstName, setFirstName] = useState('')
  const [interest, setInterest] = useState('general')
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle')
  const [errorMsg, setErrorMsg] = useState('')

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setStatus('loading')
    setErrorMsg('')

    try {
      const res = await fetch('/api/subscribe', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, firstName, interest, sourcePage }),
      })
      const data = await res.json()
      if (!res.ok) {
        setErrorMsg(data.error ?? 'Something went wrong.')
        setStatus('error')
      } else {
        setStatus('success')
      }
    } catch {
      setErrorMsg('Network error — please try again.')
      setStatus('error')
    }
  }

  if (status === 'success') {
    return (
      <div className="rounded-xl border border-[#e8e8e8] bg-white p-8 shadow-sm text-center">
        <div
          className="w-12 h-12 rounded-full flex items-center justify-center text-white text-xl font-bold mx-auto mb-4"
          style={{ backgroundColor: BQ_TEAL }}
        >
          ✓
        </div>
        <h3 className="text-lg font-bold text-[#333333] mb-2">You&apos;re in.</h3>
        <p className="text-sm text-[#666666]">
          Thank you, {firstName || 'friend'}. We&apos;ll share updates on grant cycles, our journey, and how you can help.
        </p>
      </div>
    )
  }

  return (
    <div className="rounded-xl border border-[#e8e8e8] bg-white p-6 md:p-8 shadow-sm">
      <h3 className="text-lg font-bold text-[#333333] mb-1">Stay connected</h3>
      <p className="text-sm text-[#666666] mb-6">
        Get updates on grant cycles, our IVF journey, and ways to support BabyQuest. No spam — ever.
      </p>
      <form onSubmit={handleSubmit} className="space-y-3">
        <div className="grid sm:grid-cols-2 gap-3">
          <input
            type="text"
            placeholder="First name"
            value={firstName}
            onChange={(e) => setFirstName(e.target.value)}
            className="w-full px-4 py-2.5 border border-[#e8e8e8] rounded-lg text-sm text-[#333333] placeholder-[#aaaaaa] focus:outline-none focus:border-[#3bbfbe] transition-colors"
          />
          <input
            type="email"
            placeholder="Email address *"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full px-4 py-2.5 border border-[#e8e8e8] rounded-lg text-sm text-[#333333] placeholder-[#aaaaaa] focus:outline-none focus:border-[#3bbfbe] transition-colors"
          />
        </div>
        <select
          value={interest}
          onChange={(e) => setInterest(e.target.value)}
          className="w-full px-4 py-2.5 border border-[#e8e8e8] rounded-lg text-sm text-[#333333] focus:outline-none focus:border-[#3bbfbe] transition-colors bg-white"
        >
          <option value="general">I want to follow the journey</option>
          <option value="donor">I&apos;m interested in donating</option>
          <option value="recipient">I&apos;m facing infertility myself</option>
          <option value="corporate">Corporate / organizational giving</option>
        </select>
        {status === 'error' && (
          <p className="text-xs text-red-600">{errorMsg}</p>
        )}
        <button
          type="submit"
          disabled={status === 'loading'}
          className="w-full py-3 text-white font-semibold rounded-lg transition-opacity hover:opacity-90 disabled:opacity-60 text-sm"
          style={{ backgroundColor: BQ_TEAL }}
        >
          {status === 'loading' ? 'Saving...' : 'Keep me updated →'}
        </button>
        <p className="text-xs text-[#aaaaaa] text-center">
          We never share your info. Unsubscribe anytime.
        </p>
      </form>
    </div>
  )
}
