# Baby Quest — Actionable To-Dos
Updated 2026-04-07

---

## Immediate (This Week — Cody handles personally)

- [ ] **Call/email Cassie Ferguson** — get her read on BabyQuest, DTFA parallels,
  what actually works for recipient story campaigns and recurring donor conversion
- [ ] **Email Pamela Cohen Hirsch** (bqfoundation@gmail.com) — introduce yourselves
  as active recipients, ask about ambassador program structure, surface the
  tournament idea, ask about preferred content channels

---

## Phase 1 — Content Foundation

- [ ] **Review and approve recipient story draft** — `content/recipient-story.md`
  - Ro should review and approve before anything is submitted
  - Adjust any details she wants changed
  - Once approved: submit to BabyQuest for their "recipient stories" feature

- [ ] **Create GitHub repo** — `CodyJThomas/baby-quest` (private)
  - Push this scaffold
  - Add to RoCo project tracker

- [ ] **Initialize Next.js web app** — `cd web && npx create-next-app@latest .`
  - Same stack as life-hub: TypeScript, Tailwind, App Router
  - Connect to Supabase `babyquest` schema

- [ ] **Create Supabase `babyquest` schema + core tables**
  - `grant_cycles` — deadline dates, funding gap, awards count
  - `content_calendar` — drafts, scheduled posts, campaign timing
  - `media_outreach` — journalist contacts, pitch status, publication targets
  - `events` — tournament, fundraisers, appearances
  - `fertility_stats` — research data for content and data storytelling

---

## Phase 2 — First Build (Post Pamela conversation)

- [ ] **Faceless video — IVF Access Gap**
  - Script: open with Ro's nanny narrative (narration, no face), pivot to national data,
    close with BabyQuest grant stats and donation CTA
  - Sources: CDC NASS, NCSL state mandate data, KFF health data
  - Format: 8–10 min YouTube + 60-sec Instagram Reels cut

- [ ] **Donor email sequence** (5 emails, Google Doc → BabyQuest)
  - Email 1: Recipient story intro + impact of $25/month
  - Email 2: The nanny narrative (Ro's story, most emotionally resonant)
  - Email 3: The data story (IVF access gap, state-by-state)
  - Email 4: The "no overhead" proof point (BabyQuest financials)
  - Email 5: Recurring gift ask

- [ ] **Local media pitch** (Cleveland Scene / Cleveland Magazine)
  - Angle: "Cleveland couple navigating IVF shares what it actually costs"
  - Ro's nanny narrative is the lede
  - Coordinate with Pamela before pitching so BabyQuest can amplify

---

## Phase 3 — Infrastructure

- [ ] **Grant cycle countdown microsite** — Next.js page, countdown to next
  deadline, current funding gap, single CTA, recipient story pull quote

- [ ] **Public impact dashboard** — grant counter, funding gap by cycle,
  state heat map of recipients; offer to BabyQuest as embeddable widget

- [ ] **Email capture landing page** — "Get notified when applications open"
  — top of the donor funnel; the email list is the long-term asset

---

## Phase 4 — Tournament (Summer 2026)

- [ ] Lock date and format with Razzles (pending Pamela's input on timing)
- [ ] Registration fee structure ($25/player or $100/team)
- [ ] Tournament sponsorship deck (1-page PDF — repurposed from corporate giving one-pager)
- [ ] Donation/registration landing page
- [ ] Local press pitch for the event

---

## Backlog

- See BACKLOG.md
