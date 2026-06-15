# Diagnostic Analysis — Root Cause

Use when a metric moved and you need to explain why. The goal is *attribution*, not just description.

## The protocol

### 1. Confirm the move is real

Before investigating causes, confirm the change isn't an artifact:

- **Data pipeline delay:** Today's partition incomplete? Look at the same time-of-week in prior weeks — `day_of_week` matters more than raw date for weekly metrics.
- **Definition change:** Did LookML change? dbt model change? Did a column get renamed? `git log` on the dbt model explaining the metric is the fastest way to find this.
- **Segment change:** Did the denominator shift? If MRR/active_accounts looks down, check if `active_accounts` itself changed (accounts churned? segments reclassified?).
- **Seasonality:** Weekly? Monthly? Quarterly? Always plot at least 12 weeks of history, not just the last 2.

**If the "move" evaporates here, stop. Report "not real" and save the day.**

### 2. Size the move in context

- Absolute: X → Y (delta Z)
- Relative: Z%
- Base: how big is the population? Small-denominator effects disappear at 100× scale
- Historical context: is this within the normal week-to-week variance? Compute stddev of recent weeks; if the move is within 1 stddev, it's noise

Rule of thumb: if you're investigating a move smaller than one standard deviation of the metric's recent history, you're chasing ghosts.

### 3. Decompose before explaining

Don't jump to "it's churn" or "it's new logos down". Decompose the metric into its parts first:

**For MRR drop:**
```
Net MRR change = (new MRR) + (expansion MRR) - (contraction MRR) - (churn MRR)
```
Compute each component, week-over-week. The one that moved most is your starting point.

**For CTR drop:**
```
CTR = clicks / impressions
```
Did clicks fall, or impressions rise? Very different stories.

**For active users:**
```
Active = (retained from prior period) + (new) - (churned) + (resurrected)
```

Decomposition is the single most powerful diagnostic move. It turns "MRR dropped" into "expansion MRR dropped in the SMB segment" in one step.

### 4. Segment to localize

Once you know *which component* moved, find *where* it moved:

- By plan tier (Essentials / Professional / Enterprise)
- By geography (NA / EMEA / APAC)
- By segment (SMB / Mid-market / Enterprise)
- By cohort (when did they start?)
- By product feature (who uses AIVA vs not?)
- By channel of acquisition

**The move usually concentrates in 1-2 segments.** If it's uniform across all segments, you're likely looking at a pipeline issue (step 1), not a real business event.

### 5. Correlate with events

What else happened at the same time?
- Price change? Product launch? Campaign end?
- Pipeline/infra issue? Looker outage? Fivetran sync delay?
- External: holiday, competitor move, economic event?

Keep a running log of "what changed when" — a spreadsheet or a wiki page. Most diagnostics end with "oh right, we changed X on date Y, that's it." Having a log turns a 4-hour investigation into 4 minutes.

### 6. Test the causal story

Once you have a candidate cause, stress-test it:

- **Does it explain the size of the move?** If expansion MRR dropped $50K and your candidate cause affects ~$10K of accounts, it's not the whole story.
- **Does it explain the timing?** If the cause started in W12 but the metric moved in W14, there's a gap to explain (delay? threshold effect?).
- **Does it explain the localization?** Your cause should predict which segment was affected.
- **What's the counterfactual?** Is there a segment the cause did NOT affect? Did it stay stable there? If yes → evidence for the cause. If no → something else is going on.

If the story fails any of these, don't stop — either the cause is wrong or incomplete.

## Common traps

### Simpson's paradox
A trend in aggregate can reverse when segmented. If the aggregate shows X went up but every segment shows X went down, the composition shifted. Check segment size change — more segment-A with low X + less segment-B with high X produces this.

### Regression to the mean
A metric that was unusually high or low reverts. If last week was an all-time high, this week's "drop" might just be reversion. Compare to the trailing mean, not the last data point.

### Survivorship bias
"Our best customers have feature X" — may just mean the feature X cohort is older and worse ones churned. Always include the denominator of the entire cohort, not just survivors.

### "We ran a campaign in W14 and X went up in W15, so the campaign worked"
Correlation, not causation. No counterfactual. Classic. Move to experimental analysis if you want a causal claim.

### Stakeholder narrative
The stakeholder has a hypothesis ("I bet it's the Pro plan launch"). You confirm it. That's confirmation bias with extra steps. Always decompose first; the stakeholder's hypothesis is one of several to test.

## Output shape

A good diagnostic writeup has:

1. **TL;DR**: "MRR dropped 3.2% W14→W15. 80% of the drop is in SMB expansion MRR, concentrated in the EMEA region. Most likely cause: campaign ended W13 with no follow-on. Confidence: moderate."
2. **Decomposition table**: components + deltas + contribution %
3. **Segment cut**: localize where the move concentrated
4. **Timeline**: events that coincided
5. **Counterfactual / ruled out**: what it's NOT
6. **Confidence + next steps**: what would increase confidence

Use the `internal-comms` skill for the actual write-up formatting.
