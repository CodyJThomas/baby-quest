import { createServiceClient } from '@/lib/supabase'
import Link from 'next/link'
import EmailCapture from '@/components/EmailCapture'
import PageViewTracker from '@/components/PageViewTracker'

import { EYEBROW } from '@/lib/styles'

const BQ_TEAL = '#3bbfbe'

async function getAccessGap() {
  const supabase = createServiceClient()
  const { data } = await supabase.schema('babyquest').from('mv_access_gap').select('*').single()
  return data
}

async function getOhioProfile() {
  const supabase = createServiceClient()
  const { data } = await supabase.schema('babyquest').from('mv_ohio_profile').select('*').single()
  return data
}

async function getLegislation() {
  const supabase = createServiceClient()
  const { data } = await supabase
    .schema('babyquest')
    .from('mv_legislation_tracker')
    .select('*')
    .order('last_action_date', { ascending: false })
    .limit(6)
  return data ?? []
}

async function getMandateSummary() {
  const supabase = createServiceClient()
  const { data } = await supabase
    .schema('babyquest')
    .from('mv_mandate_summary')
    .select('usps_code, state_name, has_mandate, coverage_level, covers_ivf, region')
    .order('state_name')
  return data ?? []
}

async function getOhioStats() {
  const supabase = createServiceClient()
  const { data } = await supabase
    .schema('babyquest')
    .from('fertility_stats')
    .select('metric_name, value, unit, geo_name')
    .eq('geo_level', 'state')
    .order('geo_name')
  return data ?? []
}

