import type { Metadata } from 'next'
import Link from 'next/link'
import EmailCapture from '@/components/EmailCapture'
import ShareButtons from '@/components/ShareButtons'
import PageViewTracker from '@/components/PageViewTracker'

import { EYEBROW } from '@/lib/styles'

const BQ_TEAL = '#3bbfbe'

export const metadata: Metadata = {
  title: 'Our Story | BabyQuest',
  description:
    "Cody and Rochelle Thomas's fertility journey — four IUI cycles, a miscarriage, and how BabyQuest Foundation made IVF possible for a family that refused to give up.",
}

export default function OurStoryPage() {
  return (
    <main className="min-h-screen bg-white text-[#666666]">

      {/* Our story — Rochelle & Cody */}
      <section className="max-w-4xl mx-auto px-4 md:px-6 pt-16 pb-14 md:pt-24">
        <p className={`${EYEBROW} mb-3`}>Our story</p>
        <h1 className="text-3xl md:text-4xl font-bold text-[#333333] mb-10">
          Rochelle &amp; Cody Thomas
        </h1>
        <div className="grid md:grid-cols-2 gap-10 items-start">
          <div>
            <p className="text-[#666666] leading-relaxed mb-4">
              Over the past twelve years, Rochelle has helped raise several children as a nanny —
              celebrating first steps, comforting scraped knees, watching them grow. Few things
              bring her more joy than guiding children through those early years. Yet each time
              she leaves for the day, she carries the same quiet hope: that one day she and Cody
              will experience those moments with a child of their own.
            </p>
            <p className="text-[#666666] leading-relaxed mb-4">
              We are grounded in love, purpose, and a shared vision for the family we hope to
              build. Our relationship is built on trust, laughter, and deep respect. Like many
              couples facing infertility, we have experienced uncertainty and heartbreak — but
              those experiences have only strengthened our commitment to each other and to this dream.
            </p>
            <p className="text-[#666666] leading-relaxed mb-6">
              On April 6, 2026, we found out we had been selected as Spring 2026 BabyQuest grant
              recipients. We sat with that news for a long time before we knew what to say. What
              we keep coming back to is this: there are people who built this foundation so that
              couples like us would not have to choose between starting a family and financial
              security. We want more people to know that.
            </p>
            <p className="text-sm font-medium italic" style={{ color: BQ_TEAL }}>
              &ldquo;There are other Rochelles and Codys out there — people sitting with the same
              quiet hope, running the same impossible math, wondering whether this dream is still
              within reach. BabyQuest exists because of donors who decided that it should be.&rdquo;
            </p>
            <p className="text-xs text-[#aaaaaa] mt-2">— Rochelle &amp; Cody Thomas, Lakewood, Ohio</p>
          </div>
          <div className="rounded-xl border border-[#e8e8e8] bg-[#f9f9f9] p-6 shadow-sm space-y-4">
            <p className={EYEBROW}>Grant recipients include</p>
            {[
              'Military veterans denied fertility coverage',
              'Cancer survivors facing donor eggs or gestational surrogacy',
              'Same-sex couples told they could never have a family',
              'Couples who remortgaged their homes on failed procedures',
              'Singles pursuing parenthood on their own',
            ].map((item) => (
              <div key={item} className="flex items-start gap-3">
                <span
                  className="mt-0.5 w-5 h-5 rounded-full flex items-center justify-center shrink-0 text-white text-xs font-bold"
                  style={{ backgroundColor: BQ_TEAL }}
                >
                  ✓
                </span>
                <p className="text-sm text-[#666666]">{item}</p>
              </div>
            ))}
            <div className="pt-2 border-t border-[#e8e8e8] text-xs text-[#595959]">
              All orientations, backgrounds, and family structures welcome.
              Grants do not require repayment.
            </div>
            <a
              href="https://babyquestfoundation.org/donate"
              target="_blank"
              rel="noopener noreferrer"
              className="block w-full text-center px-5 py-3 text-white text-sm font-semibold rounded-lg transition-opacity hover:opacity-90 mt-2"
              style={{ backgroundColor: BQ_TEAL }}
            >
              Support the next grant recipient →
            </a>
          </div>
        </div>
      </section>

      {/* Share */}
      <section className="max-w-4xl mx-auto px-4 md:px-6 pb-6">
        <div className="mb-10">
          <p className="text-sm text-[#666666] mb-3">
            If this story resonates with you, please share it.
          </p>
          <ShareButtons
            sourcePage="/our-story"
            shareUrl="https://baby-quest.vercel.app/our-story"
            shareText="Read Cody and Rochelle's fertility journey — and how BabyQuest Foundation made IVF possible for a family that refused to give up."
          />
        </div>
      </section>

      {/* Our fertility journey — IUI timeline */}
      <section className="border-t border-[#e8e8e8] bg-[#f9f9f9]">
        <div className="max-w-4xl mx-auto px-4 md:px-6 py-14">
          <p className={`${EYEBROW} mb-3`}>Our fertility journey</p>
          <h2 className="text-2xl md:text-3xl font-bold text-[#333333] mb-3">
            What four failed IUI cycles actually feel like
          </h2>
          <p className="text-[#666666] mb-10 max-w-2xl">
            IUI (intrauterine insemination) is the step most couples try before IVF. It&apos;s less invasive,
            less expensive — and for most people, it doesn&apos;t work. Here&apos;s our honest account.
          </p>

          {/* Timeline */}
          <div className="relative border-l-2 border-[#e8e8e8] ml-4 space-y-0">
            {[
              {
                label: 'Cycle 1 — Triggered IUI',
                color: '#d97706',
                outcome: 'No pregnancy',
                detail:
                  'Trigger shot administered. Timed perfectly. We waited the two weeks with cautious optimism. Negative.',
                stat: 'IUI success rate per cycle: 10–20%. Most couples need multiple attempts — if it works at all.',
              },
              {
                label: 'Cycle 2 — Triggered IUI',
                color: '#d97706',
                outcome: 'No pregnancy',
                detail:
                  'Second attempt. Same protocol, same hope, same result. The math was starting to feel personal.',
                stat: 'After 2 failed IUI cycles, cumulative success is still only ~30–40% for ideal candidates.',
              },
              {
                label: 'Cycle 3 — Conception',
                color: '#3bbfbe',
                outcome: 'Pregnant — then lost at 6 weeks',
                detail:
                  'It worked. For the first time, a positive test. We let ourselves feel it. At six weeks, we lost the pregnancy. A miscarriage after fertility treatment is a specific kind of grief — you fought to get here, and then it was gone.',
                stat: '15–25% of clinically confirmed pregnancies end in miscarriage. The rate is higher after fertility treatments. You are not alone.',
                highlight: true,
              },
              {
                label: 'Cycle 4 — The zombie cycle',
                color: '#888888',
                outcome: 'No pregnancy → pivot to IVF',
                detail:
                  'We went through the motions. The grief from cycle 3 hadn\'t lifted. We were exhausted and not fully present. Negative again — and honestly, by then we already knew IVF was next. We needed the break more than the cycle.',
                stat: 'Emotional burnout is a documented barrier to fertility treatment completion. "Zombie cycles" — going through the process without hope — are more common than providers acknowledge.',
              },
            ].map((step, i) => (
              <div key={i} className="pl-8 pb-10 relative">
                <div
                  className="absolute -left-[9px] top-1 w-4 h-4 rounded-full border-2 border-white"
                  style={{ backgroundColor: step.color }}
                />
                <div className={`rounded-xl border p-5 shadow-sm ${step.highlight ? 'border-[#3bbfbe]/30 bg-white' : 'border-[#e8e8e8] bg-white'}`}>
                  <div className="flex items-start justify-between gap-3 mb-2 flex-wrap">
                    <p className="text-xs font-semibold uppercase tracking-widest" style={{ color: step.color }}>
                      {step.label}
                    </p>
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                      step.highlight
                        ? 'bg-red-50 text-red-700 border border-red-200'
                        : step.color === '#888888'
                        ? 'bg-gray-100 text-[#888888] border border-[#e8e8e8]'
                        : 'bg-orange-50 text-orange-700 border border-orange-200'
                    }`}>
                      {step.outcome}
                    </span>
                  </div>
                  <p className="text-sm text-[#333333] leading-relaxed mb-3">{step.detail}</p>
                  <p className="text-xs text-[#595959] bg-[#f9f9f9] rounded-lg px-3 py-2 border border-[#e8e8e8]">
                    📊 {step.stat}
                  </p>
                </div>
              </div>
            ))}
          </div>

          {/* IUI stats callout */}
          <div className="rounded-xl border border-[#e8e8e8] bg-white p-6 shadow-sm mt-2">
            <p className={`${EYEBROW} mb-4`}>The IUI reality — by the numbers</p>
            <div className="grid sm:grid-cols-3 gap-5">
              {[
                { value: '10–20%', label: 'Success rate per IUI cycle', color: '#d97706' },
                { value: '~$2,000', label: 'Cost per IUI cycle', color: BQ_TEAL },
                { value: '15–25%', label: 'Miscarriage rate after IUI conception', color: '#dc2626' },
              ].map((s) => (
                <div key={s.label} className="text-center">
                  <p className="text-3xl font-bold mb-1" style={{ color: s.color }}>{s.value}</p>
                  <p className="text-xs text-[#595959]">{s.label}</p>
                </div>
              ))}
            </div>
            <p className="text-xs text-[#aaaaaa] text-center mt-4 font-mono">
              Sources: NCHS, SART, ACOG clinical guidelines
            </p>
          </div>
        </div>
      </section>

      {/* Email capture */}
      <section className="max-w-4xl mx-auto px-4 md:px-6 py-14">
        <div className="grid md:grid-cols-2 gap-10 items-start">
          <div>
            <p className={`${EYEBROW} mb-3`}>Follow along</p>
            <h2 className="text-2xl font-bold text-[#333333] mb-4">
              Stay in the loop
            </h2>
            <p className="text-[#666666] leading-relaxed mb-4">
              We&apos;ll share updates on our IVF journey, grant cycle announcements,
              and data-driven posts about the fertility access gap. No spam — just the
              content that matters.
            </p>
            <p className="text-[#666666] leading-relaxed">
              If our story resonates with you — whether you&apos;re facing infertility yourself,
              or you want to help someone who is — join us.
            </p>
          </div>
          <EmailCapture sourcePage="/our-story" />
        </div>
      </section>

      {/* Donate CTA */}
      <section className="border-t border-[#e8e8e8] bg-[#f9f9f9]">
        <div className="max-w-4xl mx-auto px-4 md:px-6 py-14 text-center">
          <p className={`${EYEBROW} mb-3`}>Make a difference</p>
          <h2 className="text-2xl md:text-3xl font-bold text-[#333333] mb-4">
            Help fund the next family.
          </h2>
          <p className="text-[#666666] leading-relaxed mb-8 max-w-xl mx-auto">
            Every donation directly funds a grant for someone who has exhausted every other
            option. No repayment required. No discrimination. Just hope — made possible by
            people like you.
          </p>
          <a
            href="https://babyquestfoundation.org/donate"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center px-8 py-3.5 text-white font-semibold rounded-lg transition-opacity hover:opacity-90 text-base"
            style={{ backgroundColor: BQ_TEAL }}
          >
            Donate to BabyQuest Foundation ↗
          </a>
        </div>
      </section>

      <PageViewTracker page="/our-story" />

      {/* Footer */}
      <footer className="border-t border-[#e8e8e8] max-w-4xl mx-auto px-4 md:px-6 py-8 text-xs text-[#aaaaaa]">
        <p>
          Built by Cody and Rochelle Thomas — BabyQuest Spring 2026 grant recipients — in support of{' '}
          <a href="https://babyquestfoundation.org" className="underline hover:text-[#3bbfbe] transition-colors">
            BabyQuest Foundation
          </a>.
        </p>
        <p className="mt-4 flex gap-4">
          <Link href="/" className="underline hover:text-[#3bbfbe] transition-colors">
            ← Home
          </Link>
          <Link href="/data" className="underline hover:text-[#3bbfbe] transition-colors">
            Research data →
          </Link>
        </p>
      </footer>
    </main>
  )
}
