---
name: gitlab-cli
description: >
  Programmatically interact with GitLab from the command line via the `glab` CLI. Manage merge
  requests, CI/CD pipelines and jobs, repositories, issues, releases, and project variables for
  your GitLab repos. Use as the fallback whenever the claude.ai GitLab MCP
  connector is unavailable or its OAuth flow fails ("requested scope is invalid").
allowed-tools: Bash(glab:*) Bash(jq:*)
---

# GitLab CLI (`glab`) -- Agent Skill

The `glab` CLI manages GitLab merge requests, pipelines, jobs, repos, issues, and releases from the command line. Use it to review and comment on MRs, watch CI/CD pipelines, inspect job logs, and automate repo workflows — entirely over the GitLab REST API with a personal access token, no browser OAuth.

**Why this exists:** the claude.ai GitLab MCP connector's OAuth flow can fail with "The requested scope is invalid, unknown, or malformed" (an OAuth app / SSO scope mismatch on gitlab.com). `glab` sidesteps that completely. This skill is the durable path for GitLab work; for broader dbt/Redshift/Looker context see your data stack skill.

Always pass `-F json` (or `--output json`) when you need to parse output programmatically; pipe through `jq`. Text mode is for human display only.

## Prerequisites

Before running any command, verify authentication:

```bash
glab auth status
```

Expected: `✓ Logged in to gitlab.com as <user>`, API over HTTPS. If not logged in, the user creates a Personal Access Token at https://gitlab.com/-/user_settings/personal_access_tokens (scope `api`, plus `write_repository` for HTTPS push), then logs in — have THEM run it with the `!` prefix so the token never passes through the agent:

```bash
glab auth login --hostname gitlab.com --token glpat-XXXX
```

The token is persisted to `~/Library/Application Support/glab-cli/config.yml` (plaintext) and survives across sessions. No env var needed. If a token is ever pasted into chat, tell the user to revoke and reissue it.

### Repo targeting

Inside a cloned repo, `glab` auto-detects the project from the git remote — no `-R` needed. Outside a repo, or to target another project, pass `-R owner/group/repo` (the `OWNER/group/repo` path).

## Global flags

| Flag                | Description                                  |
| ------------------- | -------------------------------------------- |
| `-R, --repo <path>` | Target repo as `OWNER/REPO` (or full URL)    |
| `-F, --output json` | JSON output (for scripting; pipe to `jq`)    |
| `-h, --help`        | Help for any command / subcommand            |

## Command reference

Top-level commands most relevant to Aircall data work: `mr`, `ci`, `job`, `repo`, `issue`, `release`, `variable`, `api`, `auth`, `config`. (Others exist: `alias`, `label`, `milestone`, `schedule`, `search`, `snippet`, `ssh-key`, `token`, `user`.)

### mr — merge requests

```bash
glab mr list [--mine] [--author <user>] [--label <l>] [--draft] [-F json]
glab mr view <id|branch> [--comments] [-F json]   # title, body, pipeline, discussions
glab mr diff <id|branch>                           # view the change
glab mr create [--fill] [--draft] [--target-branch main] [--title ..] [--description ..]
glab mr update <id|branch> [--ready] [--draft] [--title ..] [--description ..]
glab mr note <id|branch> -m "comment text"         # post a comment / review note
glab mr approve <id|branch>
glab mr checkout <id|branch>                        # check out the MR branch locally
glab mr merge <id|branch> [--squash] [--remove-source-branch]
glab mr rebase <id|branch>
glab mr close|reopen <id|branch>
```

### ci — pipelines

```bash
glab ci list [--status <running|failed|success|..>] [-F json]
glab ci status                       # status of the pipeline for the current branch
glab ci get [-p <pipeline-id>] [-F json]
glab ci view [<branch>]              # interactive pipeline/job browser
glab ci trace [<job-id|job-name>]   # stream a job log live
glab ci retry [<job-id|job-name>]
glab ci cancel
glab ci lint                        # validate .gitlab-ci.yml
glab ci run [-b <branch>] [--variables KEY:val]
glab ci artifact <ref> <job-name>   # download artifacts from last pipeline
```

### job — individual CI jobs

```bash
glab job [<job-id>]                  # view a job
glab ci trace <job-name>             # tail its log (most useful for debugging a failed dbt run)
```

### repo

```bash
glab repo view [<path>] [-F json]    # repo metadata, default branch, etc.
glab repo clone <path>
glab repo search <query>
```

### issue

```bash
glab issue list [--mine] [-F json]
glab issue view <id> [--comments]
glab issue create [--title ..] [--description ..]
glab issue note <id> -m "comment"
glab issue close|reopen <id>
```

### variable — CI/CD variables

```bash
glab variable list [-F json]
glab variable get <KEY>
glab variable set <KEY> <value> [--masked] [--protected]   # ask before mutating
glab variable delete <KEY>
```

### api — escape hatch for anything not wrapped

```bash
# Any GitLab REST endpoint, authenticated. Project path must be URL-encoded.
glab api projects/aircall%2Fdata%2Fdbt-models/merge_requests?state=opened
glab api projects/:id/pipelines/:pipeline_id/jobs           # :id resolves in-repo
glab api --method POST projects/:id/merge_requests/:iid/notes -f body="comment"
```

### auth / config

```bash
glab auth status
glab auth login --hostname gitlab.com --token glpat-XXXX
glab config get|set <key> [value]
```

## Safety

