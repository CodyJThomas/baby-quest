import Link from 'next/link'

const BQ_BLUE = '#3bbfbe'
const BQ_CHARCOAL = '#32373c'

const STATS = [
  {
    value: '1 in 8',
    label: 'Couples experience infertility',
    source: 'NCHS, 2015–2019',
    hexColor: BQ_BLUE,
    detail: '9.7 million women ages 15–49 have impaired fecundity.',
  },
  {
    value: '1.6%',
    label: 'Of women have accessed IVF or ART',
    source: 'NCHS, 2022–2023',
    hexColor: '#d97706',
    detail: 'Fewer than 2 in 100 women have reached the treatment most likely to work.',
  },
  {
    value: '$15,000',
    label: 'Average cost per IVF cycle, uninsured',
    source: 'RESOLVE estimate',
    hexColor: '#dc2626',
    detail: 'Ohio has no IVF coverage mandate. Most cycles are paid entirely out of pocket.',
  },
]

const ACCESS_FACTS = [
  {
    stat: '5×',
    label: 'More likely to use IVF with private insurance vs. public',
    detail: '13.6% private insurance vs. 4.4% public coverage',
  },
  {
    stat: '3×',
    label: 'More likely to use IVF in highest vs. lowest income bracket',
    detail: '14.8% top income bracket vs. 5.0% lowest',
  },
  {
    stat: '~19',
    label: 'States with any insurance mandate for infertility',
    detail: 'Most cover diagnostics only. Fewer than 20 require IVF coverage.',
  },
]

