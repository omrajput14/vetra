---
name: "Vetra"
description: >-
  Livestock health platform for farmers and vets in rural India. Built on
  Evernote's marketing-site palette and Figtree/Inter type pairing, but
  re-tuned for a mobile, outdoor, low-literacy context: higher contrast,
  bigger touch targets, larger minimum type, and two new semantic colors
  (alert red, caution amber) that Evernote's system never needed.
platform: "Flutter / Android"
base_system: "Evernote DESIGN.md (adapted, not copied verbatim)"
---

## Why start from Evernote and not Instacart

Evernote's whole visual language is built around *records on paper* — a
notebook metaphor, one restrained accent color, achromatic structure. That's
much closer to what Vetra actually is (an animal's passport, a vaccination
history, a diagnosis timeline) than Instacart's retailer-grid/marketplace
language. So the neutrals, the parchment surface, and the single-accent
discipline carry over. What doesn't carry over: Evernote's system was
extracted from a 1440px desktop marketing page, meant to be *read*, not
*tapped in sunlight by someone who may not read English well*. Every gap
below exists because of that difference.

---

## Colors

Evernote's original tokens were fixed hex values with no theme concept —
fine for a marketing page that only ever renders once. Vetra needs a
light/dark pair for each neutral role, so those tokens are now named by
**role** (`text-primary`, `surface-background`, etc.) with a light and dark
value each. The four accent colors stay fixed across both themes — see why
under Dark Mode below.

### Semantic neutrals — light / dark
| Token | Light | Dark | Role |
|---|---|---|---|
| `text-primary` | `#141414` | `#F2EDE6` | Headings, main body text. Dark value reuses the parchment tone — a deliberate callback. |
| `text-secondary` | `#4e4d4c` | `#C9C4BC` | Breed/age lines, secondary copy. |
| `text-metadata` | `#737373` | `#8A8680` | Timestamps, IDs only — never anything the farmer must act on, in either theme. |
| `text-pure` | `#000000` | `#FFFFFF` | Reserved for rare max-contrast moments. |
| `surface-background` | `#f4eee5` (parchment) | `#141414` (ink) | App floor. Parchment and ink literally swap roles between themes. |
| `surface-card` | `#ffffff` | `#1F1F1F` | Card fill. |
| `border-hairline` | `#a1a1a1` | `#3A3A3A` | Borders only — never text, in either theme. |

### Accent colors — unchanged across themes
| Token | Hex | Role |
|---|---|---|
| `brand-primary` | `#94e130` | Chartreuse. One primary action per screen only. |
| `alert-critical` | `#C62828` | Contagious diagnosis banners, Emergency SOS. Nothing else may use this red. |
| `caution-amber` | `#F2994A` | "Vaccination due in 3 days," moderate risk. One step below critical. |
| `vet-accent` | `#2F6FDE` | Small role-badge only (marks a screen/account as vet-side). Never used on a button. |

Reasoning: chartreuse stays the *only* color used for positive/primary
actions (true to Evernote's discipline), but health apps need failure
states a notebook brand never had to define. Two new colors, used narrowly,
keep the "one voltage" discipline intact while giving you an honest way to
say "this is urgent" without overloading green.

---

## Typography

Kept: **Figtree** for anything farmer-facing (headings, buttons, passport
cards) — it's warm and geometric, good substitute needs zero substitution
since it's a free Google Font, easy to bundle in Flutter. **Inter** for
dense vet-side data (diagnosis forms, timestamps) — same split Evernote
uses between brand voice and utility text.

Changed: Evernote's scale was built for a desktop hero (72px, -3.6px
tracking). None of that survives to a phone. Rebuilt scale:

| Token | Font | Size | Weight | Use |
|---|---|---|---|---|
| `screen-title` | Figtree | 24px | 600 | "My Animals," "Scan QR" |
| `section-heading` | Figtree | 20px | 600 | "Vaccination History" |
| `card-title` | Figtree | 18px | 600 | Animal name on passport card |
| `body-default` | Figtree | 16px | 400 | All farmer-facing body text — **16px is the floor, not 12–14px** |
| `button-label` | Figtree | 16px | 600 | Never shrink button text for hierarchy |
| `alert-text` | Figtree | 16px | 600 | Same size as body — alerts never shrink |
| `caption-metadata` | Inter | 13px | 400 | Timestamps, IDs — vet dashboard only |
| `vet-data-row` | Inter | 15px | 400 | Diagnosis form fields, dense tables |

No negative tracking anywhere. Evernote's -3.6px only works at 72px; at
mobile sizes it just looks cramped.

