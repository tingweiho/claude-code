---
name: data-viz
description: Use this skill whenever Ting-Wei is making a chart, plot, or visualization in a Python notebook (Jupyter, VS Code, Hex) — whether for exploration, a diagnostic deep-dive, a stakeholder readout, or a dashboard. Trigger on phrases like "plot this", "visualize", "chart", "make a graph", "show the distribution", "compare these segments", "why does this look weird", or on seeing matplotlib/seaborn/plotly/altair code that's being iterated on. Covers chart selection (the Cleveland-McGill hierarchy), [Company] brand-consistent styling for notebooks, and the craft-level mistakes senior DS still make (dual Y-axes, rainbow palettes, bad color on sequential data). For presentation decks use `aircall-slides`; for Hex-specific cell mechanics use `hex`.
---

# Data Visualization

The goal: charts that are **accurate, readable, and brand-consistent**. Not pretty. Pretty is downstream of accurate + readable.

## Load the right reference for the task

| Task | Reference |
|------|-----------|
| "Which chart type for this question?" | `references/chart-choice.md` |
| "Notebook style doesn't match brand / looks inconsistent" | `references/palette.md` + `assets/viz_defaults.py` |
| "I'm writing matplotlib/seaborn and it looks bad" | `references/python-craft.md` |
| "This chart is technically correct but not landing" | `references/audience-tuning.md` |

## The 5 non-negotiables

These are the rules that catch 90% of viz mistakes regardless of library, chart type, or audience.

### 1. Pick the chart for the question, not the data
"I have a time series" → doesn't tell you what chart to use. "I want to show the trend direction and magnitude of MRR over Q2" → line chart with marked inflection points. "I want to show the distribution of MRR changes per account" → histogram or violin. Same data, different questions, different charts.

See `references/chart-choice.md` for the mapping.

### 2. Encode with position or length; avoid area and angle
Cleveland & McGill (1984) ranked the accuracy of visual encodings:
1. **Position along a common scale** (scatter, bar chart baseline) — most accurate
2. **Position along non-aligned scales** (small multiples)
3. **Length** (bars — encode values via bar height, not via area)
4. **Angle / slope** (pie chart, line chart slope)
5. **Area** (bubble charts)
6. **Color saturation / hue** — least accurate

Translate: **bars beat pies, every time.** If you find yourself reaching for a pie chart, stop and use a bar chart ordered by value.

### 3. Don't lie with axes
- Truncated Y-axis on bar charts is misleading (bars are length-encoding — length-to-zero is the visual meaning). Truncated Y on line charts is sometimes OK but flag it.
- **Dual Y-axes are almost always misleading.** Two lines on different scales let you align any two trends. Use small multiples instead.
- Log scales are fine — label them clearly (`"Log scale"` on the axis label).

### 4. Color is a language, not decoration
- **Categorical data:** distinct hues (≤ 7 — beyond that, nobody can tell them apart)
- **Sequential data** (e.g. heatmap of values): a single-hue gradient (light → dark blue, not rainbow)
- **Diverging data** (e.g. change vs baseline): two-hue gradient with a neutral middle (blue-white-red)
- **Never rainbow** (`jet`, `hsv`) for sequential data — it creates false boundaries and confuses color-blind readers
- **Emphasis by color:** one highlighted series in brand green, the rest in a neutral gray. Almost always better than 7 competing colors.

### 5. Title, axis labels, units, source
Every chart leaves the notebook with:
- A **title** that states the conclusion, not the topic. "MRR flat Q2" > "Q2 MRR".
- Titles are **always center-aligned** — never left-aligned. Most libraries default to left; override explicitly:
  - Matplotlib: `apply_aircall_style()` below sets `axes.titlelocation = "center"`. `plt.suptitle(...)` is centered by default.
  - Altair: `.properties(title=alt.TitleParams(text="...", anchor="middle"))`.
  - Plotly: `fig.update_layout(title=dict(text="...", x=0.5, xanchor="center"))`.