export default function LandingPage() {
  return (
    <main className="min-h-screen bg-white text-[#666666]">

      {/* Hero */}
      <section className="max-w-4xl mx-auto px-6 pt-12 pb-10 md:pt-20 md:pb-16">
        <div className="mb-6">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: BQ_BLUE }}>
            BabyQuest Foundation — Spring 2026 Recipients
          </span>
        </div>
        <h1 className="text-4xl md:text-5xl font-bold leading-tight tracking-tight mb-6 text-[#333333]">
          Infertility isn&apos;t rare.
          <br />
          <span style={{ color: BQ_BLUE }}>Access to treatment is.</span>
        </h1>
        <p className="text-lg text-[#666666] max-w-2xl leading-relaxed mb-8">
          Cody and Rochelle Thomas are IVF patients in Lakewood, Ohio — and Spring 2026 grant
          recipients of BabyQuest Foundation. We&apos;re building this platform to make the case
          that no couple should have to choose between starting a family and financial ruin.
        </p>
        <div className="flex flex-col sm:flex-row gap-4">
          <a
            href="https://babyquestfoundation.org/donate"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center px-6 py-3 text-white font-semibold rounded-lg transition-opacity hover:opacity-90 text-sm"
            style={{ backgroundColor: BQ_BLUE }}
          >
            Donate to BabyQuest Foundation ↗
          </a>
          <Link
            href="/data"
            className="inline-flex items-center justify-center px-6 py-3 border-2 font-medium rounded-lg transition-colors text-sm hover:text-[#3bbfbe] hover:border-[#3bbfbe]"
            style={{ borderColor: BQ_CHARCOAL, color: BQ_CHARCOAL }}
          >
            Explore the data →
          </Link>
        </div>
      </section>

      {/* The numbers */}
      <section className="border-t border-[#e8e8e8] bg-[#f9f9f9]">
        <div className="max-w-4xl mx-auto px-6 py-14">
          <h2 className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-8">
            The scale of the problem
          </h2>
          <div className="grid md:grid-cols-3 gap-6">
            {STATS.map((s) => (
              <div
                key={s.label}
                className="rounded-xl border border-[#e8e8e8] bg-white p-6 shadow-sm"
              >
                <p className="text-4xl font-bold tabular-nums mb-2" style={{ color: s.hexColor }}>
                  {s.value}
                </p>
                <p className="text-sm font-semibold text-[#333333] mb-2">{s.label}</p>
                <p className="text-xs text-[#666666] leading-relaxed mb-3">{s.detail}</p>
                <p className="text-xs text-[#aaaaaa] font-mono">Source: {s.source}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Access gap */}
      <section className="max-w-4xl mx-auto px-6 py-14">
        <h2 className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-2">
          The access gap
        </h2>
        <p className="text-[#666666] mb-8 max-w-2xl">
          The same medical need produces very different outcomes depending on income, insurance, and
          zip code. That&apos;s not a medical problem — it&apos;s a policy problem.
        </p>
        <div className="grid md:grid-cols-3 gap-5">
          {ACCESS_FACTS.map((f) => (
            <div
              key={f.label}
              className="rounded-xl border border-[#e8e8e8] bg-white p-5 shadow-sm"
            >
              <p className="text-3xl font-bold text-[#333333] mb-2">{f.stat}</p>
              <p className="text-sm text-[#333333] font-medium mb-1">{f.label}</p>
              <p className="text-xs text-[#999999]">{f.detail}</p>
            </div>
          ))}
        </div>
      </section>

      {/* About BabyQuest */}
      <section className="border-t border-[#e8e8e8] bg-[#f9f9f9]">
        <div className="max-w-4xl mx-auto px-6 py-14 grid md:grid-cols-2 gap-12 items-start">
          <div>
            <h2 className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-4">
              About BabyQuest Foundation
            </h2>
            <p className="text-[#666666] leading-relaxed mb-4">
              BabyQuest Foundation is a 501(c)(3) nonprofit that provides IVF and fertility
              treatment grants to individuals and couples who cannot afford care. Founded by
              Pamela Cohen Hirsch, BabyQuest has helped hundreds of families build the families
              they&apos;ve dreamed of.
            </p>
            <p className="text-[#666666] leading-relaxed mb-6">
              Two grant cycles are offered each year — Spring (June deadline) and Fall (September
              deadline). Applications are reviewed on demonstrated financial need and medical
              eligibility.
            </p>
            <a
              href="https://babyquestfoundation.org"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-medium underline transition-opacity hover:opacity-80"
              style={{ color: BQ_BLUE }}
            >
              Learn more at babyquestfoundation.org ↗
            </a>
          </div>
          <div className="rounded-xl border border-[#e8e8e8] bg-white p-6 shadow-sm">
            <p className="text-xs font-semibold uppercase tracking-widest text-[#999999] mb-4">
              Grant cycles — 2026
            </p>
            <div className="space-y-4">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <span className="w-2 h-2 rounded-full" style={{ backgroundColor: BQ_BLUE }} />
                  <span className="text-sm font-semibold text-[#333333]">Spring 2026</span>
                  <span className="text-xs text-[#999999] ml-auto">Applications closed</span>
                </div>
                <p className="text-xs text-[#888888] pl-4">Deadline: June 8, 2026</p>
              </div>
              <div className="border-t border-[#e8e8e8] pt-4">
                <div className="flex items-center gap-2 mb-1">
                  <span className="w-2 h-2 rounded-full bg-[#cccccc]" />
                  <span className="text-sm font-semibold text-[#333333]">Fall 2026</span>
                  <span className="text-xs text-amber-600 ml-auto">Opens soon</span>
                </div>
                <p className="text-xs text-[#888888] pl-4">Deadline: September 10, 2026</p>
              </div>
            </div>
            <div className="mt-6 pt-4 border-t border-[#e8e8e8]">
              <a
                href="https://babyquestfoundation.org/donate"
                target="_blank"
                rel="noopener noreferrer"
                className="block w-full text-center px-5 py-2.5 text-white text-sm font-semibold rounded-lg transition-opacity hover:opacity-90"
                style={{ backgroundColor: BQ_BLUE }}
              >
                Support a grant recipient →
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-[#e8e8e8] max-w-4xl mx-auto px-6 py-8 text-xs text-[#aaaaaa]">
        <p>
          Built by Cody and Rochelle Thomas — BabyQuest Spring 2026 grant recipients — in support
          of{' '}
          <a
            href="https://babyquestfoundation.org"
            className="underline hover:text-[#3bbfbe] transition-colors"
          >
            BabyQuest Foundation
          </a>
          .
        </p>
        <p className="mt-1">
          Data: NCHS National Survey of Family Growth (2022–2023 and 2015–2019), RESOLVE, CDC ART
          Surveillance System.
        </p>
        <p className="mt-2">
          <Link href="/data" className="underline hover:text-[#3bbfbe] transition-colors">
            Research data →
          </Link>
        </p>
      </footer>
    </main>
  )
}