### Hindi / Marathi / Telugu — the real fix, not just a warning

Figtree only covers Latin script. It has no Devanagari or Telugu glyphs at
all — Flutter will silently substitute the system font for any Hindi,
Marathi, or Telugu string, which means an English screen and a Hindi
screen would end up looking like two different apps if left unaddressed.

**Decision:** pair Figtree with **Noto Sans Devanagari** (Hindi, Marathi)
and **Noto Sans Telugu** (Telugu) for translated locales. Both are free
Google Fonts, built specifically to solve this exact "tofu" problem, and
their proportions sit close enough to Figtree's geometric warmth that the
switch doesn't feel jarring between locales.

| Token | Script | Font | Size |
|---|---|---|---|
| `body-default-devanagari` | Hindi / Marathi | Noto Sans Devanagari, 400 | 17px |
| `body-default-telugu` | Telugu | Noto Sans Telugu, 400 | 17px |

Note the size bumps from 16px to 17px, not down — this is deliberate.
Devanagari matras and Telugu vowel signs are small, intricate marks that
need slightly *more* room to stay legible, even though the Latin instinct
is to shrink text to fit longer words.

**Layout rules that follow from this:**
- Never hardcode button or chip widths. Use intrinsic content width with
  padding, not a fixed `width:`, since translated strings run 20–40%
  longer than English.
- Allow buttons to wrap to two lines in translated locales rather than
  truncating — but the alert banner text (`alert-critical`) must **never**
  truncate or ellipsis in any locale, since that's the one string that
  can't afford to lose meaning.
- Drop any `text-transform: uppercase` styling entirely, app-wide.
  Devanagari and Telugu have no letter casing, so an uppercase rule that
  only applies to English creates visual inconsistency between locales for
  no benefit.
- Before locking any component's width, test it against the actual
  translated string — not the English placeholder — since Telugu is
  likely to be the longest of the three.

---

## Radius

Evernote runs a tight 5px base to read as "structured tool, not consumer
toy" — good instinct, kept in spirit, but bumped slightly for touch comfort:

| Token | Value | Use |
|---|---|---|
| `radius-sm` | 8px | Buttons, input fields |
| `radius-md` | 12px | Passport cards, feature cards |
| `radius-lg` | 20px | Modals, bottom sheets |
| `radius-pill` | full | Status chips only |

---

## Icon System

**Decision: filled/solid icons, not line icons.** Thin 1–2px strokes wash
out in direct sunlight and shrink poorly at small sizes — solid silhouettes
hold up better in both conditions and are faster to recognize for anyone
skimming by shape rather than reading a label. Corners on custom icons
should echo the radius language (soft, not sharp) so they feel native to
the rest of the UI.

**Two tiers, not one:**

| Tier | Icons | Source |
|---|---|---|
| Custom-drawn | Livestock/animal, syringe (vaccination), QR scan frame, stethoscope (vet/diagnosis), warning triangle (contagious), certificate (passport/prescription) | Bespoke — these carry your actual brand identity and appear in nav bars and primary actions, so they're worth the extra design time. |
| Generic solid library | Bell (notifications), map pin, calendar, settings, back arrow, search | Material Symbols "Filled" or Phosphor "Fill" variant — already universally recognized, no need to reinvent. |

**Rules:**
- Grid: 24dp icon on a minimum 48dp tap target, regardless of how small
  the icon looks visually — this is the Android accessibility floor and
  matters more here given an older/field-working user base.
- Color: `text-primary` when neutral/inactive, `brand-primary` fill when
  active/selected (e.g., the current bottom-nav tab), `alert-critical` only
  for the warning icon. Never repurpose an icon's color meaning elsewhere —
  consistency is what makes icon-only recognition work over repeat use.
- Never mix filled and outline styles in the same screen. Pick filled and
  stay filled everywhere, including inside icons pulled from a generic
  library.

---

## Dark Mode

Scoped in now rather than left for later, since Flutter's `ThemeData`
supports light/dark pairs cleanly from day one and it costs little to wire
up early. Practically, it matters most for the vet side — a night
emergency diagnosis or SOS response — while the farmer app will mostly be
used in daylight regardless of which theme is active.

The reason this was a smaller lift than it first looks: the four accent
colors (`brand-primary`, `alert-critical`, `caution-amber`, `vet-accent`)
are only ever used as **self-contained fills with a fixed contrasting
text color** (chartreuse + `text-primary`, red + white) — so they don't need
separate dark-mode values at all. What actually needed pairing were the
neutrals, which is exactly what the semantic table under Colors now
provides. Nothing else in this spec changes for dark mode — cards, borders,
and chips all inherit correctly once `text-*`, `surface-*`, and
`border-hairline` switch to their dark values.

