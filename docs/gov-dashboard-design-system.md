---
name: VETRA Government Dashboard
description: Unified digital surveillance, early warning, and epidemiological intelligence dashboard for government veterinary and animal husbandry officers.
platform: Web / Desktop
colors:
  nav-bg: '#0E1A2B'
  nav-text: '#9FB1C4'
  nav-text-active: '#F4F7FA'
  workspace-bg: '#F6F8FA'
  surface: '#FFFFFF'
  border: '#E1E6EC'
  border-strong: '#C7D0DB'
  text-primary: '#101826'
  text-secondary: '#526074'
  text-muted: '#93A1B0'
  accent: '#1E5C97'
  accent-hover: '#164A7C'
  accent-subtle: '#E4EDF6'
  risk-severe: '#6E1423'
  risk-critical: '#B7301F'
  risk-high: '#D97B1F'
  risk-moderate: '#C9A227'
  risk-minimal: '#3E7C4A'
  case-confirmed: '#B7301F'
  case-suspected: '#D97B1F'
  vaccination-gap: '#B7301F'
  vaccination-ok: '#3E7C4A'
typography:
  page-title:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  section-header:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  panel-label:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  body:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  table-text:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  table-numeric:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  risk-score:
    fontFamily: JetBrains Mono
    fontSize: 30px
    fontWeight: '500'
    lineHeight: 36px
  data-metadata:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 2px
  md: 4px
  lg: 6px
---

# VETRA Government Dashboard — Design System

Companion reference to `vetra-dashboard-build-prompt.md`. This is the source of truth for colors, type, layout, and component conventions.

## Design thesis

Most "surveillance dashboards" default to the same move: a dark sidebar, a blue accent, and pins dropped on a map. That reads as generic ops-tooling, not epidemiology specifically. VETRA's dashboard should look like it was built by people who understand how disease actually spreads across geography — because that's what the backend is already computing.

**The signature move:** outbreak risk isn't shown as a dot with a colored ring. It's rendered as **contour bands** — concentric, unevenly-shaped rings that fade outward from a cluster core, the way epidemiologists actually draw risk surfaces (isopleth maps / kernel density contours), not the way consumer map apps draw a "5km radius." This is the one place the design takes a visible risk, and it's justified by the brief: the risk engine already computes a continuous, multi-signal field, not a binary in/out zone — the map should look like it.

Two more decisions carry the rest of the personality:
- **A mono utility face for every number that matters operationally** — risk scores, coordinates, timestamps, case IDs read like data-terminal output, not marketing copy. This is what makes the interface feel instrumented rather than decorated.
- **A five-tier risk scale that ends in oxblood, not bright red.** Real epidemiological severity maps (WHO, NYT COVID mapping) reserve a darker terminal color beyond "high" for "severe" — it reads as more serious precisely because it isn't the loudest color on screen. A screen that's all bright red at the critical tier has nowhere to go; one that ends in a deep, quiet maroon does.

## Color

### Structure — cartographic navy, not default Tailwind slate
| Token | Hex | Use |
|---|---|---|
| `nav-bg` | `#0E1A2B` | Primary navigation / sidebar |
| `nav-text` | `#9FB1C4` | Nav labels, inactive |
| `nav-text-active` | `#F4F7FA` | Nav labels, active |
| `workspace-bg` | `#F6F8FA` | Main content background |
| `surface` | `#FFFFFF` | Panels, tables, cards |
| `border` | `#E1E6EC` | Default borders/dividers |
| `border-strong` | `#C7D0DB` | Table headers, section dividers |
| `text-primary` | `#101826` | Headings, primary body text |
| `text-secondary` | `#526074` | Labels, metadata, captions |
| `text-muted` | `#93A1B0` | Disabled, placeholder |

### Accent — muted institutional blue (per brief), never saturated SaaS-blue
| Token | Hex | Use |
|---|---|---|
| `accent` | `#1E5C97` | Links, active tab, selected layer, primary buttons |
| `accent-hover` | `#164A7C` | Hover state |
| `accent-subtle` | `#E4EDF6` | Selected-row background, focus rings |

### Risk scale — five tiers, functional only, never reused elsewhere
| Token | Hex | Meaning |
|---|---|---|
| `risk-severe` | `#6E1423` | 90–100 · beyond critical — terminal tier |
| `risk-critical` | `#B7301F` | 70–89 |
| `risk-high` | `#D97B1F` | 50–69 |
| `risk-moderate` | `#C9A227` | 25–49 |
| `risk-minimal` | `#3E7C4A` | 0–24 |
| `case-confirmed` | `#B7301F` (solid marker) | Confirmed case |
| `case-suspected` | `#D97B1F` (hollow/outline marker) | Suspected case — **shape differs from confirmed, not just color**, so severity reads without relying on color vision alone |
| `vaccination-gap` | `#B7301F` | Low/critical immunity coverage |
| `vaccination-ok` | `#3E7C4A` | Adequate coverage |