- Axis labels with **units** ($, %, count).
- Source / query date in a footnote or caption — enables reproducibility.

If a chart can't survive being screenshot and shared without context, it's incomplete.

### 6. No gridlines by default
Clean plots beat gridded ones. The matplotlib helper in `assets/viz_defaults.py` turns gridlines off; Altair and Plotly recommendations below do the same.

Turn gridlines ON only when the reader genuinely needs to read values off the chart (dense scatter with reference lines, cohort heatmap with numeric thresholds). When you do enable them, use `axis='y'` only, with a light `BORDER`-coloured line at low alpha. Never both axes.

## Library choice — default to modern

Ting-Wei dislikes the default matplotlib/seaborn look. Reach for these instead:

| Library | When |
|---------|------|
| **Altair** (Vega-Lite) | Default for most charts — cleanest defaults, concise grammar, faceting, linked brushing. |
| **Plotly** | Complex charts matplotlib can't do cleanly: sankey, sunburst, treemap, parcoords, choropleth, 3D. Also when a stakeholder dashboard genuinely benefits from hover/zoom. |
| **Great Tables** | When the right answer is a styled table, not a chart (KPI summaries, cohort grids, Slack canvas embeds). |
| **Lets-Plot** | ggplot-style faceted figures when Altair's grammar feels too verbose. JetBrains-backed, actively developed. |
| **marimo** | When building a reactive exploratory dashboard you'd otherwise ship as a Streamlit app. |
| **matplotlib / seaborn** | Only when an existing notebook already uses it, or when you specifically need raster output with full layout control. Apply `assets/viz_defaults.py` styling below. |

**Rule out by default:** Bokeh (dated layout API), plotnine (Lets-Plot is more polished), PyGWalker (Tableau clone, not for crafted outputs).

### No gridlines — applies to every library

- **Matplotlib:** `apply_aircall_style()` (below) sets `axes.grid = False`. Don't re-enable unless the chart needs it.
- **Altair:** `.configure_axis(grid=False)` on every chart, or apply once via `alt.themes.register` + `alt.themes.enable`.
- **Plotly:** `fig.update_xaxes(showgrid=False).update_yaxes(showgrid=False)` or set via a custom template.

## Matplotlib/seaborn drop-in styling (when you must)

The skill includes `assets/viz_defaults.py`. At the top of any notebook:

```python
import sys
sys.path.insert(0, '/Users/tingwei/.claude/skills/data-viz/assets')
from viz_defaults import apply_aircall_style

apply_aircall_style()
```

This sets matplotlib defaults to [Company] brand (Brand Green accent, Neutral grays, Poppins-style sans-serif, clean tick marks, **no gridlines**). Your next `plt.plot()` / `sns.lineplot()` inherits the style. See `references/palette.md` for the palette details.

## Craft gotchas — render before declaring done

Specs lie. A chart that looks right in code overlaps, clips, or overflows on screen. Render at real notebook width before shipping.

### Titles are bold unless you override
Every library defaults to bold. On [Company] brand (no bold body copy), bold titles shout.
- **Altair:** set `fontWeight='normal'` in the theme's `title` config.
- **Plotly:** passing a font family falls back to the bold weight on most systems. Set `font=dict(size=13)` and verify visually.
- **Matplotlib:** not bold, but default `fontsize=10` is tiny. `apply_aircall_style()` bumps it.

### Bar labels collide when label width > bar width
Symptom: `"5 (6.1%)"` at three adjacent bars renders as `"5 (65%)(65%)(6.1%)"`.

Fix, in order of preference:
1. **Shorten the label** (drop the `(6.1%)` — the y-axis already shows count).
2. **Widen the bars** — Altair `mark_bar(size=52)`, Plotly `bargap=0.2`.
3. **Stagger vertically** with alternating `dy` — only when options 1–2 aren't available.

### Don't double-encode
If the y-axis shows count, don't label bars with count too. Either drop the label or make it convey what the axis can't (share %, cumulative, segment name). Every visual element earns its pixels.

