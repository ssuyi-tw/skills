# distill

> Repo-reader notes for the [`distill`](../distill/distill/SKILL.md) skill. This file is documentation only — it is never stowed or installed (it lives outside the doubled skill dir).

## What it is

`distill` is an on-demand skill that captures the **signal** from a session before it scrolls away. Most of a session is noise — the back-and-forth, the dead end fixed two turns later, routine execution. A little of it compounds: a decision and *why*, a model that clicked, a lesson about how to work. Distill pulls that into a one-off `DISTILL.md` the user triages, then chains the durable pieces onward so they outlive the conversation.

## When to reach for it

It fires only when the user explicitly asks (e.g. "distill this"), usually near the end of a session or after a meaty chunk of figuring something out.

It sits on two axes against its neighbors:

| | Direction | Captures |
| --- | --- | --- |
| **handoff** | forward — continue the work | mechanics: files, state, next steps |
| **distill** | backward — reflect on the work | concepts: decisions + why, what clicked, lessons |
| **memory** | — | settled facts for long-term recall |

Distill is the in-between of the three: durable, but not yet settled. If the user wants the *next agent* to keep going, that's handoff. If they want a settled fact in long-term storage, that's memory.

## What it produces

A `DISTILL.md` in the project root. There is **no fixed shape** — length follows how much knowledge the session actually generated. A session with one real insight gets one entry; an empty session gets a three-line "nothing to distill" and stops. The headings are containers reached for as the material warrants, not a checklist:

- **Decisions** — what was chosen, why, what was rejected.
- **Concepts** — a model or framing that clicked.
- **Parking lot** — an open *question whose answer would change understanding* (not a TODO in disguise).
- **Lessons** — what to do differently next time.
- **Seeds** — a speculative new thing that could exist (a possible skill, tool, pattern).

Empty headings are dropped; one insight gets one home; padding to look thorough is explicitly forbidden.

## The chain

Items reusable beyond the session are marked inline with `→ foundation` — portable principles, lessons, and mental models, not project-specific decisions or open questions. After writing the file, distill pulls those marked items and **chains them to a persistence skill** (the memory system is the default; the target is intentionally left pluggable), then offers to run it on the user's OK.

Distill itself captures, marks, and recommends — it does **not** persist. If nothing is marked `→ foundation`, there is no chain and it stops after writing the file.

## Design notes

- **Density-first.** The skill gauges how much knowledge was generated *before* writing, so output scales to substance rather than filling a template.
- **Mode is a tell, not a rule.** An instruction-heavy session can still be dense if the user dictated a sharp principle — judgment is on how much reasoning surfaced, not who originated it.
- **The "code-deleted" test.** Each candidate line must still mean something with the code/diff removed; if it only makes sense next to the work, it belongs in handoff, not distill.
