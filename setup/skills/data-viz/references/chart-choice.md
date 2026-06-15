# Chart Choice

The question comes first, then the chart. This is a practical router, not a taxonomy.

## The question → chart map

| Question | Chart |
|---|---|
| How does one value compare to a few others? | Horizontal bar chart, sorted by value |
| How does a value change over time? | Line chart (1-5 series); small multiples (>5 series) |
| How are two numeric variables related? | Scatter plot; add a smoothed trend line if pattern matters |
| What's the distribution of one variable? | Histogram (unimodal continuous); density plot (smooth); ECDF (for precision); boxplot (comparing many distributions) |
| How does a distribution differ across groups? | Small-multiple histograms, OR violin/boxplot side-by-side |
| How does a total break down into parts? | Stacked bar (not pie); or 100% stacked bar (if ratios matter); or waterfall (if sequential) |
| How do two things change together over time? | Two-line small multiples OR a connected scatter — **not** dual Y-axis |
| How do values differ across two categorical dimensions? | Heatmap (for patterns) or grouped bar chart (for exact values) |
| Is there a geographic pattern? | Map (choropleth for regions, symbol map for points) |
| What's the flow / transition between states? | Sankey diagram, chord diagram |

## Charts to use sparingly or never

### Pie chart
Never needed. A bar chart does the same job better. If you *must* show composition, use a 100% stacked bar. Pies are acceptable only for a literal "3 parts of a whole" with very different sizes (>3× ratio) — and even then, a bar is usually clearer.

### Donut chart
Pie chart with a hole. Same problems.

### 3D anything
Hides data, distorts proportions. The chart library's 3D bar chart is a design mistake pretending to be a feature. Use faceted 2D charts instead.

### Word cloud
Encodes frequency via text size (area — worst rank of visual encoding). Only use for decorative slides, never for analysis.

### Radar / spider chart
Humans read angle and area poorly. A grouped bar chart with categories on X-axis does the same job more legibly.

## Small multiples > overlays

When comparing >3 series (segments, products, regions), don't stack them on one chart with 7 colors. Use **small multiples** — one small chart per series, same scale, laid out in a grid.

**Why:** each individual small chart is readable; the grid makes comparisons scale-consistent; no color legend to decode.

Matplotlib: `plt.subplots(nrows, ncols, sharey=True, sharex=True)`.
Seaborn: `sns.FacetGrid` or `sns.relplot(..., col="segment")`.
Altair: `alt.Chart(...).facet(column="segment")`.

## Chart composition: the inverted pyramid

When a chart has multiple elements (main chart + legend + annotations + source line):

1. **Main data element** — takes the most visual space
2. **Essential context** (title, axis labels) — legible without squinting
3. **Supporting elements** (legend, reference lines, annotations) — present but subordinate
4. **Metadata** (source, date) — small, at the bottom, present for reproducibility

If a legend is bigger than the chart area, the chart is wrong (too many series).

## Common mistakes at senior level

These aren't beginner errors; they're the mistakes experienced analysts make under time pressure.

### Dual Y-axis
Two series on the same chart, each with its own Y axis. Scaling each axis independently lets you align any two trends visually — meaning the chart tells you nothing. If you care whether two things correlate, run a scatter or compute the correlation. Don't imply it visually.

### Bar chart not sorted by value
Alphabetical / chronological sorting on a categorical bar chart hides the ranking that's usually the point. Unless there's a reason (time, ordinal categories), sort by the measured value.

### Too many colors
Brains can track ~5-7 categorical colors at once, fewer if similar hues. If you have 10 series, pick the 2-3 that matter and gray the rest (or use small multiples).

### Starting Y-axis at non-zero on a bar chart
Bar length encodes value. Truncating the axis means the length-to-zero visual is wrong. Line charts can truncate (slope is the encoding, not length-to-zero), but always label clearly.

### Heatmap with rainbow colormap
Rainbow (`jet`, `hsv`) creates false boundaries where the color shifts. Use viridis / plasma / magma for sequential data — they're perceptually uniform and color-blind-safe.

### Missing baseline comparison
"Revenue by region" without "vs plan" or "vs last quarter" or "vs forecast" — every revenue chart needs a reference point. The bar values alone are not the story.

### Log scale without labeling
Log scales are sometimes necessary (highly skewed data). Always label `"Log scale"` on the axis — otherwise readers interpret distances linearly and conclusions will be wrong.

## Reference hierarchy (for the curious)

Cleveland & McGill 1984 ranked visual encodings by perceptual accuracy, from best to worst:

1. Position along a common scale
2. Position along non-aligned scales
3. Length, direction, angle
4. Area
5. Volume, curvature
6. Shading, color saturation

When you can replace a higher-ranked encoding for a lower one (replace area with length, replace color with position), do. This single principle covers most chart-selection decisions.