### Test with your longest category label
`"Sales Activities"` does not fit in a 50px cell. Decide:
1. **Widen cells** — best when categories are few.
2. **Rotate** (`labelAngle=-30`) — only when cells must stay narrow.
3. **Abbreviate** — last resort; signal loss.

### Heatmap: min cell size ≈ 40×40 px
Numeric labels need ≥ 10px font. And swap text colour to white when cell fill crosses ~55% of the gradient — below that, dark text on dark fill disappears:
```python
alt.condition('datum.pct > 55', alt.value('#FFFFFF'), alt.value(INK))
```

### Notebook rendering dependencies
- **Plotly → `nbformat`.** Without it: `ValueError: Mime type rendering requires nbformat>=4.2.0`. Add to the pip line.
- **Plotly → `ipywidgets`** for some hover interactions. Install alongside.
- **Altair `width='container'`** needs Vega-Embed container setup that notebooks don't provide. Symptom: `Unrecognized signal name: "container"`. Use fixed pixel width or `continuousWidth` in the theme.

### Use `%pip`, not `!pip`
`!pip` runs against `$PATH`'s Python; `%pip` runs against the **kernel's** Python. When they differ (they usually do), `!pip` installs silently to the wrong env and imports fail. Always `%pip` in cells.

### Stacked-bar totals: light, not bold
Totals above stacks are reference, not the finding. Regular weight, 10–12pt. Bold totals fight the title and the stacks for attention.

### Match cells by ID, not by substring
Scripted `'plotly' in source` matches any cell mentioning plotly — including `import plotly` in setup. Match on cell `id` or a precise signature like `'go.Bar(' in source`. Otherwise you overwrite the wrong cell.

## Library-specific theme starters

Drop these at the top of any notebook to get consistent [Company]-brand defaults without per-chart styling.

### Altair theme
```python
import altair as alt
def aircall_theme():
    return dict(config=dict(
        background='#FAFBFD',
        font='Poppins, Helvetica Neue, sans-serif',
        title=dict(fontSize=13, color='#002620', anchor='start',
                   fontWeight='normal', offset=8),  # left-anchor + normal weight
        view=dict(stroke=None, continuousWidth=720, continuousHeight=300),
        axis=dict(grid=False, domain=True, domainColor='#E5EAE9', domainWidth=0.8,
                  labelColor='#749E98', titleColor='#002620', tickColor='#E5EAE9',
                  tickSize=0, labelPadding=6, titlePadding=10,
                  labelFontSize=10, titleFontSize=11),
        legend=dict(labelColor='#002620', titleColor='#002620',
                    orient='top', direction='horizontal',
                    labelFontSize=10, titleFontSize=11),
    ))
alt.themes.register('aircall', aircall_theme)
alt.themes.enable('aircall')
```

### Plotly defaults
```python
import plotly.graph_objects as go
PLOTLY_DEFAULTS = dict(
    plot_bgcolor='#FAFBFD', paper_bgcolor='#FAFBFD',
    font=dict(family='Poppins, Helvetica Neue, sans-serif', color='#002620'),
    title=dict(x=0.0, xanchor='left', font=dict(size=13, color='#002620')),
    xaxis=dict(showgrid=False, zeroline=False, tickfont=dict(color='#749E98')),
    yaxis=dict(showgrid=False, zeroline=False, tickfont=dict(color='#749E98')),
    legend=dict(orientation='h', yanchor='bottom', y=1.08, xanchor='left', x=0.0,
                font=dict(color='#002620', size=11)),
    margin=dict(l=60, r=20, t=80, b=40),
    bargap=0.25,
    hovermode='x unified',
)
# Use: fig.update_layout(**PLOTLY_DEFAULTS)
```

Prefer the Altair theme over per-chart `.configure_*` calls — one registration covers every chart in the notebook.

## Related skills
- `aircall-slides` — brand-exact visuals for presentations (same palette, Reveal.js layer)
- `hex` — Hex-specific cell types, dashboards for stakeholders
- `data-analysis` — the "what to analyze" skills; this skill handles the "how to show it"
