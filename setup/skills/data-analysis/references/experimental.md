# Experimental Analysis — A/B Tests & Quasi-Experiments

Use when evaluating whether an intervention (feature launch, campaign, pricing change, AI feature) actually moved the metric. The goal is a **causal claim**, which requires more rigor than diagnostic or descriptive work.

Primary source: Kohavi, Tang, Xu — *Trustworthy Online Controlled Experiments* (2020). Practitioner-grade, ex-Microsoft/LinkedIn/Airbnb. The pitfalls below are from that book plus Aircall context.

## Before running the test

### 1. Define primary metric + guardrails — BEFORE the test
Primary metric: the one thing the test is designed to move. Pick ONE. Two primary metrics = you're testing a vibe, not a hypothesis.

Guardrails: metrics that must NOT degrade even if the primary moves. For most changes at Aircall: churn, customer NPS, revenue, latency, error rate.

A test that moves the primary but tanks a guardrail is a failure, not a win.

### 2. Power analysis — before, not after
How big a sample do you need to detect a realistic effect? Quick estimates:
- For a 5% relative lift on a 10% base rate: ~15K per arm
- For a 2% relative lift on a 10% base rate: ~100K per arm
- For anything smaller: you need a lot of volume, or you're measuring noise

Use an online calculator (Evan Miller, optimizely) rather than hand-computing. **Don't run tests that can't detect the effect you care about** — they waste weeks and produce "not significant" results that mean nothing.

### 3. Pre-register the analysis
Write down, before running:
- Primary metric + direction expected
- Guardrails
- Duration
- Sample size / power
- Segments you'll cut (and NOT cut)
- How you'll handle missing data

**Why:** p-hacking is most often not deliberate — it's post-hoc rationalization. Pre-registering forces honesty.

## Picking the design

### True A/B test (randomized)
- Requires: ability to randomly assign units (users, accounts, sessions) to treatment/control
- Gold standard — if you can run it, run it
- Aircall examples: in-product banner shown or not, AIVA shown to cohort A vs B, feature flag rollout

### Quasi-experimental (when randomization isn't possible)
For changes that affect everyone (pricing change, public launch), you can't A/B. Use:

- **Diff-in-diff (DiD):** compare the change in treatment vs change in a similar control group over the same period. Needs a plausible parallel-trends assumption.
- **Interrupted time series:** one group, before vs after, with enough history to see the pre-trend. Dangerous if other things changed at the same time.
- **Regression discontinuity:** when treatment is assigned by a threshold (e.g. "accounts > $100K ARR get AIVA"). Compare just above vs just below the threshold.
- **Synthetic control:** build a "fake control" from weighted combinations of other segments. Advanced — see Abadie et al.

**Quasi-experimental claims are inherently weaker than A/B.** Be explicit about the assumptions; state what would invalidate the conclusion.

### Before/after (the weakest)
"We launched X on date Y, metric moved after." Not a causal claim without a control. Usable only when everything else is ruled out — seasonality, simultaneous launches, data pipeline changes. Usually insufficient for a decision.

## During the test

### Don't peek and stop early
Looking at results daily and stopping when significant = inflated false positive rate. Either:
- Predeclare a stop time based on power analysis, OR
- Use sequential testing correction (SPRT, alpha-spending) — but only if you know how

Peeking is the single most common cause of false-positive experiment results.

### Watch for sample ratio mismatch (SRM)
If you assigned 50/50 and got 51/49, that's suspicious — randomization should be 50/50. SRM means the assignment is biased and the entire test is suspect. Kohavi devotes a whole chapter to this; it's that common.

### Guardrail monitoring
If a guardrail degrades mid-test, stop. The primary metric result doesn't matter if churn doubled.

## After the test

### 1. Did the primary metric move?
Report point estimate + confidence interval, not p-value alone. "Primary metric: +3.2% ± 1.1% (95% CI)" is informative; "p=0.04" is not.

### 2. Are guardrails intact?
Every guardrail should be reported. Not just the primary.

### 3. Is the effect size practically significant?
Statistical significance ≠ business relevance. A 0.1% lift with p=0.001 on a revenue metric might not justify the feature's maintenance cost. Name the threshold of "interesting" in advance.

### 4. Check segments AFTER, not in primary analysis
Segment cuts are for generating hypotheses, not confirming wins. If the overall is flat but "it won in SMB", that's a hypothesis for the next test, not a victory lap.

### 5. Write down what would have changed your conclusion
"If the primary had moved +X% instead of +3.2%, I would have concluded Y." Forces you to state your priors, makes the next test cheaper.

## Common traps

### Novelty / Primacy effect
Users react to ANY change. The first-week bump can disappear by week 3. Run long enough to see the plateau — or explicitly separate novelty from steady-state.

### Interaction with other experiments
If 5 A/B tests are running simultaneously, users are in multiple cells. If the tests interact, each one's readout is wrong. Coordinate.

### Network / cross-unit effects
Changing behavior for user A may change behavior for user B (teammates, peers). Standard A/B assumes independence — violated in team-based products like Aircall. Cluster-randomize (by account, not by user) when possible.

### Winner's curse
The test with the biggest effect size is most likely to be an overestimate. Subsequent launches tend to regress. Don't bet the P&L on a single-experiment magnitude.

### "We can't A/B this so we'll just launch"
Running any form of comparison (matched cohorts, DiD, time series) is better than no comparison. Default to the weakest valid design rather than none.

## For evaluating AI features you build

When the "intervention" is a prompt change, model bump, or new AI feature (your Website Ops Hub territory):

- Primary metric often: downstream business outcome (ticket resolution time, self-service rate)
- Guardrails: hallucination rate, fallback rate, user complaint rate
- Use `regression-guard` anchors as one layer of signal; experimental comparison on real prod data as the other

The AI-feature evaluation stack:
1. **Anchor diffs** (deterministic regression — `regression-guard`)
2. **Eval set** (offline, labeled — `claude-api` or similar)
3. **Online A/B or gradual rollout** (this skill)

All three, in that order. Don't skip to 3 without 1 and 2.

## Output shape

```
## Experiment: [name]
**Hypothesis**: [what we expected to move, by how much, why]
**Design**: [A/B / DiD / before-after], N = [treatment] / [control], duration [X weeks]
**Primary metric**: [name, pre-declared]

### Results
- Primary: [point estimate] ± [CI], p=[value]
  → [practically significant? yes/no vs threshold]
- Guardrail 1: [change, CI] — [intact / degraded]
- Guardrail 2: ...

### Segments (hypothesis-generating, not confirmatory)
- [cut 1]: [observation]

### Decision
[ship / don't ship / rerun]. Confidence: [high/moderate/low].
Reasons:
- ...

### What would change my mind
[specific future data that would flip the decision]
```
