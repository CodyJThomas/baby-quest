import { createServiceClient } from '@/lib/supabase'

async function getAccessGap() {
  const supabase = createServiceClient()
  const { data } = await supabase
    .schema('babyquest')
    .from('mv_access_gap')
    .select('*')
    .single()
  return data
}

async function getOhioProfile() {
  const supabase = createServiceClient()
  const { data } = await supabase
    .schema('babyquest')
    .from('mv_ohio_profile')
    .select('*')
    .single()
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

export default async function Home() {
  const [gap, ohio, legislation, mandates] = await Promise.all([
    getAccessGap(),
    getOhioProfile(),
    getLegislation(),
    getMandateSummary(),
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

  return (
    <main className="min-h-screen bg-white text-[#666666]">

      <div className="max-w-6xl mx-auto px-6 py-10 space-y-10">

        {/* Hero stat row */}
        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-4">
            US IVF Access Gap
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard
              value={gap?.states_without_mandate ?? '—'}
              label="States with no IVF mandate"
              sub="out of 51"
              color="text-red-600"
            />
            <StatCard
              value={gap?.states_covering_ivf ?? '—'}
              label="States that actually cover IVF"
              sub={gap ? `${gap.pct_states_with_mandate}% of states` : ''}
              color="text-green-600"
            />
            <StatCard
              value={gap?.states_with_mandate ?? '—'}
              label="States with any mandate"
              sub="many cover diagnosis only"
              color="text-amber-600"
            />
            <StatCard
              value="$15,000"
              label="Average out-of-pocket IVF cost"
              sub="per cycle, uninsured"
              color="text-[#333333]"
            />
          </div>
        </section>

        {/* Ohio profile */}
        <section>
          <h2 className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-4">
            Ohio — Our Home State
          </h2>
          <div className="rounded-xl border border-[#e8e8e8] bg-[#f9f9f9] p-6 grid md:grid-cols-3 gap-6 shadow-sm">
            <div>
              <p className="text-xs text-[#999999] mb-1">Mandate Status</p>
              <p className="text-xl font-bold text-amber-600">
                {ohio?.has_mandate ? 'Mandate — but no IVF' : 'No Mandate'}
              </p>
              <p className="text-xs text-[#999999] mt-1">
                Ohio requires HMOs to offer an optional infertility rider — but IVF is not covered.
              </p>
            </div>
            <div>
              <p className="text-xs text-[#999999] mb-1">Active OH Legislation</p>
              <p className="text-xl font-bold" style={{ color: '#3bbfbe' }}>
                {ohio?.active_oh_bills ?? 0} bill{ohio?.active_oh_bills !== 1 ? 's' : ''}
              </p>
              <p className="text-xs text-[#999999] mt-1">
                {ohio?.favorable_oh_bills ?? 0} favorable · {ohio?.restrictive_oh_bills ?? 0} restrictive
              </p>
            </div>
            <div>
              <p className="text-xs text-[#999999] mb-1">Ohio HB 38</p>
              <p className="text-sm font-medium text-[#333333]">IVF Insurance Coverage Act</p>
              <p className="text-xs text-[#999999] mt-1">
                Would mandate full IVF coverage for employers with 25+ employees.
                Currently in House Insurance Committee.
              </p>
            </div>
          </div>
        </section>

        {/* Legislation tracker */}
        {legislation.length > 0 && (
          <section>
            <h2 className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-4">
              Active Legislation
            </h2>
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
          <h2 className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-4">
            State Mandate Map — {mandates.length} States
          </h2>
          <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-2">
            {mandates.map((state: any) => (
              <div
                key={state.usps_code}
                className="rounded-lg p-2 bg-white border border-[#e8e8e8] text-center shadow-sm"
                title={`${state.state_name}: ${coverageLevelLabel[state.coverage_level] ?? 'Unknown'}`}
              >
                <div className="text-xs font-bold text-[#333333] mb-1">{state.usps_code}</div>
                <div className={`w-2 h-2 rounded-full mx-auto ${coverageLevelColor[state.coverage_level] ?? 'bg-[#cccccc]'}`} />
              </div>
            ))}
          </div>
          <div className="flex flex-wrap items-center gap-5 mt-4">
            {Object.entries(coverageLevelLabel).map(([level, label]) => (
              <div key={level} className="flex items-center gap-1.5">
                <div className={`w-2 h-2 rounded-full ${coverageLevelColor[level]}`} />
                <span className="text-xs text-[#888888]">{label}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Footer */}
        <footer className="border-t border-[#e8e8e8] pt-6 text-xs text-[#aaaaaa]">
          <p>
            Data: CDC ART Surveillance (NASS), RESOLVE State Mandate Tracker, NCSL, Congress.gov.
            {gap?.data_as_of && ` Mandate data as of ${new Date(gap.data_as_of).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}.`}
          </p>
          <p className="mt-2">
            <a href="/" className="underline hover:text-[#3bbfbe] transition-colors">← Back to home</a>
          </p>
        </footer>
      </div>
    </main>
  )
}

function StatCard({
  value,
  label,
  sub,
  color,
}: {
  value: string | number
  label: string
  sub?: string
  color: string
}) {
  return (
    <div className="rounded-xl border border-[#e8e8e8] bg-white p-5 shadow-sm">
      <p className={`text-3xl font-bold tabular-nums ${color}`}>{value}</p>
      <p className="text-sm text-[#333333] mt-1">{label}</p>
      {sub && <p className="text-xs text-[#888888] mt-0.5">{sub}</p>}
    </div>
  )
}
