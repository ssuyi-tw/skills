---
name: distill
description: Distill a session into a one-off DISTILL.md — the durable concepts and reasoning worth keeping (decisions and why, mental models, lessons), not the work mechanics.
argument-hint: "Optional: a thread or topic to focus the distillation on"
disable-model-invocation: true
---

# distill

Backward-looking cousin of handoff: handoff carries the work's *mechanics* forward; distill keeps the **signal** — reasoning that compounds — and drops the **noise** of how the work got done. It writes that signal into a file the user triages, then chains the durable pieces onward. Fires on explicit request near a session's end.

**Length follows density.** Skim the user's turns: exploring or weighing advice mints signal, directing execution mints little. One real insight → one entry, not a filled-in template. If nothing emerged, say so and stop. If the user named a thread, focus there.

Method:

1. Read as a dialogue and find the signal — where judgment was exchanged (a call and its *why*, a reversal, advice weighed), a model that clicked, a seed worth keeping (a new thing that could exist), or an open question whose answer would shift understanding (task-shaped questions are handoff's).
2. Keep a line only if it survives the code deleted — if it means nothing without the diff beside it, it's noise; drop it.
3. Before writing, scan the kept signal for *gaps* — a decision missing its *why*, a reversal whose lesson went unsaid, an item you can't place as durable or one-off. A gap is *missing* signal, not noise; only the user can supply it. Offer to fill the highest-value ones (≤3 questions, skippable), fold in the answers, and flag any left unfilled. Never guess — a guess injects fake signal.

Write `DISTILL.md` into its own folder under `~/etc/dump/` (never the workspace) — `~/etc/dump/<YYYY-MM-DD>-<short-topic-slug>/DISTILL.md`, creating the folder. Tell the user the path. Shape is free: one heading per kind of signal you kept, nothing padded, one insight one home.

Mark portable lessons/models with `→ foundation`, but only when the mark traces to a real turn (the user correcting the assistant, a measurement overturning a stated position, the user dictating a rule); otherwise leave it unmarked. A durable user preference gets `→ memory:feedback`.

Chain: if anything was marked, offer to hand the marked subset to a persistence skill (memory by default) and run it on the user's OK. Distill recommends; it does not persist itself.
