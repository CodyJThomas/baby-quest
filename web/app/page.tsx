import Link from 'next/link'
import Image from 'next/image'
import EmailCapture from '@/components/EmailCapture'
import FundraisingBar from '@/components/FundraisingBar'
import ShareButtons from '@/components/ShareButtons'
import SocialProof from '@/components/SocialProof'
import PageViewTracker from '@/components/PageViewTracker'
import { createServiceClient } from '@/lib/supabase'
import { EYEBROW } from '@/lib/styles'

const BQ_TEAL = '#3bbfbe'
const BQ_CHARCOAL = '#32373c'

const STATS = [
  {
    value: '1 in 8',
    label: 'Couples have trouble getting or sustaining a pregnancy',
    source: 'NCHS, 2015–2019 / BabyQuest Foundation',
    hexColor: BQ_TEAL,
    detail: '9.7 million women ages 15–49 have impaired fecundity.',
  },
  {
    value: '85%',
    label: 'Of IVF costs are paid out of pocket',
    source: 'BabyQuest Foundation',
    hexColor: '#d97706',
    detail: 'Lack of insurance coverage forces most families to self-fund every cycle.',
  },
  {
    value: '$16,000+',
    label: 'Per IVF cycle — plus $5,000 in medications',
    source: 'BabyQuest Foundation',
    hexColor: '#dc2626',
    detail: 'With no guarantee of success on the first round, costs compound quickly.',
    compact: true,
  },
  {
    value: '30%',
    label: 'Of infertility cases involve male factors',
    source: 'BabyQuest Foundation / NCHS',
    hexColor: BQ_CHARCOAL,
    detail: 'Low sperm count and other male factors are a primary — and often overlooked — cause.',
  },
]

const IMPACT = [
  { value: '250+', label: 'Grants awarded', sub: 'since March 2012' },
  { value: '$3.9M', label: 'Awarded in cash & equivalents', sub: 'including negotiated discounts & waived fees' },
  { value: '215+', label: 'Babies born across the U.S.', sub: '+ 11 pregnancies at time of publication' },
]

const GIVING_TIERS = [
  {
    name: 'The Giving Hope Grant',
    minimum: '$12,000',
    period: 'one-time gift',
    perks: [
      "Establish a named grant in your company's honor",
      'Final approval in recipient selection',
      'Logo on all social media promotions',
      'Minimum 4 social media acknowledgments',
    ],
  },
  {
    name: 'Monthly Contribution',
    minimum: '$300/mo',
    period: '$3,600/year minimum',
    perks: [
      'Monthly donation acknowledged on social media',
      'Logo included with recipient photo updates',
      'Tangible visibility into grant impact',
    ],
  },
  {
    name: 'Special Day or Month',
    minimum: '$500',
    period: 'one-time gift',
    perks: [
      'Designate a BabyQuest day, week, or month',
      'Portion of proceeds directed to BabyQuest',
      'Logo + tribute on social media',
      "Ideal for NIAW or Mother's Day month (May)",
    ],
  },
]

const MEDIA = [
  'The View', 'Today Show', 'Good Morning America',
  'Tamron Hall Show', 'New York Times', 'Nasdaq', 'HuffPost',
]

export const dynamic = 'force-dynamic'

async function getSiteStats() {
  const supabase = createServiceClient()
  const [{ count: views }, { data: shares }, { data: config }] = await Promise.all([
    supabase.schema('babyquest').from('page_views').select('*', { count: 'exact', head: true }),
    supabase.schema('babyquest').from('share_events').select('platform'),
    supabase.schema('babyquest').from('fundraising_config').select('*').single(),
  ])
  const sharesByPlatform = (shares ?? []).reduce((acc: Record<string, number>, row: { platform: string }) => {
    acc[row.platform] = (acc[row.platform] ?? 0) + 1
    return acc
  }, {})
  return {
    totalViews: views ?? 0,
    totalShares: (shares ?? []).length,
    sharesByPlatform,
    fundraising: config,
  }
}