- **Mutations require intent.** Before `mr merge`, `mr close`, `mr approve`, `variable set/delete`, `issue close`, `ci cancel`, or any `api --method POST/PUT/DELETE`, confirm with the user — these are outward-facing and hard to reverse. Read-only commands (`list`, `view`, `diff`, `status`, `get`, `trace`) run freely.
- **Never echo or store the token** beyond glab's own config. If it leaks, advise rotation.
- Posting an MR note / approval is visible to the whole team — treat like sending a message.

## Workflow examples

### Review the open MRs assigned to me

```bash
glab mr list --mine -F json | jq -r '.[] | "\(.iid)\t\(.title)\t\(.web_url)"'
glab mr view <iid> --comments
glab mr diff <iid>
```

### Comment on an MR after reviewing the diff

```bash
glab mr diff 1234
# ...analyze the change...
glab mr note 1234 -m "LGTM — one nit: the view materialization on clean_partnerstack_partnerships looks right, but consider documenting the explicit column list."
```

### Watch a failing dbt pipeline and read the failed job log

```bash
glab ci status                                  # find the failed pipeline on this branch
glab ci list --status failed -F json | jq '.[0]'
glab ci trace <failed-job-name>                 # stream the dbt error output
glab ci retry <job-name>                        # after a fix is pushed (confirm first)
```

### Create a draft MR for the current branch (dbt-models — ALWAYS use the template)

The dbt-models repo has a **mandatory MR template** at `.gitlab/merge_request_templates/Default.md`. `glab mr create` does NOT apply it automatically (unlike the web UI) — you must pass `--template Default`, or the MR ships without the required Schema & Deployment Classification and reviewers will bounce it.

```bash
glab mr create --template Default --draft --target-branch main -t "feat(partnerstack): add partner name"
# Opens the template in $EDITOR (or use --description - ). Fill every "(Mandatory)" section, then:
glab mr update <iid> --ready
```

Do NOT use `--fill` for dbt-models — it overwrites the description with commit messages and drops the template. Use `--fill` only on repos with no template.

See the **dbt-models MR workflow** section below for what each template section requires.

### Inspect another repo without cloning

```bash
glab mr list -R owner/group/repo -F json | jq length
glab repo view -R aircall/data/looker -F json | jq '.default_branch'
```

## dbt-models MR workflow (Aircall-specific)

When creating or reviewing an MR in `aircall/data/dbt-models`, the `Default.md` template is mandatory and gates merge. Fill it accurately — the answers drive the post-merge deployment, which **the MR author runs, not the CDO**.

**Required sections (all marked "Mandatory"):**
- **Ticket Reference** — `DI-####` / `DATA-####`.
- **Summary of Change.**
- **Screenshots of successful local run** — `dbt run --select <model>` + `dbt test` output.
- **Schema & Deployment Classification** — the critical part. The repo uses `on_schema_change: 'append_new_columns'` on incrementals:
  - **Add column** → no full-refresh; `append_new_columns` adds it (existing rows NULL).
  - **Remove / rename / type-change column** → no full-refresh; requires post-merge Redshift DDL (`ALTER TABLE … DROP/RENAME/ALTER COLUMN`).
  - **Logic change, forward-only** → normal `dbt run`.
  - **Logic change needing historical correction** → full-refresh or `run_refresh_by_period`.
- **⚠️ `view_if_not_exists` trap** — most source/clean models are views with the project-default `view_if_not_exists` materialization (no `materialized=` in the config block). dbt **skips** these on normal runs, so **ANY** change (column/logic/anything) needs a post-merge `--full-refresh` or downstream models break. List affected views and put the full-refresh in the deployment plan. (A CI auto-detect step is planned to replace this manual check.)
- **Deployment Plan** — exact post-merge commands: Redshift DDL (if any), `dbt run` commands, downstream `dbt run/test --select model+`.
- **Downstream Impact** — `dbt ls --select +model+`, plus external consumers (Looker, reverse ETL, APIs).
- **MRR section** — if touching `models/marts/mrr/`, `models/intermediate_marts/mrr/`, `*mrr_*.sql`, or opportunities models: complete MRR validation checks AND tag one MRR reviewer (@ext-mihaela.gheuca, @ext-anthony.olund, @artur.trofymov, @alexander.bufalo, @ext-tejas.borkar).

**For backfill strategy decisions** (full-refresh vs `run_refresh_by_period` vs forward-only vs Redshift DDL) and rollback, use the **`dbt-deploy-runbook`** skill — it covers the deployment mechanics this template's plan section depends on. For broader dbt/Redshift/Looker context use **`data-stack`**.

**Reviewing an MR:** pull the diff, then verify the Classification section matches the actual change — the most common miss is a modified `view_if_not_exists` model with no `--full-refresh` in the plan.

```bash
glab mr diff <iid>
glab mr view <iid> --comments        # confirm template sections are filled
glab mr note <iid> -m "view_if_not_exists model changed but no --full-refresh in the deployment plan — that view won't be recreated on the nightly run."
```

## Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| `An error has occurred — requested scope is invalid` (browser) | The MCP connector's OAuth flow, not glab. Use this CLI instead. |
| `401 Unauthorized` on a command | Token expired/revoked. Reissue PAT, re-run `glab auth login --token`. |
| Token works for read but not push | PAT missing `write_repository` scope; or git remote uses SSH (separate key). |
| `404 Project Not Found` | Wrong `-R` path — it's `aircall/data/dbt-models`, group is nested. |
| SSO / Okta token rejected | After creating the PAT, click its "Authorize with SSO" button once. |