One thing worth a quick visual check once real screens exist: chartreuse
on near-black tends to look *more* vivid, not less — confirm it isn't
overpowering next to the calmer dark neutrals before shipping.

---

## Spacing

`4 / 8 / 12 / 16 / 24 / 32 / 40px` — standard mobile scale, nothing exotic.

---

## Components

**`icon-nav-tile`** — home-screen and bottom-nav items. Large icon (not
Evernote-scale) + 14px Figtree 600 label underneath. Bigger than a typical
consumer app's nav icons — this is the direct fix for low-literacy use:
if the label isn't read, the icon alone should still communicate "Scan,"
"My Animals," "Vet Nearby."

**`animal-passport-card`** — `surface-card` fill, `radius-md`, `border-hairline` border.
Photo thumbnail, `card-title` name, `text-secondary` breed/age line, QR icon
tag in the corner. This is your core screen — everything else refers back
to it.

**`button-primary`** — `brand-primary` fill, `text-primary` text, `radius-sm`,
**52px height** (up from Evernote's 46px — thumb-friendly for outdoor,
one-handed use). One per screen: Add Animal, Scan QR, Confirm Diagnosis.

**`button-secondary`** — transparent fill, `text-primary` text, `border-hairline` border,
same height/radius as primary.

**`status-chip-healthy`** — `radius-pill`, chartreuse **border** + `text-primary`
text, transparent/canvas fill — deliberately stroke-not-fill (borrowing
Instacart's one good idea) so chartreuse-as-fill stays exclusive to the
primary CTA button.

**`caution-chip`** — `radius-pill`, `caution-amber` fill, `text-primary` text.
"Vaccination due in 3 days."

**`alert-banner-contagious`** — full-width, `alert-critical` fill, white
text, warning icon. Always icon + explicit word ("Contagious" /
"Emergency") — never color alone. This matters doubly here: phone screens
wash out color in direct sunlight, and red/green alone isn't reliable for
colorblind users.

**`emergency-sos-button`** — floating action button, `alert-critical` fill,
visually distinct shape (circular, not the standard button radius) from
`button-primary` so it's never mistaken for a normal action.

**`qr-scan-frame`** — camera view with chartreuse corner brackets framing
the scan target.

**`vet-role-badge`** — small `vet-accent` outline tag next to a vet's name
in headers. Marks the account type without introducing a second
CTA-competing color.

**`diagnosis-form-card`** — Inter-based, denser padding, for the vet's
add-diagnosis flow (disease name, contagious toggle, severity dropdown).
Deliberately less "warm" than farmer screens — this is a professional tool
in that moment, not a friendly one.

---

## Do's and Don'ts

**Do** reserve `brand-primary` fill for exactly one action per screen —
kept directly from Evernote's discipline.

**Do** pair every `alert-critical` element with an icon and a word.
Colorblind accessibility and sunlight glare both defeat color-only signals.

**Do** keep `body-default` and `alert-text` at 16px minimum. Evernote's
marketing captions go to 12px; that's fine on a monitor, not for a farmer
glancing at a phone outdoors.

**Do** keep `surface-background` as the app floor — it's doing double
duty as your paper/passport metaphor.

**Don't** use `text-metadata` for anything the farmer needs to act on. Timestamps
and metadata only.

**Don't** add a third or fourth semantic color beyond amber/red. Two
severity tiers is the ceiling before fast triage breaks down.

**Don't** put `vet-accent` blue on any button. It's a role marker, not a
second brand color — the moment it's clickable, you have two competing
CTAs.

**Don't** carry over Evernote's -3.6px tracking at any mobile size. There's
no 72px surface on a phone for it to work on.

---

## Known Gaps — what's still genuinely open

Icons, multilingual type, and dark mode are now decided above. What's left
isn't a design call — it's verification work that can only happen once
real screens exist:

- **Real contrast verification.** The neutral pairs above are chosen for
  *intent* (outdoor legibility), but haven't been run through a formal
  WCAG contrast checker against actual rendered screens yet. Check
  `text-secondary` on `surface-background` first, in both themes — that's
  the pairing most likely to be borderline.
- **Larger illustration/empty-state style** (e.g., the "no animals added
  yet" screen). The icon system above covers UI icons, not full
  illustrations — worth a quick separate decision once you're building the
  onboarding flow, but it doesn't block anything else here.
