# Data Model Regression Checks (dbt)

A lighter-weight set since dbt already provides strong guardrails and you've said this is less of a pain point. Still worth codifying the minimum.

## What dbt already protects you from

- **Schema tests** (`unique`, `not_null`, `accepted_values`, `relationships`) — run every time, cheap. These exist because writing them once catches 90% of "silently wrong" data issues.
- **Deferred state** — `--defer --state target_production` means upstream models stay stable while you only rebuild the ones you changed. Prevents "I broke an upstream I didn't mean to touch."
- **`dbt run` failure stops `dbt test`** — if the build itself doesn't succeed, tests don't run on stale data.

## What dbt doesn't protect you from

### 1. Downstream breakage (silent)
You rename a column or change its type in a `marts/` model. Three Looker dashboards and an operational alert downstream depend on the old shape. `dbt run` passes. Looker starts erroring the next morning.

**Check:** before modifying any column in a mart, run a downstream search:
```bash
# Find anything that references the column
grep -r "<column_name>" dbt-models/models/
grep -r "<column_name>" ../looker-repo/  # if you have access
```

If there's downstream usage, either preserve the old column as a deprecated alias temporarily, or coordinate the change.

### 2. Distribution shift (values change, schema doesn't)
Your change affects what rows match a filter. Row count stays similar, tests pass, but the MIX has shifted. Downstream metric quietly moves 8%.

**Check:** for any change that touches filter logic or joins, compare aggregate distributions before/after:
```sql
-- Before change
select segment, count(*) from my_model group by segment;
-- After change (on the dev build)
select segment, count(*) from my_dev_build group by segment;
-- Diff the two — shifts > 5% worth a manual look
```

### 3. The "today data is incomplete" trap
You run QA using today's partition. Numbers look wrong. You spend an hour debugging. It's actually fine — Fivetran hasn't finished syncing today.

**Check:** always QA against `extract_date <= current_date - 1`. This is already a rule in `aircall-data-stack/references/dbt.md`. The reminder here: if a number looks weird, check the date filter *first*.

### 4. Incremental model state drift
Incremental models build on their own prior output. A change to the logic only applies to NEW rows — old rows keep their old shape. Two rows with different shapes now coexist.

**Check:** after changing an incremental model, do a full-refresh once (`dbt run --full-refresh --select <model>`) to rebuild historical rows with the new logic. Alternately, add a migration to update old rows.

## Minimum smoke set for dbt changes

Before merging a PR that touches dbt:

1. `dbt run --select <changed_models>+ --defer --state target_production --target production_etl` succeeds (your change + downstream)
2. `dbt test --select <changed_models>+ --defer --state target_production --target production_etl` passes
3. If the model is incremental, a `--full-refresh` also succeeds (on dev target, not prod)
4. Row count of the target table before vs after change is within expected range (often: same, or within ±1%)
5. If the change is on a mart, no downstream Looker dashboards error out (spot-check the top 3 dashboards that use the table)

## Why the data-modeling side is easier

- Models are (mostly) pure SQL — deterministic, reproducible
- The test surface is narrow: schema tests + row counts + distributions
- Tooling is mature: `dbt test`, `dbt compile`, CI
- Production runs happen on a schedule, so failures show up in monitoring not user reports

The fact that this reference is shorter than the Slack one is the point — don't over-engineer the already-protected side.
