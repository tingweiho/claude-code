# Python Notebook Viz Craft

Library-specific patterns for matplotlib + seaborn (the workhorse stack). Plotly + Altair only when interactivity adds real value — see end of file.

Assumes `apply_aircall_style()` from `assets/aircall_viz.py` has been called at the top of the notebook. All examples use that styling.

## Pattern: emphasize-one, gray-the-rest

Almost always better than 7 colored series. Reader's eye goes to the highlighted line; gray series provide context.

```python
import matplotlib.pyplot as plt
from aircall_viz import BRAND_GREEN, INK_MUTED

for segment in segments:
    is_focus = segment == "EMEA"
    plt.plot(
        df.loc[df.segment == segment, "date"],
        df.loc[df.segment == segment, "mrr"],
        color=BRAND_GREEN if is_focus else INK_MUTED,
        alpha=1.0 if is_focus else 0.4,
        linewidth=2 if is_focus else 1,
        label=segment,
    )

plt.title("MRR growth flat — EMEA the exception")
plt.ylabel("MRR ($M)")
plt.legend()
```

Key moves: bolder linewidth + alpha=1.0 on the focus, lower alpha on the rest. Sometimes drop the legend and annotate the focus line directly.

## Pattern: small multiples (faceting)

When >3 series. Same scale, same axes, one chart per series.

**Seaborn (cleanest):**
```python
import seaborn as sns

g = sns.relplot(
    data=df, x="date", y="mrr",
    col="segment", col_wrap=3,
    kind="line",
    height=2.5, aspect=1.4,
)
g.set_titles("{col_name}")
g.fig.suptitle("MRR by segment", y=1.02)
```

**Matplotlib (more control):**
```python
fig, axes = plt.subplots(2, 4, figsize=(14, 6), sharex=True, sharey=True)
for ax, segment in zip(axes.flat, segments):
    sub = df[df.segment == segment]
    ax.plot(sub.date, sub.mrr, color=BRAND_GREEN)
    ax.set_title(segment, fontsize=10)
fig.suptitle("MRR by segment")
fig.tight_layout()
```

`sharex=True, sharey=True` is critical for visual comparability across panels.

## Pattern: annotated reference lines

Beats writing a paragraph of caveats below the chart.

```python
fig, ax = plt.subplots()
ax.plot(df.date, df.mrr, color=BRAND_GREEN)

# Reference line — average of pre-period
baseline = df[df.date < "2026-04-01"].mrr.mean()
ax.axhline(baseline, color=INK_MUTED, linestyle="--", linewidth=1)
ax.text(df.date.max(), baseline, f" Q1 avg: ${baseline:.1f}M",
        va="center", color=INK_MUTED, fontsize=9)

# Event marker — campaign launch
ax.axvline("2026-04-15", color=INK_MUTED, linestyle=":", linewidth=1)
ax.text("2026-04-15", df.mrr.max(), " Campaign launch",
        rotation=90, va="top", color=INK_MUTED, fontsize=9)
```

## Pattern: sort bar charts by value

```python
counts = df.groupby("segment").size().sort_values(ascending=True)
ax.barh(counts.index, counts.values, color=BRAND_GREEN)
ax.set_xlabel("Tickets")
ax.set_title("Ticket volume by segment")
```

`ascending=True` on horizontal bars puts the longest at the top — the most-visible position.

## Pattern: distribution comparison

When comparing distributions (not summary stats) across groups:

```python
import seaborn as sns

# Violin: shows distribution shape
sns.violinplot(data=df, x="plan", y="mrr_per_seat",
               palette=CATEGORICAL, inner="quartile")

# Or strip + box: shows individual points + summary
sns.stripplot(data=df, x="plan", y="mrr_per_seat",
              palette=CATEGORICAL, alpha=0.4, jitter=0.25)
sns.boxplot(data=df, x="plan", y="mrr_per_seat",
            palette=CATEGORICAL, showfliers=False, width=0.5)
```

A box-only plot hides bimodal distributions. Use violin or strip when shape matters.

## Pattern: heatmap with sequential color

```python
import seaborn as sns

# Aggregate to a pivot
pivot = df.pivot_table(index="month", columns="plan", values="mrr", aggfunc="sum")

sns.heatmap(
    pivot,
    cmap="viridis",       # or SEQUENTIAL_GREEN custom cmap
    annot=True, fmt=".1f",
    cbar_kws={"label": "MRR ($M)"},
    linewidths=0.5, linecolor=BORDER,
)
```

Use `viridis` / `plasma` / `magma` for sequential. Use `RdBu_r` for diverging (centered on a baseline).

## Anti-patterns to grep for

If your code contains any of these, reconsider:

- `plt.pie(...)` — almost always replaceable by sorted horizontal bar
- `cmap='jet'` or `cmap='hsv'` or `cmap='rainbow'` — perceptually misleading; use viridis
- Two `ax.plot()` calls + `twinx()` — dual Y-axis; use small multiples
- `figsize=(20, 4)` for a chart with 50 categorical x-ticks — use horizontal bar
- `for col in df.columns: plt.plot(df[col])` — uncontrolled multi-series; emphasize one and gray the rest

## When to reach for Plotly / Altair

Default to matplotlib. Reach for interactive only when:

1. **Many points + need to identify outliers** — Plotly scatter with hover beats matplotlib + manual annotation
2. **Time series with many dated events** — interactive zoom helps
3. **Stakeholder dashboards in Hex** — Hex's chart cells use Plotly under the hood; same data, different rendering layer

Don't use interactive for:
- Anything in a static report (PDF, slide deck)
- Final EOD/morning digest charts (Slack doesn't render interactive)
- Charts going into the canvas (same)

When you do reach for Plotly:

```python
import plotly.express as px
fig = px.line(df, x="date", y="mrr", color="segment",
              color_discrete_sequence=CATEGORICAL)
fig.update_layout(
    plot_bgcolor=PAGE_BG, paper_bgcolor=PAGE_BG,
    font=dict(family="Poppins, sans-serif", color=INK),
    title="MRR by segment",
)
fig.show()
```

For Altair, similar concepts — `alt.Color(..., scale=alt.Scale(range=CATEGORICAL))`.
