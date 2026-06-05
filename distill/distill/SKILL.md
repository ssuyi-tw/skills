---
name: distill
description: Distill the session into a one-off DISTILL.md — the concepts and reasoning from the user↔assistant conversation (decisions-and-why, mental models, lessons), NOT the work mechanics (implementation, tool internals, code specifics). Backward-looking and reflective, NOT a baton-pass — use handoff for "continue this work", use distill for "what we learned that outlives it". Triggered by "distill", "distill this", "/distill", "distill the session", "distill what we learned".
---

# distill

The session is winding down. Most of what happened was noise — the back-and-forth, the dead-end that got fixed two turns later, the obvious stuff. Buried in it is a little signal worth keeping: the kind that **compounds** — a decision and *why*, a model that clicked, a lesson about how to work that pays off next session. Distill pulls that into a file the user triages, and chains the durable pieces onward so they don't evaporate with the rest.

It's the **backward-looking** cousin of handoff — different axis, forward-vs-back *and* work-vs-concept:

- **handoff** → forward → the work's *mechanics*: files, state, what to do next.
- **distill** → backward → the *concepts and conversation*: what was decided and why, what clicked, what we learned.

## When this fires

The user explicitly asks to distill — usually near the end of a session, or after a meaty chunk of figuring-something-out. On-demand and one-off. If they want the *next agent* to keep going, that's handoff. If they want a settled fact in long-term memory, that's the memory system. Distill is the in-between: durable but not yet settled.

## How to distill

**Gauge density first — it sets the length.** Before writing anything, skim the user's turns and ask *how much knowledge actually got generated here.* Where the user was exploring, unsure, or weighing advice, the exchange minted something worth keeping. Where they were just directing execution, little was discovered. The output scales to that: a session that produced one real insight gets one insight, not a filled-in template. If almost nothing emerged, say so and stop — a three-line distillation is a correct result.

Mode is a *tell, not a rule*: an instruction-heavy session can still be dense (the user can dictate a sharp principle). Judge on how much reasoning surfaced, not on who originated it.

Then, working only from what's actually there:

1. **Read it as a dialogue, not a worklog.** Hunt the turns where judgment was exchanged — a call and its *why*, a reversal, advice weighed, a thread raised then dropped. The signal is in the exchange, not the artifacts.
2. **Strip the mechanism.** If a line only says *how* the work was carried out — code, commands, tool internals, file edits — drop it. Keep the reasoning that drove it.
3. **Test each survivor:** *would it still mean something with the code deleted?* No → cut. This is also the dedup test — if you're about to write the same idea twice, the session was thinner than it looked; keep one mention.
4. **Mark what compounds** — the subset reusable beyond this session — and chain it onward (below).

## Output

Write `DISTILL.md` in the project root; tell the user the path. There's no fixed shape — length follows density. These headings are containers to reach for *as the material warrants*, not a checklist to fill:

- **Decisions** — what was chosen, *why*, and what was rejected.
- **Concepts** — a model or framing that clicked.
- **Parking lot** — an open *question whose answer would change your understanding*, surfaced but not resolved. Not a TODO, and not a TODO in disguise: a question whose answer is *a task* ("should we audit the others?", "is the quota still 10k?") is a next-step → **handoff**. Anything the user flags "for later" is handoff no matter how it's phrased.
- **Lessons** — what to do differently next time.
- **Seeds** — a speculative *new thing that could exist* (a possible skill, tool, or pattern). Distinct from the parking lot: seeds invent something new, the parking lot tracks an unanswered question inside *this* work.

Drop every heading that's empty. **One insight has one home.** If the same idea fits two headings — the specific call (Decision) and the general rule (Lesson) — keep only the more durable one, usually the Lesson. A one-insight session is *one* entry, not the same idea restated as a decision *and* a concept *and* a lesson. Never pad to look thorough.

**Mark the foundation-grade items** inline with `→ foundation` — the subset reusable beyond this session, which the chain step (below) carries onward. Foundation-grade means a *portable principle, lesson, or mental model*. An open question (parking lot), a project-specific decision, or a next-step is **not** foundation-grade — it doesn't compound, so don't mark it. The marks land on the portable lessons and models, rarely the repo-specific anchors: mark the principle ("reject a working fix → look for the violated invariant"), not the identifier (`transformDateParams`). If nothing qualifies, mark nothing — that's itself a signal the session was thin.

## Chain it onward

DISTILL.md is the staging artifact — read once. **If nothing was marked `→ foundation`, there is no chain — stop after writing the file** (or after reporting there was nothing to distill). Otherwise the compounding subset shouldn't die with it, so distill ends by handing it off:

1. Pull the items you marked as compounding.
2. **Chain to a persistence skill** that carries them across sessions. *Which skill is open for now* — the memory system is the default candidate; a dedicated foundation skill may replace it. Name it as the pluggable seam; don't hardcode.
3. Surface that subset and offer to run the chain; invoke on the user's OK.

Distill captures, marks, and recommends — it does **not** persist on its own. That's the chained skill's job, under the user's triage.

## Don't

- Don't pad to fill a template. A thin session gets a short file; an empty heading is fine, a fabricated one is noise.
- Don't capture work mechanics — implementation, tool internals, commands. If it only makes sense next to the diff, it's not for distill.
- Don't restate an idea across headings.
- Don't editorialize the whole session back at them — lead with signal, skip the recap.
- Don't persist the foundation yourself — chain it; the target is intentionally open.
- Don't park next-steps — not even phrased as a question. "Should we audit X?" / "is Y still true?" are tasks in disguise; they belong in handoff. The parking lot holds questions that change understanding, not the to-do list.
