---
name: slides
description: Use this skill whenever the user is making slides, a deck, a presentation, a readout, a pitch, a talk, or converting a PowerPoint (PPT/PPTX) to web — even if they don't say "slides". Trigger on "put this together as a deck", "I need to present this", "make me something to show the team", "build a presentation", "convert this PPTX", "turn my slides into HTML", "brand-compliant deck", on  when they want to deploy/share a deck or export it to PDF. Produces zero-dependency 16:9 HTML decks; Aircall brand is the house default, with a creative template pack for external/personal decks. Save to ~/.claude/Slides/<name>.html.
---

# Slides (frontend-slides engine + Aircall brand)

Create zero-dependency, animation-rich **16:9 HTML** presentations that run entirely in the browser. Built on the frontend-slides fixed-stage engine, with a company brand as the house style.

**Save all decks to `~/.claude/Slides/<name>.html`.** Preview assets go in `~/.claude/Slides/.previews/` (clean up after).

## Brand vs. creative — the routing rule (read first)
- **Internal / Aircall-facing decks → Company Brand is the default and the only on-brand style.** Use the **Company Brand** preset in [STYLE_PRESETS.md](STYLE_PRESETS.md) (full spec: [company-brand.md](company-brand.md)). Skip the 3-wild-previews style-discovery; instead confirm Company Brand and offer at most light variations (which gradient for the hero, light vs. dark cover).
- **External / personal / explicitly "creative" decks → run the full style-discovery flow** (Phase 2) with the presets + `bold-template-pack`.
- **Typography is the house default everywhere:** `viewport-base.css` defaults every deck to Instrument Serif / Poppins / JetBrains Mono (never bold). A chosen creative preset/template overrides with its own fonts by design — that's intended; don't fight it.
- **Identifiers always in code font:** any field, column, model, table, function, file, or config name on a slide must be set in `--font-mono` (JetBrains Mono) — e.g. wrap it in `<code>` or a `.mono` span, never plain body text. In this skill's Markdown docs use backticks. Applies to titles, bullets, captions, and labels, not just code blocks.
- **Never globally force Aircall *colours* onto a creative preset/template.** Each preset/template commits to its own palette as the core of its identity; overriding it with Brand Green breaks the design. Aircall colours live only in the Company Brand preset. (This is a deliberate decision — typography travels as a soft default, colour does not.)

## Core Principles
1. **Zero Dependencies** — single HTML file, inline CSS/JS. No npm/build.
2. **Show, Don't Tell** — for creative decks, generate visual previews, not abstract choices.
3. **Distinctive Design** — no generic "AI slop". On-brand ≠ boring; off-brand ≠ random.
4. **Progressive Disclosure** — read lightweight indexes first; load a bold template's full `design.md` only after it's picked.
5. **Fixed 16:9 Stage (NON-NEGOTIABLE)** — every deck is a 1920×1080 canvas scaled as a whole to the viewport. Stays 16:9 on every screen incl. phones. Never reflow slide content to fit the device. **Read [viewport-base.css](viewport-base.css) and include its full contents in every deck.**

## Design Aesthetics (creative decks)
Avoid AI-slop convergence: no Inter/Roboto/Arial/system display fonts, no purple-gradient-on-white clichés, no cookie-cutter card grids. Commit to a cohesive aesthetic, distinctive type, atmospheric backgrounds, and one well-orchestrated load animation with staggered reveals. For Company Brand decks, "distinctive" means the restrained editorial brand look — not decoration.

## Fixed Stage Rules (every slide, every deck)
- Deck viewport fills the window; each slide authored inside a fixed 1920×1080 stage; stage scales uniformly (letterbox/pillarbox OK, never re-layout).
- No responsive breakpoints to rearrange slide content for phones. Use fixed internal measurements at 1920×1080.
- Slide visibility via `.active`/`.visible` (`visibility`/`opacity`/`pointer-events` from `viewport-base.css`) — **never** `display:none/block` for slide switching (later `display:flex` layout rules would reveal all slides at once).
- Include `prefers-reduced-motion` support. Never negate CSS functions directly (`-clamp(...)` is silently ignored) — use `calc(-1 * clamp(...))`.

### Content Density Modes
Ask whether this is a **speaker-led** deck (low density: one idea/slide, big type, 1-3 bullets, more slides) or **reading-first** (high density: self-contained grids/tables, 4-8 bullets/4-6 cards). No scrolling/overflow/overlap ever; if content exceeds the mode, split into more slides.

---

## Phase 0: Detect Mode
- **Mode A: New Presentation** → Phase 1.
- **Mode B: PPT Conversion** → Phase 4.
- **Mode C: Enhancement** of existing HTML → read it, respect density limits, verify 16:9 + no overflow/overlap after every change, split slides proactively when adding content/images.

---

## Phase 1: Content Discovery (new decks)
Ask together (use the structured-question UI if available):
1. **Purpose** — Pitch / Teaching / Conference talk / Internal
2. **Length** — Short 5-10 / Medium 10-20 / Long 20+
3. **Content** — All ready / Rough notes / Topic only
4. **Density** — Speaker-led (low) / Reading-first (high)

**Infer brand vs. creative from Purpose:** "Internal" (or any Aircall-facing readout) ⇒ Company Brand default, skip Phase 2's wild previews. Pitch/Conference/personal ⇒ eligible for the creative flow. When ambiguous, ask: "On-brand Aircall, or a custom creative look?"

