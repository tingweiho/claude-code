# Exploratory Analysis — EDA Protocol

Use when you've got a new dataset and you don't know what's in it. The goal is *understanding shape and quality*, not conclusions. Conclusions come later — usually in a diagnostic or experimental pass.

Rooted in Tukey's EDA (`The Future of Data Analysis`, 1962) and Wickham's modern restatement in *R for Data Science*.

## The protocol

### Phase 1: Shape

Before anything else, understand what you're holding.

- **Rows and columns:** how many? If it's billions of rows, your tooling matters. If it's 200, statistical inference is shaky.
- **Grain:** what does one row represent? One customer? One event? One customer-day? Misunderstanding grain is the #1 source of EDA errors.
- **Time range:** oldest to newest record. Does the range match what you expected?
- **Primary key candidates:** which columns uniquely identify a row? If no combination does, the table has duplicates — investigate before aggregating.

### Phase 2: Quality

- **Null rates per column:** any column >30% null is either optional or broken. Know which.
- **Outliers:** for numeric columns, compute p1, p50, p99. If p99 is 1000× p50, investigate — is it a unit mixup (cents vs dollars)? Log scale needed?
- **Enum cardinality:** for categorical columns, how many distinct values? A column named `country` with 500 distinct values has noise (typos, locales, "N/A").
- **Date sanity:** any future dates? Dates before 1970? Obvious sentinel values (`1900-01-01`, `9999-12-31`)?
- **Dupe check:** group by your suspected primary key, count > 1. If any, the table has duplicates.

### Phase 3: Distributions

For each variable that matters:
- Plot it. Histogram for numeric, bar chart for categorical.
- Note the shape: normal, log-normal, power-law, bimodal, uniform?
- Tails matter. A right-skewed distribution means means ≠ medians — use both.

For cross-variable relationships:
- Scatter plot or 2D binning for two numerics.
- Boxplot-per-category for numeric × categorical.
- Heatmap for two categoricals.

Don't jump to correlation coefficients without looking at the plot first. Anscombe's quartet — four datasets with identical summary stats and wildly different shapes — is the classic warning.

### Phase 4: Build a dataset "dictionary"

By the end of EDA, write down (in a scratch markdown or notebook cell):

```
## Dataset: <name>
- Grain: one row per <X>
- Primary key: (col1, col2)
- Time range: YYYY-MM-DD to YYYY-MM-DD
- Row count: N
- Notable columns:
  - col1: type, range, null rate, distribution shape, what it means
  - col2: ...
- Quality issues found:
  - <col>: high null rate, investigate
  - <col>: outliers above 99.9th pctile
- Open questions:
  - Why do 12% of rows have NULL for X? Definition or data issue?
```

This dictionary is the handoff to any subsequent analysis — diagnostic, experimental, descriptive. Without it, every follow-up analysis re-does EDA.

## Common traps

### "Let me just look at averages"
Averages hide distribution shape. Bimodal distributions have no meaningful mean. Always plot before averaging.

### Today's partition
If the dataset is date-partitioned and today's partition is loading in parallel, you'll get apparent "drops" that are artifacts. Filter to complete partitions only.

### Ignoring the grain
You aggregate `revenue` thinking one row = one customer, but it's one row = one invoice line. Your sums are inflated by N line items per customer. Always verify grain before aggregating.

### Over-investing in plots nobody will see
EDA outputs are disposable. The dictionary + key plots are the deliverable. Don't polish every chart.

### Inferring causation from EDA
EDA is descriptive, not causal. "Churned accounts have fewer logins" — could be cause, effect, or spurious. EDA identifies the question; diagnostic or experimental analysis answers it.

## When to stop

EDA is done when you can write the dataset dictionary confidently AND you've identified the 1-3 columns / relationships that matter for whatever comes next. If you're still "just exploring" after a few hours, you've lost the thread — pick a real question and switch to diagnostic mode.

## Related Aircall-specific tricks

- **dbt `schema.yml` as a cheat sheet:** if the table is a dbt model, `models/schema.yml` often documents grain + column semantics. Start there before generating your own dictionary.
- **Fivetran partition lag:** for any raw `fivetran_*` schema table, filter `extract_date < current_date` to skip partial today data.
- **Looker LookML definitions:** for any business metric (MRR, churn, etc.), the LookML definition is the canonical source — don't re-derive in SQL.
