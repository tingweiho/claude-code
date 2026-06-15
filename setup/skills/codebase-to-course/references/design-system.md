# Design System Reference

Complete CSS design tokens for the course. Copy this entire `:root` block into the course HTML and adapt the accent color to suit the project's personality.

## Table of Contents
1. [Color Palette](#color-palette)
2. [Typography](#typography)
3. [Spacing & Layout](#spacing--layout)
4. [Shadows & Depth](#shadows--depth)
5. [Animations & Transitions](#animations--transitions)
6. [Navigation & Progress](#navigation--progress)
7. [Module Structure](#module-structure)
8. [Responsive Breakpoints](#responsive-breakpoints)
9. [Scrollbar & Background](#scrollbar--background)

---

## Color Palette

```css
:root {
  /* --- BACKGROUNDS (warm cream — course default; Aircall ink/neutral) --- */
  --color-bg:             #faf7f0;       /* warm cream — default module bg */
  --color-bg-warm:        #f0ece1;       /* deeper cream — alternating modules */
  --color-bg-code:        #011310;       /* Neutral 900 — near-black green, code blocks */
  --color-text:           #002620;       /* Ink — never pure black */
  --color-text-secondary: #749E98;       /* Ink Muted — secondary text */
  --color-text-muted:     #A9C0BC;       /* lighter ink — timestamps, labels */
  --color-border:         #E5EAE9;       /* Neutral 200 */
  --color-border-light:   #F3F5F5;       /* Neutral 100 */
  --color-surface:        #FFFFFF;       /* card surfaces */
  --color-surface-warm:   #fdf9f3;       /* warm card surface */

  /* --- ACCENT (terracotta — runbook editorial style). Plus a teal "teach"
     secondary for definitions / info panels. --color-accent-light is the
     code/calc chip background. --- */
  --color-accent:         #b8421a;       /* terracotta / rust */
  --color-accent-hover:   #993515;       /* darker rust */
  --color-accent-light:   #f4e7dd;       /* faint rust over cream — chip bg */
  --color-accent-muted:   #e0b3a0;       /* muted terracotta */
  --color-teach:          #2a6c8f;       /* teal secondary */
  --color-teach-soft:     #dfeaf2;

  /* --- SEMANTIC (success = Brand Green; error/info legible for quiz feedback) --- */
  --color-success:        #056A52;       /* Brand Green 600 */
  --color-success-light:  #EEF6F4;
  --color-error:          #941454;       /* Pink 500 */
  --color-error-light:    #EBCCDC;       /* Pink 200 */
  --color-info:           #237C90;       /* Teal 500 */
  --color-info-light:     #CFE2E6;       /* Teal 200 */

  /* --- ACTOR COLORS (assign to main components) ---
     Each major "character" in the codebase gets a distinct Aircall accent. */
  --color-actor-1:        #008F6D;       /* Brand Green */
  --color-actor-2:        #237C90;       /* Teal */
  --color-actor-3:        #6A28B5;       /* Purple */
  --color-actor-4:        #941454;       /* Pink */
  --color-actor-5:        #091460;       /* Periwinkle 900 */
}
```

**Rules:**
- Even-numbered modules use `--color-bg`, odd-numbered use `--color-bg-warm` (alternating backgrounds create visual rhythm)
- Actor colors should be visually distinct from each other and from the accent
- Code blocks always use `--color-bg-code` with light text
- This palette is Aircall brand — see the `aircall-slides` skill for the canonical full spec (gradients, extended colour ramps)

---

## Typography

```css
:root {
  /* --- FONTS (runbook editorial stack) ---
     Display: Fraunces — headings, captions (italic); weights 400–700.
     Body: Inter — body/UI; weights 400–600.
     Mono: JetBrains Mono — code, labels, tags, calculations. */
  --font-display:  'Fraunces', Georgia, serif;
  --font-body:     'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-mono:     'JetBrains Mono', 'Fira Code', 'Consolas', monospace;

  /* --- TYPE SCALE (1.25 ratio) --- */
  --text-xs:   0.75rem;    /* 12px — labels, badges */
  --text-sm:   0.875rem;   /* 14px — secondary text, code */
  --text-base: 1rem;       /* 16px — body text */
  --text-lg:   1.125rem;   /* 18px — lead paragraphs */
  --text-xl:   1.25rem;    /* 20px — screen headings */
  --text-2xl:  1.5rem;     /* 24px — sub-module titles */
  --text-3xl:  1.875rem;   /* 30px — module subtitles */
  --text-4xl:  2.25rem;    /* 36px — module titles */
  --text-5xl:  3rem;       /* 48px — hero text */
  --text-6xl:  3.75rem;    /* 60px — module numbers */

  /* --- LINE HEIGHTS --- */
  --leading-tight:  1.15;  /* headings */
  --leading-snug:   1.3;   /* subheadings */
  --leading-normal: 1.6;   /* body text */
  --leading-loose:  1.8;   /* relaxed reading */
}
```

**Google Fonts link (put in `<head>`):**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400;0,9..144,500;0,9..144,600;0,9..144,700;1,9..144,400;1,9..144,600&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
```

**Rules (runbook editorial — Fraunces has real weights, so headings use them):**
- Module numbers: `--text-6xl`, font-display, weight 700, `--color-accent`
- Module titles: `--text-4xl`, font-display, weight 600
- Screen headings: `--text-xl` or `--text-2xl`, font-display, weight 600
- Body text: `--text-base` or `--text-lg`, font-body (Inter) weight 400, `--leading-normal`; `<strong>` = 600
- Code / calculations: `--text-sm`, font-mono — rendered as chips (`<code>` accent chip · `<span class="calc">` neutral chip)
- Labels/badges: `--text-xs`, font-mono, uppercase, letter-spacing 0.05em
- Captions / definitions: Fraunces italic (`.caption`, `.define-term`)
- Fraunces = headings/captions · Inter = body/UI · JetBrains Mono = code/labels/calcs.

---

## Spacing & Layout

```css
:root {
  --space-1:  0.25rem;   /* 4px */
  --space-2:  0.5rem;    /* 8px */
  --space-3:  0.75rem;   /* 12px */
  --space-4:  1rem;      /* 16px */
  --space-5:  1.25rem;   /* 20px */
  --space-6:  1.5rem;    /* 24px */
  --space-8:  2rem;      /* 32px */
  --space-10: 2.5rem;    /* 40px */
  --space-12: 3rem;      /* 48px */
  --space-16: 4rem;      /* 64px */
  --space-20: 5rem;      /* 80px */
  --space-24: 6rem;      /* 96px */

  --content-width:     800px;   /* standard reading width */
  --content-width-wide: 1000px; /* for side-by-side layouts */
  --nav-height:        50px;
  --radius-sm:  8px;
  --radius-md:  12px;
  --radius-lg:  16px;
  --radius-full: 9999px;
}
```

**Module layout:**
```css
.module {
  min-height: 100dvh;       /* fallback: 100vh */
  scroll-snap-align: start;
  padding: var(--space-16) var(--space-6);
  padding-top: calc(var(--nav-height) + var(--space-12));
}
.module-content {
  max-width: var(--content-width);
  margin: 0 auto;
}
```

---

## Shadows & Depth

```css
:root {
  --shadow-sm:  0 1px 2px rgba(44, 42, 40, 0.05);
  --shadow-md:  0 4px 12px rgba(44, 42, 40, 0.08);
  --shadow-lg:  0 8px 24px rgba(44, 42, 40, 0.1);
  --shadow-xl:  0 16px 48px rgba(44, 42, 40, 0.12);
}
```

Use warm-tinted RGBA (44, 42, 40) — never pure black shadows.

---

## Animations & Transitions

```css
:root {
  --ease-out:    cubic-bezier(0.16, 1, 0.3, 1);
  --ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);
  --duration-fast:   150ms;
  --duration-normal: 300ms;
  --duration-slow:   500ms;
  --stagger-delay:   120ms;
}
```

**Scroll-triggered reveal pattern:**
```css
.animate-in {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity var(--duration-slow) var(--ease-out),
              transform var(--duration-slow) var(--ease-out);
}
.animate-in.visible {
  opacity: 1;
  transform: translateY(0);
}

/* Stagger children */
.stagger-children > .animate-in {
  transition-delay: calc(var(--stagger-index, 0) * var(--stagger-delay));
}
```

**JS setup for stagger:**
```javascript
document.querySelectorAll('.stagger-children').forEach(parent => {
  Array.from(parent.children).forEach((child, i) => {
    child.style.setProperty('--stagger-index', i);
  });
});
```

**Intersection Observer (trigger reveals):**
```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target); // animate only once
    }
  });
}, { rootMargin: '0px 0px -10% 0px', threshold: 0.1 });

document.querySelectorAll('.animate-in').forEach(el => observer.observe(el));
```

---

## Navigation & Progress

**HTML structure:**
```html
<nav class="nav">
  <div class="progress-bar" role="progressbar" aria-valuenow="0"></div>
  <div class="nav-inner">
    <span class="nav-title">Course Title</span>
    <div class="nav-dots">
      <button class="nav-dot" data-target="module-1" data-tooltip="Module 1 Name"
              role="tab" aria-label="Module 1"></button>
      <!-- one per module -->
    </div>
  </div>
</nav>
```

**Progress bar (CSS-only where possible, JS fallback):**
```javascript
function updateProgressBar() {
  const scrollTop = window.scrollY;
  const scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
  const progress = (scrollTop / scrollHeight) * 100;
  progressBar.style.width = progress + '%';
}
window.addEventListener('scroll', () => {
  requestAnimationFrame(updateProgressBar);
}, { passive: true });
```

**Nav dot states:**
- Default: `border: 2px solid var(--color-text-muted)`, empty center
- Current: `border-color: var(--color-accent)`, filled center, subtle glow shadow
- Visited: `background: var(--color-accent)`, filled solid

**Floating table of contents (left rail):** `_base.html` includes an empty `<nav class="toc" id="toc">`. `main.js` auto-populates it from the nav dots — one top-level `.toc-link` per module, label taken from each dot's `data-tooltip`. It scroll-spies in lockstep with the dots (active link mirrors the active dot) and click-scrolls to the module. Purely additive: no per-course markup needed, and it auto-hides below 1180px so it never crowds the content column. Styling lives in `styles.css` (`.toc`, `.toc-link`).

**Keyboard navigation:**
```javascript
document.addEventListener('keydown', (e) => {
  if (['INPUT', 'TEXTAREA'].includes(e.target.tagName)) return;
  if (e.key === 'ArrowDown' || e.key === 'ArrowRight') { nextModule(); e.preventDefault(); }
  if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') { prevModule(); e.preventDefault(); }
});
```

---

## Module Structure

**HTML template for each module:**
```html
<section class="module" id="module-N" style="background: var(--color-bg or --color-bg-warm)">
  <div class="module-content">
    <header class="module-header animate-in">
      <span class="module-number">0N</span>
      <h1 class="module-title">Module Title</h1>
      <p class="module-subtitle">One-line description of what this module teaches</p>
    </header>

    <div class="module-body">
      <section class="screen animate-in">
        <h2 class="screen-heading">Screen Title</h2>
        <p>Content...</p>
        <!-- Interactive elements, code translations, etc. -->
      </section>

      <section class="screen animate-in">
        <!-- Next screen -->
      </section>
    </div>
  </div>
</section>
```

---

## Responsive Breakpoints

```css
/* Tablet */
@media (max-width: 768px) {
  :root {
    --text-4xl: 1.875rem;
    --text-5xl: 2.25rem;
    --text-6xl: 3rem;
  }
  .translation-block { grid-template-columns: 1fr; } /* stack code/english */
  .pattern-cards { grid-template-columns: 1fr 1fr; }
}

/* Mobile */
@media (max-width: 480px) {
  :root {
    --text-4xl: 1.5rem;
    --text-5xl: 1.875rem;
    --text-6xl: 2.25rem;
  }
  .module { padding: var(--space-8) var(--space-4); }
  .pattern-cards { grid-template-columns: 1fr; }
  .flow-steps { flex-direction: column; }
  .flow-arrow { transform: rotate(90deg); }
}
```

---

## Scrollbar & Background

```css
/* Custom scrollbar */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb {
  background: var(--color-border);
  border-radius: var(--radius-full);
}

/* Subtle atmospheric background */
body {
  background: var(--color-bg);
  background-image: radial-gradient(
    ellipse at 20% 50%,
    rgba(217, 79, 48, 0.03) 0%,
    transparent 50%
  );
}

/* Page scroll setup */
html {
  scroll-snap-type: y proximity;
  scroll-behavior: smooth;
}
```

---

## Code Block Globals

All code blocks in the course — whether inside translation blocks, standalone snippets, or quiz challenges — must wrap text and never show a horizontal scrollbar. This is a teaching tool, not an IDE.

```css
pre, code {
  white-space: pre-wrap;       /* wrap long lines */
  word-break: break-word;      /* break mid-word if absolutely needed */
  overflow-x: hidden;          /* no horizontal scrollbar — ever */
}
/* Hide scrollbars on code containers */
.translation-code::-webkit-scrollbar,
pre::-webkit-scrollbar {
  display: none;
}
```

Code snippets must be **exact copies** from the real codebase — never modified, trimmed, or simplified. Instead, choose naturally short (5-10 line) sections from the code that illustrate the concept well. If a longer block is needed, show it all — the wrapping CSS will handle readability.

---

## Syntax Highlighting (Catppuccin-inspired)

For code blocks on the dark `--color-bg-code` background:

```css
.code-keyword  { color: #CBA6F7; }  /* purple — if, else, return, function */
.code-string   { color: #A6E3A1; }  /* green — "strings" */
.code-function { color: #89B4FA; }  /* blue — function names */
.code-comment  { color: #6C7086; }  /* muted gray — // comments */
.code-number   { color: #FAB387; }  /* peach — numbers */
.code-property { color: #F9E2AF; }  /* yellow — object keys */
.code-operator { color: #94E2D5; }  /* teal — =, =>, +, etc. */
.code-tag      { color: #F38BA8; }  /* pink — HTML tags */
.code-attr     { color: #F9E2AF; }  /* yellow — HTML attributes */
.code-value    { color: #A6E3A1; }  /* green — attribute values */
```
