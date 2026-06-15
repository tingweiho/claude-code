# Descriptive Reporting

Use when the ask is "summarize Q2", "give me the numbers for last week", "write up the monthly review". The analysis is mostly done; the output is the deliverable.

This reference is deliberately thin because **the writeup is the hard part, not the analysis.** For formatting/structure, use the `internal-comms` skill (installed from Anthropic, covers 3P updates, status reports, newsletters, leadership updates).

## The descriptive rigor checks

Even for "just the numbers", these catch most errors:

### 1. Pick one metric definition and stick to it
"MRR" can mean ARR/12, or billed MRR, or contracted MRR, or net new MRR. Different Looker dashboards use different definitions. Pick one, cite the source (LookML path or dbt model), and use it consistently throughout. Inconsistent definitions mid-report are the #1 trust-killer.

### 2. Show the comparison frame
Raw numbers without context are useless. Always include at least one comparison:
- Prior period (WoW, MoM, QoQ, YoY)
- Target / plan
- Forecast
- Benchmark (last year's same period, peers, etc.)

"MRR was $12M in Q2" → unreadable. "MRR was $12M in Q2, +8% QoQ and +22% YoY, vs $11.5M plan (+4%)" → complete.

### 3. Lead with the TL;DR
The executive audience will read the first sentence and maybe the first paragraph. Front-load the conclusion:
> "Q2 was on plan: MRR +8% QoQ, driven by Pro tier expansion in EMEA. Main risk is Q3 re-contracting cliff (∼$300K at risk)."

Then supporting detail. This mirrors the inverted pyramid — news style.

### 4. Distinguish signal from noise
If a WoW number wiggled by 0.5%, don't write it up as a change. Say "stable" or "flat within normal variance". Calling out every wiggle trains readers to ignore your reports.

### 5. Name the composition when the total isn't the story
"Revenue was $X" often hides the real story — growth in new logos vs expansion, or regional mix shift. Descriptive reporting should decompose the total when the decomposition changes the interpretation.

## Common traps

- **Quoting without the base:** "Churn doubled!" is meaningless without "from 0.1% to 0.2% on a base of 3,000 accounts". See §4 of the universal rigor checks.
- **Forgetting the denominator shifted:** If % active users changed, was it the numerator or denominator that moved?
- **YoY without seasonality:** Comparing Q2 to Q1 is misleading if Q2 is always seasonally up.
- **Dashboard-of-dashboards:** A report that's just a bunch of tiles with no interpretation is not a report. Interpret.

## Handoff to internal-comms

Once the numbers are right:
- For **leadership updates** → use the `internal-comms` skill's leadership-update template
- For **3P / weekly updates** → use the 3P (Progress, Plans, Problems) format
- For **newsletters / wider audience** → use the newsletter template

The descriptive analysis produces the numbers + narrative points; `internal-comms` handles the final structure and voice.

## A useful pattern for metric reviews

```
## [Metric] — Q2 2026

**TL;DR**: [one sentence — where did we land, vs what]

**Context**
- Q1 actual: $X | plan: $Y
- Q2 plan: $Z
- Q2 actual: $W

**What changed and why**
- [top driver 1 with effect size]
- [top driver 2 with effect size]

**Composition** (where the total came from)
- [segment 1: $X (share%) — note]
- [segment 2: ...]

**Risks / callouts**
- [thing that could affect next quarter]

**Methodology**
- Definition source: [LookML path or dbt model]
- Date range: YYYY-MM-DD to YYYY-MM-DD
- Exclusions: [test accounts, etc.]
```

This template is reusable across any metric review. Adjust sections based on what the audience needs.
