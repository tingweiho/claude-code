# Predictive Modeling

Use when the task is "predict X" — churn prediction, upsell scoring, lifetime value, segment classification, demand forecasting. This reference is intentionally lean; go deeper in the literature when you're actually building a model in production.

Primary sources for deeper work:
- Géron — *Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow* (practical)
- Hyndman & Athanasopoulos — `fpp3` (time-series forecasting specifically)
- Gelman et al. — *Regression and Other Stories* (interpretable modeling done right)

## When to reach for modeling (and when not to)

Modeling is appropriate when:
- You have labeled examples (churned vs not, converted vs not) at sufficient scale (hundreds per class minimum, thousands preferred)
- The decision the model feeds is actually different from what you'd do with a simple rule
- You can measure model performance against a real-world outcome

Modeling is NOT appropriate when:
- You're really doing segmentation / cohort analysis (use SQL + rules)
- The label is rare (<1% base rate with <1000 positive examples → high variance, unreliable)
- You could achieve 80% of the value with a 3-line rule ("high-value accounts that haven't logged in for 30 days")

**A logistic regression on 5 features you can defend beats an XGBoost on 50 features you can't.**

## The minimum rigor

### 1. Train/validation/test split — correctly
- Random split is fine for cross-sectional data
- **Time-based split is mandatory for any time-dependent target** (churn, forecasting). Training on future data to predict past is the #1 data-science fraud
- Leakage check: any feature that uses the target's own future values? `days_until_churn` leaks. `total_ltv` often leaks if computed post-hoc.

### 2. Baseline — always
Before any model, compute the baseline:
- Majority-class predictor (if 95% don't churn, always predict "no churn" → 95% accuracy)
- Simple rule (e.g. "predict churn if usage dropped > 50% last 30 days")

If your fancy model beats baseline by 2%, the complexity isn't justified.

### 3. Metric appropriate to the problem
- **Balanced classification:** accuracy
- **Imbalanced classification** (churn, fraud): precision, recall, F1, precision-at-k, or AUC-PR (NOT AUC-ROC — misleading for imbalanced data)
- **Regression:** RMSE (if errors are symmetric), MAE (if outliers are large), MAPE (if percentage interpretation matters)
- **Ranking (recommend top K):** NDCG, precision-at-k

Use the metric that matches how the model will be used. An account-prioritization model that gets read as "top 100 at-risk accounts" is a ranking problem — optimize for precision-at-100, not AUC.

### 4. Calibration
For classification models, the predicted probability should mean what it says — if the model says 30%, that cohort should actually churn at 30%. Plot reliability diagrams. Uncalibrated probabilities that are used as probabilities (e.g. feeding into expected-value calcs) cause silent downstream errors.

### 5. Explainability, at minimum for top drivers
You don't need SHAP plots in a status email, but you need to be able to answer "why does the model predict this account will churn?" — at least for the top-10 highest-risk rows. SHAP, permutation importance, or even coefficients of a logistic regression all serve.

Stakeholders who don't trust the model won't act on it.

### 6. Monitor post-deployment
Models decay. Drift in input distributions, concept drift in the relationship, seasonality — all change performance over time. Minimum monitoring:
- Input feature distributions vs training
- Prediction distribution vs training
- Realized outcome vs prediction (for recent cohorts that have "closed out")

Retrain cadence depends on drift rate. Quarterly is a common starting point.

## Common traps

### Data leakage
Any feature that wouldn't be available at prediction time is leakage. Classic example: "average_revenue_last_90_days" computed using data from AFTER the prediction date. Always ask: if I had to predict *tomorrow*, could I compute this feature today?

### Overfitting to the validation set
Running 50 model variants and picking the best on validation → you've overfit to validation. Use a held-out test set that you don't touch until the end.

### The "99% accuracy" trap
On rare-event classification, always-predict-negative gives 99% accuracy. Your 99.3% model is 0.3% better than useless. Always report precision + recall (or confusion matrix) for imbalanced problems.

### Correlation ≠ causation (modeling edition)
A model that predicts churn well does NOT tell you how to reduce churn. The features it uses are correlates, not levers. "Accounts that churned used less" doesn't mean "if we push them to use more, they won't churn".

### Temporal leakage in retrospective data
You're training on "at-risk accounts as of Jan 1" and their "churned by March 1" outcome. But you're also using features like "NPS score from Feb 15" — data from the future. Feature dates must be strictly before the prediction date.

## For Aircall specifically

- Most "predictive" asks end up being better served by **rule-based alerts** (dbt model flagging accounts matching criteria) + **human review**, not an ML model in production
- If you build a model, consider Hex as the iteration environment (see `hex` skill)
- Long-running predictive models that haven't been retrained in 6+ months should be assumed broken until proven otherwise

## Output shape

```
## Model: [name]
**Problem**: [predict X for Y at Z decision point]
**Used to decide**: [what business action]

### Data
- Training window: [dates], N = [rows]
- Test window: [dates], N = [rows]
- Label base rate: [%]
- Key features: [top 5]

### Baselines
- Majority class: [metric]
- Simple rule: [metric]
- Model: [metric]

### Performance
- Primary metric: [value], 95% CI [range]
- Calibration: [plot summary]
- By segment: [any notable differences]

### Top drivers (interpretability)
- Feature 1: [coefficient / SHAP summary]
- ...

### Risks / caveats
- [known limitations]
- [when to retrain]
- [distribution shifts to watch]
```
