import type { Metadata } from 'next'
import { Open_Sans, Geist_Mono } from 'next/font/google'
import Link from 'next/link'
import Image from 'next/image'
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

export const metadata: Metadata = {
  title: 'BabyQuest — Fertility Access Platform',
  description:
    'Built by Cody and Rochelle Thomas, Spring 2026 BabyQuest grant recipients. Fertility access data, policy research, and advocacy in support of BabyQuest Foundation.',
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
            <Image src="/babyquest-logo.png" alt="BabyQuest Foundation" width={140} height={44} className="rounded" />
            <span className="hidden sm:inline text-xs text-[#999999] font-normal">Fertility Access Platform</span>
          </Link>
          <div className="flex items-center gap-5">
            <Link
              href="/data"
              className="text-xs text-[#666666] hover:text-[#3bbfbe] transition-colors font-medium"
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
      </body>
    </html>
  )
}
