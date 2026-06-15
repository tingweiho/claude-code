# Aircall Brand Reference

Canonical Aircall brand spec for the **Aircall Brand** preset (see [STYLE_PRESETS.md](STYLE_PRESETS.md)). This is the house style for internal decks. Typography here is also the skill-wide default baked into [viewport-base.css](viewport-base.css) — a deck only departs from it when the user explicitly picks a creative preset / bold template.

Slides are authored on the fixed **1920×1080** stage (see [html-template.md](html-template.md)); translate any rem sizes below to stage px proportionally.

## Typography
| Role | Font | Weight | Size (rem ref) |
|------|------|--------|------|
| H1 | Instrument Serif | 400 | 3rem |
| H2 | Instrument Serif | 400 | 2.25rem |
| H3 | Instrument Serif | 400 | 1.625rem |
| H4 | Instrument Serif | 400 | 1.25rem |
| Body | Poppins | 300 | 0.9375rem |
| Body Small | Poppins | 300 | 0.8125rem |
| Label / Tag | JetBrains Mono | 400 | 0.72rem |
| Code | JetBrains Mono | 400 | 0.875rem |

**Rules:** Never bold. Poppins max weight = 400. Instrument Serif = headings only (it has no bold — visual weight comes from size). JetBrains Mono = labels/tags/code only. Set `font-synthesis: none` so the serif/sans never fake-bold.

Font link:
```html
<link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Poppins:wght@300;400&family=JetBrains+Mono:wght@400&display=swap" rel="stylesheet">
```

## Core colour tokens
| Token | Hex | Use |
|-------|-----|-----|
| Ink | `#002620` | Primary text (never use pure black) |
| Ink Muted | `#749E98` | Secondary text, captions |
| Page bg | `#FAFBFD` | Default slide background |
| Border | `#E5EAE9` | Dividers, card borders |
| #00B67A | `#008F6D` | Primary accent, CTAs |

## Brand colour palettes
**#00B67A (H=166°):** 100 `#EEF6F4` · 200 `#D4ECE6` · 300 `#A8E5D7` · 400 `#4CE5C1` · **500 `#008F6D`** · 600 `#056A52` · 700 `#06503E` · 800 `#06372B` · 900 `#041F18`
**Periwinkle Blue (H=232°):** 100 `#F1F2F7` · 200 `#CBCFE7` · 300 `#A0A8DB` · 900 `#091460`
**Teal (H=191°):** 200 `#CFE2E6` · 300 `#AACFD7` · 400 `#67B7C7` · 500 `#237C90` · 600 `#155A6A`
**Purple (H=268°):** 200 `#D9CBE8` · 500 `#6A28B5` · 600 `#360D64`
**Pink (H=330°):** 200 `#EBCCDC` · 300 `#E0A1C1` · 500 `#941454` · 600 `#680A39`
**Neutral:** 100 `#F3F5F5` · 200 `#E5EAE9` · 500 `#749E98` · 800 `#002620` · 900 `#011310`
**Paper:** 100 `#FDFDFD` · 200 `#FAFBFD` · 300 `#EFF3FC`

## Brand gradients (add a subtle grain overlay for texture)
| Name | CSS stops | Use |
|-------|-----------|-----|
| `city-nights` | `#3B396A 0%, #665774 25%, #963B5C 50%, #766257 75%, #32516D 100%` | Hero, closing — dark |
| `dusk` | `#9FB7C3 0%, #9792B8 25%, #585C94 50%, #293063 75%, #1A1E3B 100%` | Data, stats — dark |
| `midday` | `#B8C5DB 0%, #A2D3DE 25%, #A6D7E2 50%, #B0C9DC 75%, #7A7FBB 100%` | Product — light |
| `morning` | `#B3BEBC 0%, #CCC8E4 25%, #DED8E9 50%, #D1DCEA 75%, #B3BEBC 100%` | Quote, gentle — light |

**Gradient text pairings:**
- City Nights / Dusk (dark): white text, glass cards (`rgba(255,255,255,0.12)`), accents in Teal-300 / Pink-300 / Purple-200
- Mid Day / Morning (light): `#002620` ink text, white cards, dark default chips

## Component grammar (translate to 1920×1080 stage)
- **Eyebrow label:** JetBrains Mono, uppercase, ~0.72rem, letter-spacing 0.05em, colour Ink Muted (`--text-secondary`).
- **Rule / divider:** 1px line in Border `#E5EAE9` (light slides) or `rgba(255,255,255,0.25)` (dark/gradient slides).
- **Card:** white bg, 1px Border, radius ~10px (light slides) · **Glass card:** `rgba(255,255,255,0.12)` bg (gradient slides).
- **Chip:** border + Ink-Muted text (default) · green border + Brand-Green text (accent) · white variant for dark slides.
- **Stat:** Instrument Serif large numeral + Poppins 0.8125rem label beneath.
- **Backgrounds:** prefer Paper `#FAFBFD` for content slides; reserve the four gradients for hero / section divider / stat / quote / closing.

## Legacy
The previous 4:3 Reveal.js implementation is archived at `assets/legacy-reveal-4x3.html` — superseded by the 16:9 fixed-stage engine. Don't use it for new decks.
