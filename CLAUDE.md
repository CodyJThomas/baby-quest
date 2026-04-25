# Baby Quest — Claude Code Context
# Read this at the start of every session.

## About this project
This repo is a RoCo Enterprises initiative supporting BabyQuest Foundation —
a 501(c)(3) that provides IVF and fertility treatment grants to couples and
individuals who cannot afford treatment.

Cody and Rochelle Thomas are Spring 2026 BabyQuest grant recipients.
BabyQuest asked recipients to help advance the Foundation's mission.
This repo is how we do that systematically.

## People

### Us
- Cody Thomas — tech, data, strategy, infrastructure
- Rochelle (Ro) Thomas — personal brand, fertility journey content, influencer lane
- Cassie Ferguson (Cody's sister) — nonprofit marketing/communications advisor;
  works at Dave Thomas Foundation for Adoption; LinkedIn: linkedin.com/in/casolga/

### BabyQuest
- Pamela Cohen Hirsch — Founder, bqfoundation@gmail.com, 323-206-6088
- Website: babyquestfoundation.org
- Instagram: @babyquestgrants (24K followers)
- Two grant cycles/year: Spring (June 8 deadline) / Fall (Sept 10 deadline)

## Local paths
- This repo: `/home/codyj/baby-quest`
- Source materials: `/home/codyj/baby-quest/content/` (essays, drafts, recipient story)
- Life Hub: `/home/codyj/life-hub` (command center — Supabase, Vercel, agent fleet)

## Supabase
- Same Supabase project as life-hub and research-hub
- Schema: `babyquest`
- Do NOT touch `personal`, `crm`, or `volleyball` schemas unless explicitly asked

## Stack
- Web app: Next.js (web/) + Vercel
- Database: Supabase (`babyquest` schema)
- Scripts: Node.js (scripts/)
- Content: Markdown drafts (content/)
- Data: Research CSVs and JSON (data/)

## Our three lanes of work

### 1. Awareness (Ro's lane + faceless content)
- Ro's fertility journey content — Instagram-native, her pace, her comfort level
- Faceless video — data storytelling, their story as narration (no talking head)
- Written content — recipient story, press pitches, submitted articles

### 2. Fundraising (events + campaigns)
- Volleyball tournament at Razzles (summer 2026 — date TBD pending Pamela)
- Grant cycle campaigns — awareness builds 4–6 weeks before each deadline
- Corporate sponsorship outreach (tournament + general giving)

### 3. Infrastructure (Cody's lane)
- Grant cycle countdown microsite
- Public impact dashboard (grant counter, funding gap, state heat map)
- Donor email sequences
- Fertility statistics research pipeline
- Email capture list — the long-term asset

## Content posture
- Story-forward, face-optional
- Their personal narrative is the engine; data is the supporting evidence
- Ro controls her own content — never push, always support
- No on-camera YouTube or TV appearances without explicit consent
- Written press outreach: pitch story TO journalist, don't go on camera

## Optics
- They could afford IVF without the grant — the grant removes debt burden
- Ireland trip (June 17–30, 2026) is a separate matter, not discussed publicly
- Framing: "BabyQuest made this possible without financial hardship — and we want
  more people to know this resource exists."

## Core principles
- Build for real use, not hypothetical scale
- Cassie's input shapes major decisions — consult before building donor infrastructure
- Pamela's guidance shapes event timing and ambassador scope
- Content > code until the audience exists

## Agent routing
Sessions run from roco-hub (`/home/codyj/roco-hub`). Agents for this project are defined there.

| Trigger | Agent |
|---|---|
| fertility stats, research data, CDC/NCSL data | `bq-researcher` |
| web ingest — state mandates, insurance coverage | `bq-web-ingester` |
| stat file parsing — CDC NASS, SART, NCHS | `bq-stat-ingester` |
| social copy, email drafts, content drafts | main Claude (no dedicated agent yet) |
| tournament planning, donor ops | main Claude (no dedicated agent yet) |

## Workflow
- Prefer small, shippable pieces
- Keep content/ drafts in sync with what's been submitted/published
- Log all media outreach in `babyquest.media_outreach` table