export default async function DataPage() {
  const [gap, ohio, legislation, mandates, stateStats] = await Promise.all([
    getAccessGap(),
    getOhioProfile(),
    getLegislation(),
    getMandateSummary(),
    getOhioStats(),
  ])

  const coverageLevelLabel: Record<string, string> = {
    full_treatment: 'Full Coverage',
    limited_treatment: 'Limited',
    diagnostics_only: 'Diagnostics Only',
    none: 'No Mandate',
  }

  const coverageLevelColor: Record<string, string> = {
    full_treatment: 'bg-green-500',
    limited_treatment: 'bg-amber-400',
    diagnostics_only: 'bg-orange-400',
    none: 'bg-red-400',
  }

  // Build state comparison: cycles per million, all seeded states
  const cyclesPerMillion = stateStats
    .filter((s) => s.metric_name === 'cycles_per_million')
    .sort((a, b) => (b.value as number) - (a.value as number))

  const maxCycles = Math.max(...cyclesPerMillion.map((s) => s.value as number), 1)

  return (
    <main className="min-h-screen bg-white text-[#666666]">
      <div className="max-w-4xl mx-auto px-4 md:px-6 py-10 space-y-12">

        {/* Page header */}
        <section className="border-b border-[#e8e8e8] pb-6">
          <p className={`${EYEBROW} mb-2`}>Fertility Access Intelligence</p>
          <h1 className="text-3xl md:text-4xl font-bold text-[#333333] mb-2">Research Data</h1>
          <p className="text-[#666666] max-w-2xl">
            Live data on IVF insurance mandates, state access gaps, and active legislation.
            Built to support BabyQuest Foundation&apos;s mission and inform donor giving.
          </p>
        </section>

        {/* National access gap */}
        <section>
          <p className={`${EYEBROW} mb-3`}>US IVF access gap</p>
          <h2 className="text-xl font-bold text-[#333333] mb-5">The national picture</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard
              value={gap?.states_without_mandate ?? '—'}
              label="States with no fertility mandate"
              sub="out of 51"
              color="text-red-600"
            />
            <StatCard
              value={gap?.states_covering_ivf ?? '—'}
              label="States that actually cover IVF"
              sub={gap ? `${gap.pct_states_with_mandate}% of all states` : ''}
              color="text-green-600"
            />
            <StatCard
              value={gap?.states_with_mandate ?? '—'}
              label="States with any mandate"
              sub="most cover diagnosis only"
              color="text-amber-600"
            />
            <StatCard
              value="$16,000+"
              label="Average IVF cost per cycle"
              sub="plus ~$5,000 medications"
              color="text-[#333333]"
            />
          </div>
        </section>

        {/* Ohio profile */}
        <section>
          <p className={`${EYEBROW} mb-3`}>Ohio — our home state</p>
          <h2 className="text-xl font-bold text-[#333333] mb-5">Where we live, and what we face</h2>
          <div className="rounded-xl border border-[#e8e8e8] bg-[#f9f9f9] p-6 shadow-sm">
            <div className="grid md:grid-cols-3 gap-6 mb-6">
              <div>
                <p className="text-xs text-[#595959] mb-1">Mandate status</p>
                <p className="text-xl font-bold text-amber-600">Mandate — but no IVF</p>
                <p className="text-xs text-[#888888] mt-1">
                  Ohio requires HMOs to offer an optional infertility rider — but IVF is explicitly excluded.
                </p>
              </div>
              <div>
                <p className="text-xs text-[#595959] mb-1">IVF cycles started (2022)</p>
                <p className="text-xl font-bold" style={{ color: BQ_TEAL }}>4,100</p>
                <p className="text-xs text-[#888888] mt-1">
                  900 cycles per million residents — vs. 3,200 in New York.
                </p>
              </div>
              <div>
                <p className="text-xs text-[#595959] mb-1">Live birth rate per cycle</p>
                <p className="text-xl font-bold text-[#333333]">40.5%</p>
                <p className="text-xs text-[#888888] mt-1">
                  IVF works — when people can access and afford it.
                </p>
              </div>
            </div>

            {/* Ohio HB 38 */}
            <div className="border-t border-[#e8e8e8] pt-5">
              <p className="text-xs text-[#595959] mb-2">Active Ohio legislation</p>
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="text-sm font-semibold text-[#333333]">HB 38 — Ohio IVF Insurance Coverage Act</p>
                  <p className="text-xs text-[#888888] mt-1">
                    Would mandate full IVF coverage for employers with 25+ employees. Currently in House Insurance Committee.
                  </p>
                </div>
                <span className="shrink-0 text-xs px-2 py-1 rounded-full font-medium bg-green-50 text-green-700 border border-green-200">
                  ✓ Favorable
                </span>
              </div>
            </div>
          </div>
        </section>

        {/* State access comparison */}
        {cyclesPerMillion.length > 0 && (
          <section>
            <p className={`${EYEBROW} mb-3`}>State comparison</p>
            <h2 className="text-xl font-bold text-[#333333] mb-2">IVF cycles per million residents</h2>
            <p className="text-sm text-[#666666] mb-6 max-w-2xl">
              A low number means fewer people with infertility are getting treatment — not that fewer people need it.
              Ohio ranks among the lowest of seeded states.
            </p>
            <div className="space-y-3">
              {cyclesPerMillion.map((s) => {
                const isOhio = s.geo_name === 'Ohio'
                const pct = Math.round(((s.value as number) / maxCycles) * 100)
                return (
                  <div key={s.geo_name} className="flex items-center gap-4">
                    <span className={`text-xs font-semibold w-24 shrink-0 ${isOhio ? 'text-[#333333]' : 'text-[#888888]'}`}>
                      {s.geo_name}
                    </span>
                    <div className="flex-1 bg-[#f0f0f0] rounded-full h-3 overflow-hidden">
                      <div
                        className="h-3 rounded-full transition-all"
                        style={{
                          width: `${pct}%`,
                          backgroundColor: isOhio ? '#dc2626' : BQ_TEAL,
                        }}
                      />
                    </div>
                    <span className={`text-xs font-mono w-20 text-right shrink-0 ${isOhio ? 'text-red-600 font-bold' : 'text-[#888888]'}`}>
                      {(s.value as number).toLocaleString()}
                    </span>
                  </div>
                )
              })}
            </div>
            <p className="text-xs text-[#aaaaaa] mt-4 font-mono">
              Source: CDC ART Surveillance System (NASS), 2022. Cycles per million residents.
            </p>
          </section>
        )}

        {/* Legislation tracker */}
        {legislation.length > 0 && (
          <section>
            <p className={`${EYEBROW} mb-3`}>Policy tracker</p>
            <h2 className="text-xl font-bold text-[#333333] mb-5">Active legislation</h2>
            <div className="space-y-3">
              {legislation.map((bill: any) => (
                <div
                  key={`${bill.bill_number}-${bill.jurisdiction_name}`}
                  className="rounded-lg border border-[#e8e8e8] bg-white px-5 py-4 flex items-start justify-between gap-4 shadow-sm"
                >
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-xs font-mono text-[#888888]">{bill.bill_number}</span>
                      <span className="text-xs text-[#cccccc]">·</span>
                      <span className="text-xs text-[#888888]">{bill.jurisdiction_name}</span>
                    </div>
                    <p className="text-sm font-medium text-[#333333] truncate">{bill.short_title ?? bill.title}</p>
                    {bill.summary && (
                      <p className="text-xs text-[#888888] mt-1 line-clamp-2">{bill.summary}</p>
                    )}
                  </div>
                  <div className="flex flex-col items-end gap-1 shrink-0">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                      bill.ivf_favorable === true
                        ? 'bg-green-50 text-green-700 border border-green-200'
                        : bill.ivf_favorable === false
                        ? 'bg-red-50 text-red-700 border border-red-200'
                        : 'bg-gray-100 text-[#888888] border border-[#e8e8e8]'
                    }`}>
                      {bill.ivf_favorable === true ? '✓ Favorable' : bill.ivf_favorable === false ? '✗ Restrictive' : 'Neutral'}
                    </span>
                    <span className="text-xs text-[#aaaaaa] capitalize">{bill.status?.replace(/_/g, ' ')}</span>
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* State mandate grid */}
        <section>
          <p className={`${EYEBROW} mb-3`}>State mandate map</p>
          <h2 className="text-xl font-bold text-[#333333] mb-2">{mandates.length} states — coverage at a glance</h2>
          <p className="text-sm text-[#666666] mb-6">
            Red = no mandate. Green = full IVF coverage.
          </p>
          <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-1.5">
            {mandates.map((state: any) => (
              <div
                key={state.usps_code}
                className="rounded-lg p-2 bg-white border border-[#e8e8e8] text-center shadow-sm"
                title={`${state.state_name}: ${coverageLevelLabel[state.coverage_level] ?? 'Unknown'}`}
              >
                <div className="text-xs font-bold text-[#333333] mb-1">{state.usps_code}</div>
                <div className={`w-3 h-3 rounded-full mx-auto ${coverageLevelColor[state.coverage_level] ?? 'bg-[#cccccc]'}`} />
              </div>
            ))}
          </div>
          <div className="flex flex-wrap items-center gap-5 mt-4">
            {Object.entries(coverageLevelLabel).map(([level, label]) => (
              <div key={level} className="flex items-center gap-1.5">
                <div className={`w-3 h-3 rounded-full ${coverageLevelColor[level]}`} />
                <span className="text-xs text-[#888888]">{label}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Email capture */}
        <section className="border-t border-[#e8e8e8] pt-14">
          <div className="grid md:grid-cols-2 gap-10 items-start">
            <div>
              <p className={`${EYEBROW} mb-3`}>Follow along</p>
              <h2 className="text-2xl font-bold text-[#333333] mb-4">Stay in the loop</h2>
              <p className="text-[#666666] leading-relaxed mb-4">
                We update this data as new research and legislation emerges. Get notified when the
                numbers change — and when grant cycles open.
              </p>
              <p className="text-[#666666] leading-relaxed">
                If you want to help — or you&apos;re facing infertility yourself — join us.
              </p>
            </div>
            <EmailCapture sourcePage="/data" />
          </div>
        </section>

        <PageViewTracker page="/data" />

        {/* Footer */}
        <footer className="border-t border-[#e8e8e8] pt-6 pb-4 text-xs text-[#aaaaaa]">
          <p>
            Sources: CDC ART Surveillance System (NASS) 2022, RESOLVE State Insurance Mandate Tracker,
            NCSL, Congress.gov, NCHS National Survey of Family Growth 2022–2023.
            {gap?.data_as_of && ` Mandate data as of ${new Date(gap.data_as_of).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}.`}
          </p>
          <p className="mt-4">
            <Link href="/" className="underline hover:text-[#3bbfbe] transition-colors">← Back to home</Link>
          </p>
        </footer>

      </div>
    </main>
  )
}

function StatCard({
  value, label, sub, color,
}: {
  value: string | number
  label: string
  sub?: string
  color: string
}) {
  return (
    <div className="rounded-xl border border-[#e8e8e8] bg-white p-5 shadow-sm">
      <p className={`text-3xl font-bold tabular-nums ${color}`}>{value}</p>
      <p className="text-sm font-semibold text-[#333333] mt-1">{label}</p>
      {sub && <p className="text-xs text-[#888888] mt-0.5">{sub}</p>}
    </div>
  )
}
