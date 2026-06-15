# AI Agent / LLM-powered Feature Regression Checks

For features that involve an LLM call (classification, extraction, mapping, routing) inside a larger system. The Website Ops Hub JIRA-type mapping is a textbook example.

## The failure modes specific to AI features

### 1. "Smart" path silently removes the fallback
The most common regression. You add an AI classification step that's supposed to produce a better result, but you replace the deterministic fallback instead of adding a branch around it.

**The fix pattern (pseudo-code):**
```
result = ai_classify(input)
if result is None or result.confidence < threshold:
    result = fallback_behavior(input)  # <-- this MUST exist
```

The LLM can and will return `None` (rate limit, parse error, low confidence). If there's no fallback branch, the whole feature dies.

**Test:** explicitly simulate `ai_classify` returning `None`. This test is non-negotiable for any AI-powered feature.

### 2. Prompt drift on previously-working inputs
You tune a prompt to handle a new edge case — and an input that used to produce output X now produces output Y. Nothing obviously broke but the behavior shifted.

**Test:** keep a small file of "anchored inputs" — 5-10 real user messages with the expected output shape. Re-run them before and after any prompt change. Diff the outputs.

Simple bash version:
```bash
# Save outputs before change
for input in anchors/*.txt; do
    python my_agent.py < "$input" > "before/${input##*/}"
done

# ... make prompt change ...

for input in anchors/*.txt; do
    python my_agent.py < "$input" > "after/${input##*/}"
done

diff -r before/ after/
```

Doesn't need a framework. The `diff` output is your regression report.

### 3. Tool use / function calling signature change
If your agent uses tool definitions and you add a new field to one, the LLM may stop calling the tool at all (Claude is strict about schema). Or it may call it with the wrong field shape.

**Test:** after any tool-definition change, run 3 representative prompts and verify the tool gets called with the expected shape.

### 4. Model version change (4.6 → 4.7 etc)
Moving to a new model version shifts behavior even on identical prompts. Worth knowing, not a hard regression — but worth re-running anchors when you migrate.

**Test:** same anchor-diff as #2 above, across the version change.

### 5. Temperature / sampling changes
Setting temperature to 0 when it was 0.7 (or vice versa) changes behavior in ways that look like randomness but affect downstream systems that expected stable output.

**Test:** if you're feeding LLM output into a parser (JSON, enum, etc.), temperature > 0 can occasionally produce invalid output. Add a parser-retry or schema-validation step that's covered by a test.

### 6. Context window / truncation silently dropping important input
If a prompt grows past the context window, older parts get truncated. A feature that worked on short inputs breaks on long ones without any error message.

**Test:** include a "long input" anchor (top 10% of real inputs by length) in your set.

## Confidence thresholds & fallback triggers

For classifiers (like the JIRA type mapper), confidence is your switch. Common patterns:

- **Hard threshold:** if confidence < 0.8, fall back. Simple, explicit.
- **Top-2 margin:** if top prediction's confidence minus the second's is < 0.2, call it ambiguous and fall back.
- **Explicit "unsure" class:** train/prompt the model to output "unsure" when it doesn't know. Then fall back on that token.

Whichever you choose, **the fallback condition is an explicit branch you can test.** Test it. Input designed to be ambiguous should trigger the fallback, not produce a low-confidence answer.

## Anchor inputs file — template

Keep `anchors.md` in the repo next to the agent code:

```markdown
# Anchor inputs for <agent name>

Run before and after any prompt change. Diff the outputs.

## 1. Typical clear-intent input
Input: "My dashboard is slow during business hours"
Expected mapping: performance
Expected fallback trigger: no

## 2. Ambiguous input
Input: "Hey can someone look at this when you get a chance"
Expected mapping: (any)
Expected fallback trigger: yes (low confidence)

## 3. Empty / noise input
Input: "test"
Expected mapping: (any)
Expected fallback trigger: yes

## 4. Long rambling input
Input: "<paste real 500-word Slack message from production>"
Expected mapping: (correct mapping)
Expected fallback trigger: no

## 5. Adversarial input (past incident)
Input: "<the message that broke it last time>"
Expected behavior: <what should happen now>
```

This file is the single most valuable artifact for AI feature development. Don't lose it.

## Related: Anthropic guidance worth knowing

- **"Building effective agents"** (https://www.anthropic.com/research/building-effective-agents) — Anthropic's own writeup on workflow patterns, guard rails, and eval-driven iteration. Worth one read-through.
- **Evals in the Claude API docs** — structured approach to measuring agent behavior over time.
