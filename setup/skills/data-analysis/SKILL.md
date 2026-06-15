---
name: data-analysis
description: Use this skill whenever Ting-Wei is doing any form of data analysis — diagnosing why a metric moved, exploring a new dataset, writing up a report, evaluating an experiment (A/B test or before/after), or building a predictive model. Trigger on phrases like "why did X drop", "what's going on with Y", "did the launch work", "analyze this dataset", "run a QA on the metric", "summarize Q2 numbers", "A/B test result", "did our intervention move the needle", "I see a spike in ___", "churn prediction", or any ad-hoc exploration. This skill enforces the rigor steps that senior data scientists skip under time pressure. Five modes; the router decides which reference to load.
---

# Data Analysis — Rigor Router

Five modes. Each has a reference file with the specific protocol. The SKILL.md body is the router + the universal rigor checks that apply regardless of mode.

## Which mode?

| Scenario | Mode | Reference |
|----------|------|-----------|
| "Why did MRR / churn / CTR drop last week?" | **Diagnostic** | `references/diagnostic.md` |
| "Here's a new dataset, what's in it?" | **Exploratory** | `references/exploratory.md` |
| "Summarize Q2 / write up last week's numbers" | **Descriptive** | `references/descriptive.md` + `internal-comms` skill |
| "Did the experiment / campaign / launch work?" | **Experimental** | `references/experimental.md` |
| "Can we predict which accounts will churn?" | **Predictive** | `references/predictive.md` |

The modes are not mutually exclusive. A diagnostic often starts exploratory; experimental analysis feeds into descriptive write-up. Use them as loading guides, not categories.

## Universal rigor checks (apply to every mode)

These are the things every analysis needs, regardless of type. They're also the things most commonly skipped.

### 1. State the question before you query
Before writing a SQL query or opening a notebook, write the question as one sentence. If you can't, the analysis has no target. "Why did MRR drop" → specific: "MRR dropped 3.2% between W14 and W15 — what fraction of that drop is explained by cohort X vs churn vs downgrade vs logo loss?"

Vague question → garbage answer, every time.

### 2. State expected result before you see the data
Before looking at the query output, write down what you expect. "I expect churn is up because of the Q2 re-contracting cliff." If the data matches your prior, good. If it doesn't, you learned something — resist the urge to post-hoc rationalize.

Without a prior, any result looks plausible. That's how confirmation bias lives.

### 3. Sanity-check the data before the answer
- Row count reasonable? Any silent filter hiding rows?
- Date range correct? (Today's partition is incomplete — see `aircall-data-stack` rule)
- Nulls / sentinels (`-1`, `9999`, `'unknown'`) in the columns you're aggregating?
- Duplicates? (Common cause of metric "spikes")
- Join explosion? (Did your row count jump after a join? One-to-many inflates sums)

**If the data is wrong, every downstream conclusion is wrong.** Five minutes of sanity-checking saves hours of backtracking.

### 4. Effect size, not just direction
"Churn went up" → useless. "Churn went from 2.1% to 2.4%, a 14% relative increase on a base of ~3,000 accounts (≈9 extra churned accounts)" → actionable. Always report:
- Absolute change
- Relative change
- Base rate / denominator
- A confidence interval or MoE when relevant

A big relative change on a small base is often noise.

### 5. Name your assumptions
Every analysis has assumptions. Write them down as part of the writeup:
- Date range selected: X to Y (why?)
- Cohort filter: Z (why?)
- Metric definition: exact SQL or LookML source
- What's excluded: test accounts, internal users, churned customers, etc.

Reviewers catch assumption bugs faster than logic bugs.

### 6. Stop when confidence is low; don't hedge-confidently
If after rigor checks you're only 60% confident in the conclusion, **say so** in the writeup. "The most likely driver is X (moderate confidence); ruling out Y requires data we don't have." Hedging-confidently ("X is probably the cause") reads as confident to stakeholders and erodes trust when wrong.

### 7. Know which question you're NOT answering
Diagnostic: "what caused this" ≠ "what should we do about it". Experimental: "did intervention A work" ≠ "did A work better than B". Keep scope tight; flag follow-ups explicitly.

## When to reach for the reference

You don't need to read a reference to do the three universal checks. Load the reference when:
- The analysis is non-trivial (takes > 1 hour or will go to a stakeholder)
- You're using a mode you do rarely (most likely: experimental or predictive)
- You've done the analysis and want to pressure-test before sending

## Related skills
- `aircall-data-stack` — SQL / dbt / Looker mechanics (where to get the data)
- `internal-comms` — how to write up the results (especially for Descriptive mode)
- `regression-guard` — when the analysis is about an AI feature or deployed system you've built
