---
name: capture-english-lessons
description: Distill this session's English lessons from Scott's own typed messages — unnatural phrasings (the main unit), grammar slips, misunderstandings/misused words — into a dated diff-shaped lesson file under ~/etc/dump/english/. Run at the end of a session, in-context. Triggered by "/capture-english-lessons", "capture english lessons", "distill my english from this session".
disable-model-invocation: true
---

# capture-english-lessons

Per-session capture half of the English learning loop (synthesis half: `digest-english-lessons`,
separate skill — not in this repo). The session context itself is the corpus — you were there, you
know what he meant, where the repair sequences were, and which phrasings caused friction. Capture
while that is live instead of re-scanning transcripts later.

## Goal

The target is **concept→text bandwidth**, not error correction. Fluent production runs on stored
multi-word chunks retrieved whole (Pawley & Syder; formulaic-language research), so the primary
unit of capture is the **phrasing diff + its reusable chunk** — the thing he can retrieve next
time instead of assembling word-by-word. Grammar slips are tracked only as monitoring load:
un-automatized small grammar burns working memory that should go to expression.

## Corpus

Only Scott's own typed English in this session's user messages. Exclude: pasted content (specs,
code, tool output, quoted text), code identifiers, Chinese (L1 typos are style, not noise — never
log them). If the session has too little of his typed English to yield honest lessons, say so and
stop — do not manufacture lessons.

## Lessons — three buckets, all diff-shaped

A lesson is a diff, never a rule. The bet (from the ssuyi-voice work): repeated exposure to his own
before/afters converges faster than instruction, so no grammar explanations anywhere.

1. **Phrasing** — the main bucket. Grammatical-but-non-native or effortful constructions:
   `wrote → natural version (family) [chunk: "..."]`. Tag each with a pattern family:
   - `chunk` — a formulaic sequence/collocation exists for this ("close 411, favor 416" → "in favor of")
   - `structure` — information structure / word order ("make us easier to read the whole graph" → "make the whole graph easier to read")
   - `word-choice` — a more precise verb/noun exists ("continue the workflow from where was blocked" → "resume from where it left off")
   When a reusable chunk is the payoff, name it in `[chunk: "..."]` — the digest tracks adoption
   of named chunks across sessions. Log every genuine one; the quality bar is "he'd plausibly
   reuse this construction", not a count cap.
2. **Mistakes** — grammar/spelling errors, kept as monitoring-load data: `wrote → fix (class)`.
   Classes: 1 verb inflection (-s/-ed), 2 articles, 3 plurals, 4 verb complementation/gerund,
   5 spelling. Log every instance tersely — the digest only aggregates counts from these; they
   are not the learning target.
3. **Misunderstandings / misused words** — the bucket only in-context capture can fill: repair
   sequences ("no, I mean…"), a word used confidently with the wrong meaning, replies showing he
   read X as Y. Format: `said "X" → meant Y → the word/phrase: Z`. Empty most sessions; leave empty
   rather than stretch.

## Output

Write one file: `~/etc/dump/english/YYYY-MM-DD-<session-slug>.md` (absolute path — this is the
fixed cross-repo contract; the digest skill reads this folder). Format:

```markdown
# English lessons — <session topic>

date: YYYY-MM-DD

## Phrasing
- wrote → natural (family) [chunk: "..."]

## Mistakes
- wrote → fix (class N)

## Misunderstandings
- (none) | said "X" → meant Y → Z
```

One line per lesson, nothing else. After writing, show the Phrasing section in the reply so the
exposure happens immediately, not only at digest time (Mistakes can stay in the file).

## Guardrails

- No grammar rules, no explanations, no teaching — diffs only.
- Lessons come only from sentences he actually typed this session.
- Never log Chinese or L1-style typos.
- Never rewrite or grade past messages in the conversation itself — the file is the only output.
