---
name: distill
description: Distill a session into a one-off DISTILL.md — the durable concepts and reasoning worth keeping (decisions and why, mental models, lessons), not the work mechanics.
argument-hint: "Optional: a thread or topic to focus the distillation on"
disable-model-invocation: true
---

# distill

Backward-looking cousin of handoff: handoff carries the work's *mechanics* forward; distill captures the *concepts and reasoning* — decisions-and-why, models that clicked, lessons — into a file the user triages, then chains the durable pieces onward. Fires on explicit request near a session's end.

**Length follows density.** Skim the user's turns: exploring or weighing advice mints signal, directing execution mints little. One real insight → one entry, not a filled-in template. If nothing emerged, say so and stop. If the user named a thread, focus there.

Method:
1. Read as a dialogue; find where judgment was exchanged (a call + its *why*, a reversal, advice weighed).
2. Drop anything that only says *how* the work was done (code, commands, edits). Keep the reasoning.
3. Keep a line only if it would still mean something with the code deleted.

Write `DISTILL.md` to the OS temp dir (not the workspace); tell the user the path. Use only the headings the material earns:

- **Decisions** (chosen, why, rejected) · **Concepts** (a framing that clicked) · **Lessons** (do differently next time) · **Seeds** (a new thing that could exist) · **Parking lot** (an open question that would change your understanding — *not* a next-step; a question whose answer is a task goes to handoff).

One insight, one home — if it fits two, keep the more durable. Mark portable lessons/models with `→ foundation`, but only when the mark traces to a real turn (the user correcting the assistant, a measurement overturning a stated position, the user dictating a rule); otherwise leave it unmarked. A durable user preference gets `→ memory:feedback`.

Chain: if anything was marked, offer to hand the marked subset to a persistence skill (memory by default) and run it on the user's OK. Distill recommends; it does not persist itself.

Don't: pad a thin session, capture mechanics, restate one idea twice, or park next-steps (those are handoff's).
