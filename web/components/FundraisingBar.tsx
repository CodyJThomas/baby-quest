import { EYEBROW } from '@/lib/styles'

export default function FundraisingBar({
  goalAmount,
  currentAmount,
  label,
}: {
  goalAmount: number
  currentAmount: number
  label: string
}) {
  const pct = Math.min(100, Math.round((currentAmount / goalAmount) * 100))

  return (
    <div className="rounded-xl border border-[#e8e8e8] bg-white shadow-sm p-6">
      <p className={`${EYEBROW} mb-2`}>Fundraising goal</p>
      <p className="text-base font-bold text-[#333333] mb-4">{label}</p>
      <div className="bg-[#f0f0f0] h-3 rounded-full overflow-hidden mb-2">
        <div
          className="h-3 rounded-full bg-[#3bbfbe] transition-all"
          style={{ width: pct === 0 ? '4px' : `max(12px, ${pct}%)` }}
        />
      </div>
      <div className="flex items-center justify-between">
        <span className="text-xs text-[#666666]">
          ${currentAmount.toLocaleString()} raised of ${goalAmount.toLocaleString()} goal
        </span>
        <span className="text-xs font-semibold text-[#3bbfbe]">{pct}%</span>
      </div>
      <p className="text-xs text-[#aaaaaa] mt-3">
        Your gift helps fund IVF for someone who has no other options.
      </p>
      <a
        href="https://babyquestfoundation.org/donate"
        target="_blank"
        rel="noopener noreferrer"
        className="mt-4 inline-flex items-center gap-1 text-sm font-semibold transition-opacity hover:opacity-80"
        style={{ color: '#3bbfbe' }}
      >
        Donate to reach the goal ↗
      </a>
    </div>
  )
}