**Rule:** these ten tokens are the only saturated colors in the entire product. Everything structural is desaturated navy/gray so risk data is always the loudest thing on screen.

## Typography

- **Primary face:** Inter — established across all VETRA products, used for UI, body text, headings.
- **Utility/data face:** a monospace (JetBrains Mono or IBM Plex Mono) reserved for risk scores, GPS coordinates, timestamps, case/report IDs, and table numeric columns. This is the one deliberate second face — it exists to make operational data feel measured and read precisely, not to add variety for its own sake.
- **Base body:** 14px / 1.6 line-height (VETRA-wide rule). Dense table rows may drop to 1.35–1.4 — never body/paragraph text.

| Role | Face | Size | Weight |
|---|---|---|---|
| Page title | Inter | 20px | 600 |
| Section header | Inter | 16px | 600 |
| Panel/card label | Inter | 13px | 600, uppercase, `text-secondary`, +0.02em tracking |
| Body | Inter | 14px | 400 |
| Table text columns | Inter | 13px | 400 |
| Table numeric columns | Mono | 13px | 400, tabular figures |
| Risk score (large display) | Mono | 30px | 500 |
| Coordinates / IDs / timestamps | Mono | 12px | 400, `text-secondary` |

No italics for emphasis anywhere — use weight or the mono face's inherent "readout" quality instead.

## Layout concept

**Command Overview** — map-anchored, alerts always visible, KPIs summarized not celebrated:

```
┌────┬──────────────────────────────────────────────┬───────────┐
│    │ Region ▾        3 critical alerts    Officer  │  ALERTS   │
│NAV ├──────────────────────────────────────────────┤  ▪ Nashik │
│    │                                                │  ▪ Pune   │
│ ▤  │                                                │  ▪ Latur  │
│ ▤  │        GIS MAP — risk contour bands            ├───────────┤
│ ▤  │        (isopleth rings, not pin drops)         │  KPI      │
│ ▤  │                                                │  STRIP    │
├────┴──────────────────────────────────────────────┴───────────┤
│ Active 12   Confirmed 34   Suspected 61   Vax gaps 4 regions   │
└─────────────────────────────────────────────────────────────┘
```

**Outbreak Intelligence (cluster detail)** — the explainability requirement made structural, not an afterthought:

```
┌─────────────────────────────┬─────────────────────────────────┐
│                               │  RISK  78 (mono, large)         │
│   mini-map: this cluster     │  ──────────────────────────────│
│   contour only                │  spatial cluster strength  ███│
│                               │  environmental conditions  ██  │
│                               │  historical recurrence     ████│
│                               │  vaccination immunity gap  █    │
└─────────────────────────────┴─────────────────────────────────┘
```

The four risk signals are always shown as labeled bars next to the score — the score is never displayed alone.

## Components

- **Risk contour rendering:** 3–4 nested translucent bands (18%, 12%, 8%, 4% opacity of the tier color) fading outward from the cluster core, irregular/organic shape driven by the actual spatial data — not a perfect circle. Core marker sized by case count.
- **Risk score display:** mono numeral + a thin single-stroke arc gauge (not a filled donut, not a gradient) — precise, not decorative.
- **Badges:** rectangular, 2px radius, 12%-opacity tier color background with full-strength tier color as text/border.
- **Tables:** `border-strong` header rule, uppercase 12px labels, numeric columns right-aligned in mono, hover row = `accent-subtle`. No colored zebra striping.
- **Alerts:** left border stripe in tier color, `surface` background, mono timestamp — always visible in the right rail or a top banner, never behind a bell icon.
- **Buttons:** 4px radius rectangles, one primary (`accent`) per view, secondary as outline only.
- **Motion:** none beyond hover/focus states, except a single slow (2s) opacity pulse on a *newly arrived* critical alert until acknowledged — no other animation anywhere. Respect `prefers-reduced-motion` by disabling even that.

## Quality floor (non-negotiable, not a nice-to-have)

Responsive down to a stacked single-column layout below 768px; visible keyboard focus rings using `accent-subtle`; `prefers-reduced-motion` respected; confirmed-vs-suspected always distinguishable by marker shape as well as color for colorblind accessibility.

## Explicitly avoid

Gradients, glassmorphism/blur, drop shadows for elevation (use `border` instead), pill-shaped cards, filled-donut or gradient-ring score charts, perfect-circle "radius" map zones, oversized hero stat numbers without context, illustrations, emojis, bubbly iconography, bright saturated blue (Tailwind-default-looking accent), and any animation beyond what's specified above.
