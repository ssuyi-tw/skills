---
name: capture-english-lessons
description: Distill this session's English lessons from Scott's own typed messages — grammar slips, unnatural phrasings, misunderstandings/misused words — into a dated diff-shaped lesson file under ~/etc/dump/english/. Run at the end of a session, in-context. Triggered by "/capture-english-lessons", "capture english lessons", "distill my english from this session".
disable-model-invocation: true
---

# capture-english-lessons

Per-session capture half of the English learning loop (synthesis half: `digest-english-lessons`,
project-scoped in `~/etc/dump`). The session context itself is the corpus — you were there, you know
what he meant, where the repair sequences were, and which phrasings caused friction. Capture while
that is live instead of re-scanning transcripts later.

## Corpus

Only Scott's own typed English in this session's user messages. Exclude: pasted content (specs,
code, tool output, quoted text), code identifiers, Chinese (L1 typos are style, not noise — never
log them). If the session has too little of his typed English to yield honest lessons, say so and
stop — do not manufacture lessons.

## Lessons — three buckets, all diff-shaped

A lesson is a diff, never a rule. The bet (from the ssuyi-voice work): repeated exposure to his own
before/afters converges faster than instruction, so no grammar explanations anywhere.

1. **Mistakes** — grammar/spelling errors: `wrote → fix (class)`. Tag with the error classes from
   `~/etc/dump/2026-07-06-english-learning-skill/ERROR-PROFILE.md`: 1 verb inflection (-s/-ed),
   2 articles, 3 plurals, 4 verb complementation/gerund, 5 spelling. Log every instance — recurrence
   counts are what the digest aggregates.
2. **Better phrasing** — grammatical but non-native: `wrote → natural version`. Cap at ~5 per
   session, highest-leverage first; a flood of "better" phrasings gets ignored.
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

## Mistakes
- wrote → fix (class N)

## Better phrasing
- wrote → natural

## Misunderstandings
- (none) | said "X" → meant Y → Z
```

One line per lesson, nothing else. After writing, show the file content in the reply so the
exposure happens immediately, not only at digest time.

## Guardrails

- No grammar rules, no explanations, no teaching — diffs only.
- Lessons come only from sentences he actually typed this session.
- Never log Chinese or L1-style typos.
- Never rewrite or grade past messages in the conversation itself — the file is the only output.
