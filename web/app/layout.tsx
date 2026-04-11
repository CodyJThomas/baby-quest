import type { Metadata } from 'next'
import { Open_Sans, Geist_Mono } from 'next/font/google'
import Link from 'next/link'
import Image from 'next/image'
import { Analytics } from '@vercel/analytics/next'
import './globals.css'

const openSans = Open_Sans({
  variable: '--font-open-sans',
  subsets: ['latin'],
  weight: ['300', '400', '600', '700', '800'],
})

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
})

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://baby-quest.vercel.app'
const OG_IMAGE = `${SITE_URL}/Charitable-Giving.png`

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: 'BabyQuest — Fertility Access Platform',
    template: '%s | BabyQuest',
  },
  description:
    '1 in 8 couples face infertility. 85% pay out of pocket. Cody & Rochelle Thomas are Spring 2026 BabyQuest grant recipients — help fund the next family.',
  keywords: ['BabyQuest', 'IVF', 'infertility', 'fertility grant', 'IVF funding', 'donate IVF', 'fertility access'],
  authors: [{ name: 'Cody & Rochelle Thomas' }],
  openGraph: {
    type: 'website',
    url: SITE_URL,
    siteName: 'BabyQuest Fertility Access Platform',
    title: '1 in 8 couples face infertility. Help fund the next family.',
    description:
      '85% of IVF costs are paid out of pocket. Cody & Rochelle Thomas are Spring 2026 BabyQuest grant recipients building awareness for fertility access. Donate today.',
    images: [{ url: OG_IMAGE, width: 1200, height: 630, alt: 'BabyQuest Foundation — Charitable Giving' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: '1 in 8 couples face infertility. Help fund the next family.',
    description:
      '85% of IVF costs are paid out of pocket. BabyQuest grants change lives — donate today.',
    images: [OG_IMAGE],
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html
      lang="en"
      className={`${openSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-white text-[#666666]">
        <nav className="border-b border-[#e8e8e8] px-6 py-3 flex items-center justify-between sticky top-0 bg-white/95 backdrop-blur z-10 shadow-sm">
          <Link href="/" className="flex items-center gap-3">
            <Image src="/babyquest-white-background.jpg" alt="BabyQuest Foundation" width={120} height={40} className="object-contain" />
            <span className="hidden sm:inline text-xs text-[#999999] font-normal">Fertility Access Platform</span>
          </Link>
          <div className="flex items-center gap-5">
            <Link
              href="/our-story"
              className="text-xs text-[#666666] hover:text-[#3bbfbe] transition-colors font-medium py-2 px-1"
            >
              Our Story
            </Link>
            <Link
              href="/data"
              className="text-xs text-[#666666] hover:text-[#3bbfbe] transition-colors font-medium py-2 px-1"
            >
              Research Data
            </Link>
            <a
              href="https://babyquestfoundation.org/donate"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs px-4 py-2.5 text-white font-semibold rounded-md transition-opacity hover:opacity-90"
              style={{ backgroundColor: '#3bbfbe' }}
            >
              Donate ↗
            </a>
          </div>
        </nav>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