export default async function LandingPage() {
  const stats = await getSiteStats()

  return (
    <main className="min-h-screen bg-white text-[#666666]">

      {/* Hero */}
      <section className="max-w-4xl mx-auto px-4 md:px-6 pt-16 pb-10 md:pt-24 md:pb-16">
        <p className={`${EYEBROW} mb-6`}>
          BabyQuest Foundation — Spring 2026 Grant Recipients
        </p>
        <h1 className="text-4xl md:text-6xl font-bold leading-tight tracking-tight mb-6 text-[#333333]">
          If babies could talk,<br />
          <span style={{ color: BQ_TEAL }}>they&apos;d tell you the truth.</span>
        </h1>
        <p className="text-base md:text-lg text-[#666666] max-w-2xl leading-relaxed mb-4">
          Military veterans. Cancer survivors. Same-sex couples. People who&apos;ve spent everything
          on failed procedures. These are BabyQuest grant recipients — and their only obstacle
          was money.
        </p>
        <p className="text-base md:text-lg text-[#666666] max-w-2xl leading-relaxed mb-8">
          We built this platform to help more people find the Foundation — and to show the human
          cost of a system that leaves families behind.
        </p>
        <div className="flex flex-col sm:flex-row gap-4 mb-5">
          <a
            href="https://babyquestfoundation.org/donate"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto inline-flex items-center justify-center px-6 py-3.5 text-white font-semibold rounded-lg transition-opacity hover:opacity-90 text-base"
            style={{ backgroundColor: BQ_TEAL }}
          >
            Donate to BabyQuest Foundation ↗
          </a>
          <Link
            href="/data"
            className="w-full sm:w-auto inline-flex items-center justify-center px-6 py-3.5 border-2 font-medium rounded-lg transition-colors text-base hover:text-[#3bbfbe] hover:border-[#3bbfbe]"
            style={{ borderColor: BQ_CHARCOAL, color: BQ_CHARCOAL }}
          >
            Explore the data →
          </Link>
        </div>
        <div className="mt-6">
          <ShareButtons
            sourcePage="/"
            shareUrl={process.env.NEXT_PUBLIC_SITE_URL ?? 'https://baby-quest-roco.vercel.app'}
            shareText="1 in 8 couples face infertility. 85% pay out of pocket. Learn how BabyQuest Foundation is changing that."
          />
        </div>
        <Link
          href="/our-story"
          className="text-sm font-medium transition-colors hover:opacity-80 block mt-3"
          style={{ color: BQ_TEAL }}
        >
          Read our story →
        </Link>
      </section>

      {/* Fundraising bar */}
      <section className="bg-[#f9f9f9] border-t border-[#e8e8e8]">
        <div className="max-w-4xl mx-auto px-4 md:px-6 py-10">
          <FundraisingBar
            goalAmount={Number(stats.fundraising?.goal_amount ?? 5000)}
            currentAmount={Number(stats.fundraising?.current_amount ?? 0)}
            label={stats.fundraising?.label ?? "Cody & Rochelle's Spring 2026 Goal"}
          />
        </div>
      </section>

      {/* Impact bar */}
      <section style={{ backgroundColor: BQ_TEAL }}>
        <div className="max-w-4xl mx-auto px-4 md:px-6 py-12">
          <p className="text-sm text-white/80 font-semibold uppercase tracking-widest text-center mb-8">
            BabyQuest Foundation impact
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 md:gap-8">
            {IMPACT.map((item, idx) => (
              <div key={item.label} className={`text-center ${idx < IMPACT.length - 1 ? 'sm:border-r sm:border-white/20' : ''}`}>
                <p className="text-4xl md:text-5xl font-bold text-white mb-1">{item.value}</p>
                <p className="text-xs md:text-sm font-semibold text-white mb-1">{item.label}</p>
                <p className="text-xs text-white/70">{item.sub}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Brutal facts */}
      <section className="border-t border-[#e8e8e8] bg-[#f9f9f9]">
        <div className="max-w-4xl mx-auto px-4 md:px-6 py-14">
          <p className={`${EYEBROW} mb-3`}>The financial reality</p>
          <h2 className="text-2xl md:text-3xl font-bold text-[#333333] mb-3">
            Brutal fertility facts
          </h2>
          <p className="text-[#666666] mb-10 max-w-2xl">
            Infertility is common. Affordable treatment is not. The numbers explain why BabyQuest exists.
          </p>
          <div className="grid sm:grid-cols-2 md:grid-cols-4 gap-5">
            {STATS.map((s) => (
              <div key={s.label} className="rounded-xl border border-[#e8e8e8] bg-white p-6 shadow-sm">
                <p className={`${'compact' in s && s.compact ? 'text-3xl md:text-4xl' : 'text-4xl md:text-5xl'} font-bold tabular-nums mb-2`} style={{ color: s.hexColor }}>
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

      {/* About BabyQuest */}
      <section className="border-t border-[#e8e8e8] bg-[#f9f9f9]">
        <div className="max-w-4xl mx-auto px-4 md:px-6 py-14 grid md:grid-cols-2 gap-12 items-start">
          <div>
            <p className={`${EYEBROW} mb-3`}>About BabyQuest Foundation</p>
            <h2 className="text-2xl font-bold text-[#333333] mb-4">
              Making the dream of parenthood come true
            </h2>
            <p className="text-[#666666] leading-relaxed mb-4">
              BabyQuest Foundation is a 501(c)(3) nonprofit that provides financial assistance
              for IVF, gestational surrogacy, egg and sperm donation, egg freezing, and embryo
              donation — to anyone who cannot afford the high cost of care.
            </p>
            <p className="text-[#666666] leading-relaxed mb-6">
              Founded by Pamela Cohen Hirsch after witnessing her daughter Nicole&apos;s
              fertility journey, BabyQuest has awarded 250+ grants and helped bring 215+ babies
              into the world since 2012.
            </p>
            <blockquote className="border-l-4 pl-4 mb-6" style={{ borderColor: BQ_TEAL }}>
              <p className="text-base italic text-[#666666]">
                &ldquo;I simply cannot imagine the pain and frustration a couple experiences knowing
                there is a medical solution for infertility and yet not being able to afford it.&rdquo;
              </p>
              <footer className="mt-3 text-xs text-[#595959] not-italic">
                — Pamela Cohen Hirsch, Founder
              </footer>
            </blockquote>
            <a
              href="https://babyquestfoundation.org"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-semibold underline transition-opacity hover:opacity-80"
              style={{ color: BQ_TEAL }}
            >
              Learn more at babyquestfoundation.org ↗
            </a>
          </div>
          <div className="rounded-xl border border-[#e8e8e8] bg-white p-6 shadow-sm">
            <p className={`${EYEBROW} mb-4`}>Grant cycles — 2026</p>
            <div className="space-y-4">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <span className="w-2 h-2 rounded-full" style={{ backgroundColor: BQ_TEAL }} />
                  <span className="text-sm font-semibold text-[#333333]">Spring 2026</span>
                  <span className="text-xs text-[#595959] ml-auto">Applications closed</span>
                </div>
                <p className="text-xs text-[#888888] pl-4">Deadline: June 8, 2026</p>
              </div>
              <div className="border-t border-[#e8e8e8] pt-4">
                <div className="flex items-center gap-2 mb-1">
                  <span className="w-2 h-2 rounded-full bg-[#cccccc]" />
                  <span className="text-sm font-semibold text-[#333333]">Fall 2026</span>
                  <span className="text-xs ml-auto" style={{ color: '#d97706' }}>Opens soon</span>
                </div>
                <p className="text-xs text-[#888888] pl-4">Deadline: September 10, 2026</p>
              </div>
            </div>
            <div className="mt-6 pt-4 border-t border-[#e8e8e8]">
              <a
                href="https://babyquestfoundation.org/donate"
                target="_blank"
                rel="noopener noreferrer"
                className="block w-full text-center px-5 py-3 text-white text-sm font-semibold rounded-lg transition-opacity hover:opacity-90"
                style={{ backgroundColor: BQ_TEAL }}
              >
                Support a grant recipient →
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Corporate giving */}
      <section className="max-w-4xl mx-auto px-4 md:px-6 py-14">
        <p className={`${EYEBROW} mb-3`}>Corporate &amp; organizational giving</p>
        <h2 className="text-2xl font-bold text-[#333333] mb-3">
          Three ways to partner with BabyQuest
        </h2>
        <p className="text-[#666666] mb-10 max-w-2xl">
          Each tier comes with social media recognition and direct visibility into the families
          your contribution helps create.
        </p>
        <div className="grid md:grid-cols-3 gap-5">
          {GIVING_TIERS.map((tier) => (
            <div key={tier.name} className="rounded-xl border border-[#e8e8e8] bg-white p-6 shadow-sm flex flex-col">
              <p className={`${EYEBROW} mb-2`}>{tier.period}</p>
              <p className="text-lg font-bold text-[#333333] mb-1">{tier.name}</p>
              <p className="text-3xl font-bold mb-5" style={{ color: BQ_TEAL }}>{tier.minimum}</p>
              <ul className="space-y-2.5 flex-1">
                {tier.perks.map((perk) => (
                  <li key={perk} className="flex items-start gap-2 text-sm text-[#666666]">
                    <span className="shrink-0 mt-0.5 font-bold" style={{ color: BQ_TEAL }}>✓</span>
                    {perk}
                  </li>
                ))}
              </ul>
              <div className="mt-6 pt-4 border-t border-[#e8e8e8]">
                <a
                  href="mailto:bqfoundation@gmail.com"
                  className="block text-center px-4 py-3 text-sm font-semibold text-white rounded-lg transition-opacity hover:opacity-90"
                  style={{ backgroundColor: BQ_TEAL }}
                >
                  Get in touch →
                </a>
                <p className="text-center text-xs text-[#aaaaaa] mt-2">bqfoundation@gmail.com</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Media coverage */}
      <section className="border-t border-[#e8e8e8] bg-[#f9f9f9]">
        <div className="max-w-4xl mx-auto px-4 md:px-6 py-10">
          <p className={`${EYEBROW} text-center mb-8`}>As seen in</p>
          <div className="flex flex-wrap justify-center gap-x-8 gap-y-3">
            {MEDIA.map((outlet) => (
              <span key={outlet} className="text-sm font-bold text-[#888888]">{outlet}</span>
            ))}
          </div>
        </div>
      </section>

      {/* Social proof — only shown once shares exist */}
      {stats.totalShares > 0 && (
        <SocialProof
          totalViews={stats.totalViews}
          totalShares={stats.totalShares}
          sharesByPlatform={stats.sharesByPlatform}
        />
      )}

      {/* Email capture */}
      <section className="max-w-4xl mx-auto px-4 md:px-6 py-14">
        <div className="grid md:grid-cols-2 gap-10 items-start">
          <div>
            <p className={`${EYEBROW} mb-3`}>Follow along</p>
            <h2 className="text-2xl font-bold text-[#333333] mb-4">
              Stay in the loop
            </h2>
            <p className="text-[#666666] leading-relaxed mb-4">
              We&apos;ll share updates on grant cycle announcements, fertility access news,
              and data-driven posts about the cost gap. No spam — just the content that matters.
            </p>
            <p className="text-[#666666] leading-relaxed">
              If you want to help — or you&apos;re facing infertility yourself — join us.
            </p>
          </div>
          <EmailCapture sourcePage="/" />
        </div>
      </section>

      {/* Final CTA */}
      <section className="max-w-4xl mx-auto px-4 md:px-6 py-14 flex flex-col md:flex-row items-center gap-10">
        <div className="shrink-0">
          <Image
            src="/Charitable-Giving.png"
            alt=""
            width={200}
            height={150}
            className="object-contain"
          />
        </div>
        <div>
          <h2 className="text-2xl md:text-3xl font-bold text-[#333333] mb-3">
            Let&apos;s create life together.
          </h2>
          <p className="text-[#666666] leading-relaxed mb-6">
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
            Donate today ↗
          </a>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-[#e8e8e8] max-w-4xl mx-auto px-4 md:px-6 py-8 text-xs text-[#aaaaaa]">
        <p>
          Built by Cody and Rochelle Thomas — BabyQuest Spring 2026 grant recipients — in support of{' '}
          <a href="https://babyquestfoundation.org" className="underline hover:text-[#3bbfbe] transition-colors">
            BabyQuest Foundation
          </a>.
        </p>
        <p className="mt-2 leading-relaxed">
          Data: NCHS National Survey of Family Growth (2022–2023 and 2015–2019), RESOLVE, BabyQuest Foundation.
        </p>
        <p className="mt-4 flex gap-4">
          <Link href="/our-story" className="underline hover:text-[#3bbfbe] transition-colors">
            Our story →
          </Link>
          <Link href="/data" className="underline hover:text-[#3bbfbe] transition-colors">
            Research data →
          </Link>
        </p>
      </footer>

      <PageViewTracker page="/" />
    </main>
  )
}
