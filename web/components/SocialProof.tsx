import { EYEBROW } from '@/lib/styles'

const PLATFORM_LABELS: Record<string, string> = {
  facebook: 'Facebook',
  twitter: 'X (Twitter)',
  instagram: 'Instagram',
  copy: 'Link copies',
}

export default function SocialProof({
  totalViews,
  totalShares,
  sharesByPlatform,
}: {
  totalViews: number
  totalShares: number
  sharesByPlatform: Record<string, number>
}) {
  const platformEntries = Object.entries(sharesByPlatform).filter(([, count]) => count > 0)

  return (
    <div className="border-t border-b border-[#e8e8e8] bg-white py-6">
      <div className="max-w-4xl mx-auto px-4 md:px-6">
        <p className={`${EYEBROW} mb-4`}>Platform reach — live</p>
        <div className="flex flex-wrap gap-x-8 gap-y-3">
          <div className="text-center">
            <p className="text-xl font-bold text-[#333333]">{totalViews.toLocaleString()}</p>
            <p className="text-xs text-[#888888]">total page views</p>
          </div>
          <div className="text-center">
            <p className="text-xl font-bold text-[#333333]">{totalShares.toLocaleString()}</p>
            <p className="text-xs text-[#888888]">total shares</p>
          </div>
          {platformEntries.map(([platform, count]) => (
            <div key={platform} className="text-center">
              <p className="text-xl font-bold text-[#333333]">{count.toLocaleString()}</p>
              <p className="text-xs text-[#888888]">via {PLATFORM_LABELS[platform] ?? platform}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