If images are provided: scan, inspect, evaluate USABLE/NOT, co-design the outline around text + images, confirm the outline. Embed a usable logo (base64) into previews.

---

## Phase 2: Style
**Company Brand deck:** confirm the Company Brand preset (no wild previews). Optionally generate ONE on-brand cover preview and ask only light choices (hero gradient: city-nights / dusk / midday / morning; light vs. dark cover). Then go to Phase 3.

**Creative deck (show, don't tell):** generate **3 distinct single-slide HTML previews** — 1 safe preset from [STYLE_PRESETS.md](STYLE_PRESETS.md), ≥1 bold template from [bold-template-pack/selection-index.json](bold-template-pack/selection-index.json), 1 wildcard (second template or a custom design). Read the compact selection index only; read a candidate's `preview.md` after shortlisting; never read `design.md` until the user picks. Save previews to `~/.claude/Slides/.previews/` (style-a/b/c.html), open them, then ask which they prefer (or "Mix").

**Preview authenticity (NON-NEGOTIABLE):** previews must look like a real first slide — never render `preview`, `option A/B/C`, template/preset names, file paths, or requirement notes ("safe option", "audience: …") on the slide itself.

---

## Phase 3: Generate
Use Phase 1 content + chosen style. Apply the density choice throughout (speaker-led → more slides/fewer ideas; reading-first → self-contained structured slides). Never let high density become clutter — split instead of shrinking.

**Before generating, read:**
- [viewport-base.css](viewport-base.css) — mandatory, include in full (it also sets the Aircall typography default)
- [html-template.md](html-template.md) — HTML architecture, JS (stage-scaling, nav, inline editing), image pipeline. Its default `:root` is Company Brand.
- [animation-patterns.md](animation-patterns.md) — animation reference
- **Company Brand deck:** [company-brand.md](company-brand.md) — colours, gradients, type scale, component grammar
- **Creative deck:** the selected preset block in `STYLE_PRESETS.md`, or the selected bold template's full `design.md` (only that one). Translate any viewport-fluid values into 1920×1080 stage coordinates; keep output single-file; don't copy demo content.

**Requirements:** single self-contained HTML; full `viewport-base.css` in `<style>`; Google Fonts / Fontshare (never system fonts); `/* === SECTION === */` comments; verify in rendered screenshots that nothing overflows or overlaps (at 1280×720 and one phone viewport). Inline editing is included by default (hover top-left or `E`, Ctrl+S to save) unless the user wants a locked file.

---

## Phase 4: PPT Conversion
1. `python scripts/extract-pptx.py <input.pptx> <output_dir>` (`pip install python-pptx` if needed)
2. Confirm extracted titles / content / image counts with the user
3. Phase 2 for style (default Company Brand if it's an internal deck)
4. Generate HTML preserving all text, images (from assets/), order, and speaker notes (as HTML comments)

---

## Phase 5: Delivery
1. Delete `~/.claude/Slides/.previews/` if present
2. `open ~/.claude/Slides/<name>.html`
3. Tell the user: file path, style name, slide count; navigation (arrows/space/swipe); how to customize (`:root` vars, font link, animations); inline editing (hover top-left or `E`, Ctrl+S); offer revisions / browser edit / export.

---

## Phase 6: Share & Export (optional)
Ask: "Deploy to a live URL (works on any device) or export to PDF?"
- **Deploy (Vercel):** `bash scripts/deploy.sh <path>` — accepts a folder (with index.html) or a single HTML file. Guide first-timers through `npx vercel` login. Verify images load on the deployed URL; prefer folder deploys when there are many assets.
- **PDF:** `bash scripts/export-pdf.sh <path-to-html> [output.pdf]` (Playwright; auto-installs Chromium on first run — warn ~30-60s). Slides must use `class="slide"`. Add `--compact` (1280×720) if the PDF >10MB. Animations become their final static state.

---

## Supporting Files
| File | Purpose | When |
|------|---------|------|
| [company-brand.md](company-brand.md) | Aircall colours, gradients, type scale, component grammar | Company Brand decks (Phase 3) |
| [STYLE_PRESETS.md](STYLE_PRESETS.md) | Company Brand preset + 12 creative presets | Phase 2 |
| [bold-template-pack/selection-index.json](bold-template-pack/selection-index.json) | Compact bold-template metadata | Phase 2 (creative) |
| [bold-template-pack/templates/*/preview.md](bold-template-pack/templates/) | Title-slide style cards (shortlisted only) | Phase 2 after shortlisting |
| [bold-template-pack/templates/*/design.md](bold-template-pack/templates/) | Full design system for the selected template only | Phase 3 (creative) |
| [viewport-base.css](viewport-base.css) | Mandatory fixed-stage CSS + Aircall type default — include in full | Phase 3 |
| [html-template.md](html-template.md) | HTML/JS architecture, image pipeline, inline editing | Phase 3 |
| [animation-patterns.md](animation-patterns.md) | CSS/JS animation snippets | Phase 3 |
| [scripts/extract-pptx.py](scripts/extract-pptx.py) | PPT → content | Phase 4 |
| [scripts/deploy.sh](scripts/deploy.sh) · [scripts/export-pdf.sh](scripts/export-pdf.sh) | Deploy / PDF | Phase 6 |
| `assets/legacy-reveal-4x3.html` | Deprecated old 4:3 Reveal.js template — reference only | — |
