# Audience Tuning

A chart that's correct for you isn't necessarily correct for your reader. The chart that lands depends on who's reading and what decision they're making.

Adapted from Cole Knaflic's *Storytelling with Data* — but with the reminder that "storytelling" is fine for stakeholder visuals, not for your own EDA.

## Three audiences, three styles

### 1. Yourself, during exploration
- **Goal:** see the data accurately
- **Style:** dense, compact, multiple per cell, no titles needed
- **Annotations:** none — you have the context in your head
- **Tip:** prefer `pd.DataFrame.plot()` for fast iteration over crafted matplotlib

### 2. Your team / DS peers in async review
- **Goal:** convey what you found, enable critique
- **Style:** brand-styled, titled, axis-labeled, source noted
- **Annotations:** mark notable points / events
- **Tip:** include enough that the chart is interpretable without you in the thread

### 3. Stakeholders / leadership
- **Goal:** make a decision faster
- **Style:** large fonts, one chart per slide / message, no clutter
- **Annotations:** the conclusion baked into the chart (title, callouts, highlight color on the relevant series)
- **Tip:** the chart should answer "so what" not just "what". If a stakeholder has to ask "what should I take away from this?", the chart is incomplete.

## The conclusion goes in the title

Compare:

❌ "Q2 MRR by region" — descriptive title, reader does the work
✅ "EMEA growth slowed in Q2 vs other regions" — conclusion title, reader gets the point in 1s

Use descriptive titles for your own EDA, conclusion titles for stakeholder views.

## Cognitive load minimization

For stakeholder charts:
- **Remove every element that isn't pulling weight.** Gridlines too dark? Lighten. Legend covers data? Move or annotate inline. Decimal places nobody can read? Round.
- **One thing per chart.** A single chart that tries to show 3 trends, 2 segments, and a forecast is unreadable. Three charts are better.
- **Pre-attentive attributes** — color, size, position — direct the reader's eye. If everything is bold, nothing is bold. Use sparingly.

## Annotation patterns

When the chart needs to "tell" the reader what to look at:

- **Highlighted series** in BRAND_GREEN, others in INK_MUTED (the emphasize-one pattern)
- **Reference line** for baseline/target, labeled inline (not in a side legend)
- **Event markers** for what changed and when (campaign launch, price change, deploy)
- **Range box** to highlight a notable region of the chart (e.g. shaded gray over the COVID period)
- **Direct labels** on lines (right-side endpoint) instead of a color legend — saves a decoding step

## Don't ship raw EDA charts to stakeholders

A chart that worked for your own exploration almost never works for a stakeholder. Always make a clean second pass:
- Replace 7 colored series with emphasize-one
- Add the conclusion to the title
- Round numbers to what the audience needs (no decimal places for revenue in $M)
- Add source / date footnote for reproducibility
- Save as PNG for embedding (don't share the notebook URL — it bit-rots)

## Aircall context

- **Slack messages** (digest, EOD): use simple, attached PNGs from matplotlib — Slack renders these inline. Skip Plotly for these.
- **Project tracker canvas**: text-only; reference the chart by filename if needed, don't embed
- **Stakeholder readouts (Marie 1-1, leadership briefing)**: 1-2 charts max, each with conclusion titles, paired with a brief written interpretation
- **Slide decks**: use `aircall-slides` for the deck itself; export the chart as PNG and embed
