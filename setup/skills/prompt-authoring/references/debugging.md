# Debugging a Prompt That Misbehaves

Map the symptom to the likely fix. This is for prompts that run (no API/auth errors) but produce wrong output.

## Diagnostic triage

**Before changing anything, answer:**
1. What did it produce?
2. What should it have produced?
3. Where exactly do the two diverge — content, format, tone, length, scope?

The diff between actual and desired narrows the fix space dramatically. Don't start rewriting until you've named the diff.

## Symptom → likely cause → fix

### "It ignored my instruction to X"

Most common causes:
- **The instruction is buried.** Claude gives more weight to start and end of the prompt than the middle. Fix: move critical rules to the top or the very end.
- **Contradictory instructions.** Another part of the prompt implies the opposite. Re-read the whole prompt looking for conflict.
- **Too many rules at once.** 15+ bullet points of rules → some get dropped. Consolidate or split the task.

### "The format varies every run"

- **Format is described, not shown.** "Format as a status report with summary and next steps" = vague. Paste an exact template.
- **No anchoring example.** Add 2–3 few-shot examples showing the exact output shape.
- **Missing structural cues.** For JSON, end with "Respond with a JSON object matching this schema: {…}". For Markdown, show section headings literally.

### "It invented facts / cited things that don't exist"

- **Wasn't told what it doesn't know.** Add "If the answer isn't in the provided context, reply 'I don't know' — do not guess."
- **Input was ambiguous.** Tighten the data boundary: wrap the source in XML tags, forbid using outside knowledge.
- **Role encourages confident invention.** A "creative assistant" persona will hallucinate more than "a careful research analyst who only cites provided sources."

### "It did the right thing but explained too much / too little"

- **Length is not specified.** Add "Reply in one sentence", "Under 100 words", "No preamble or caveats".
- **Didn't forbid preamble.** Claude often starts with "Great question!" — explicitly forbid it: "Start your response directly with the answer. Do not include preamble like 'Here is the answer'."

### "It's inconsistent across runs — sometimes right, sometimes wrong"

- **The task needs reasoning but the prompt skipped chain-of-thought.** Add "Think step by step before answering" or a structured `<thinking>` section.
- **Temperature is too high** (if calling the API directly). For deterministic outputs, use `temperature: 0`. Note: temperature isn't a prompt-authoring fix, it's an API-call fix — but worth checking.
- **The prompt relies on a vague word.** "Recent" might mean 24h to Claude and 7d to you. Replace with specifics.

### "It runs but produces empty or trivial output"

- **Expected output isn't scoped.** "Summarize" on nothing-to-summarize produces silence. Add an empty-case rule.
- **Too many constraints filtered everything out.** "Summarize only tier-1 incidents from Q3 involving severity 5 with stakeholder Marie" → zero results is the correct answer; the prompt just needs an empty-case branch.
- **Model picked the wrong tool** (agent prompts). Name the exact tool by its full identifier.

### "It's doing the task but on the wrong data"

- **Data boundary is unclear.** Wrap the input in `<input>…</input>` and add "Operate only on what's inside the <input> tags."
- **Confused instructions for data.** Long instructions mixed with long data → Claude can pick up instructions from within the data. XML-tag the data.

## When to rewrite vs patch

- **Patch** (1–2 line changes) when the diff is about format, tone, length, or a missing edge case.
- **Rewrite** when the prompt accumulates patches (every run adds a new rule to handle a new case) — it becomes brittle and contradictory. Start from the skeleton in `agent-prompts.md` and consolidate.

Rule of thumb: if you've patched the same prompt 3+ times for similar issues, rewrite.
