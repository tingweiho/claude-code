# [Company] Palette for Notebooks

Brand-consistent colors for Python notebooks. Mirrors `slides` so notebook exploration visually matches eventual presentation deliverables.

## Core palette (Python hex codes)

```python
# Primary accent
BRAND_GREEN   = "#008F6D"   # Main accent, CTAs, highlighted series
BRAND_GREEN_LIGHT = "#A8E5D7"  # Brand Green 300 — backgrounds, fills
BRAND_GREEN_DARK  = "#06503E"  # Brand Green 700 — text/emphasis on light

# Text + ink
INK            = "#002620"   # Primary text (never pure black #000)
INK_MUTED      = "#749E98"   # Secondary text, captions, tick labels

# Backgrounds + borders
PAGE_BG        = "#FAFBFD"   # Plot background
BORDER         = "#E5EAE9"   # Gridlines, axis spines

# Categorical palette (use in order — designed for ≤7 categories)
CATEGORICAL = [
    "#008F6D",   # Brand Green 500 (primary)
    "#237C90",   # Teal 500
    "#6A28B5",   # Purple 500
    "#941454",   # Pink 500
    "#091460",   # Periwinkle 900 (dark blue)
    "#749E98",   # Neutral 500 (gray)
    "#06503E",   # Brand Green 700 (dark green)
]

# Sequential palette (light → dark Brand Green)
SEQUENTIAL_GREEN = [
    "#EEF6F4", "#D4ECE6", "#A8E5D7",
    "#4CE5C1", "#008F6D", "#056A52",
    "#06503E", "#06372B", "#041F18",
]

# Diverging (red → neutral → green, for change vs baseline)
DIVERGING = [
    "#941454",   # Pink 500 (strong negative)
    "#E0A1C1",   # Pink 300 (mild negative)
    "#F3F5F5",   # Neutral 100 (zero / baseline)
    "#A8E5D7",   # Green 300 (mild positive)
    "#008F6D",   # Green 500 (strong positive)
]
```

## Style principles (matching [Company] slides)

- **Never pure black.** Use `INK` (`#002620`) for text.
- **Never pure white.** Use `PAGE_BG` (`#FAFBFD`) for plot backgrounds.
- **One emphasized series in `BRAND_GREEN`**, rest in `INK_MUTED` — almost always better than 5-7 competing colors.
- **Sequential data** (heatmaps of one variable's magnitude): use `SEQUENTIAL_GREEN` or matplotlib's `viridis` (both color-blind safe). Never `jet` / rainbow.
- **Diverging data** (change vs baseline): use `DIVERGING` with neutral at zero.

## Typography

Match `slides` when possible:
- **Titles:** Instrument Serif (if available; matplotlib fallback: `DejaVu Serif`)
- **Body / labels:** Poppins (fallback: `DejaVu Sans`)
- **Code / numbers in annotations:** JetBrains Mono (fallback: `DejaVu Sans Mono`)

In matplotlib, `assets/aircall_viz.py` sets these fallbacks automatically since most systems don't have Instrument Serif / Poppins installed.

## Pattern: emphasize-one, gray-the-rest

Instead of 7 colored lines:

```python
import matplotlib.pyplot as plt
from aircall_viz import BRAND_GREEN, INK_MUTED

# 7 lines, all gray EXCEPT the one you want to highlight
for segment in all_segments:
    color = BRAND_GREEN if segment == "EMEA" else INK_MUTED
    alpha = 1.0 if segment == "EMEA" else 0.4
    plt.plot(dates, values_by_segment[segment], color=color, alpha=alpha, label=segment)

plt.legend()
plt.title("MRR growth flat — EMEA the exception")
```

The reader's eye goes to green. The gray lines give context without competing.

## Related
- Full brand guidelines + Reveal.js layer: `slides` skill
- Drop-in matplotlib defaults: `assets/aircall_viz.py` (in this skill)
