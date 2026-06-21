# distill

> Repo-reader notes for the [`distill`](../distill/distill/SKILL.md) skill. Documentation only — never stowed or installed (it lives outside the doubled skill dir).

## What it is

`distill` captures the **signal** from a session before it scrolls away. Most of a session is noise — the back-and-forth, the dead end fixed two turns later, routine execution. A little compounds: a decision and its _why_, a model that clicked, a lesson about how to work. distill pulls that into a one-off `DISTILL.md` the user triages, then chains the durable pieces onward so they outlive the conversation.

Its **value function** is _compounding reasoning = signal, mechanics = noise_. That makes it a **meta-skill** — its domain is concepts themselves, not domain content — so it sits at the intake of the skill ecosystem:

```
session → distill → memory → (when an item recurs and is method-shaped) a new skill
```

## When to reach for it

Fires only on explicit request ("distill this"), usually near a session's end or after a meaty chunk of figuring something out. User-invoked — manual `/distill`, no autonomous trigger.

It sits between its two neighbors:

|             | Direction                      | Keeps                                            |
| ----------- | ------------------------------ | ------------------------------------------------ |
| **handoff** | forward — continue the work    | mechanics: files, state, next steps              |
| **distill** | backward — reflect on the work | concepts: decisions + why, what clicked, lessons |
| **memory**  | —                              | settled facts for long-term recall               |

distill is the in-between: durable, but not yet settled. Want the _next agent_ to keep going? handoff. Want a settled fact in long-term storage? memory. The same session splits differently under each — what distill discards as noise (tasks, mechanics) is handoff's signal, because their value functions differ.

## How it works

A short filter, then a conditional reach back to the user:

1. **Filter** (always, agent-only). Read the session as a dialogue; keep a line only if it survives the _code deleted_ — if it means nothing without the diff beside it, it's noise. The filter spends only agent effort, never the user's, so it is the default move.
2. **Fill gaps** (only when warranted). A line that is clearly signal but unclear — a decision missing its _why_, a reversal whose lesson went unsaid, an item it can't place as durable or one-off — is _missing_ signal, not noise; no filtering creates it. distill offers to fill the highest-value gaps with a few skippable questions, then folds the answers in. Any gap left unfilled is flagged, never guessed. This is the one place distill reaches past the filter to the user — the only legitimate way to _add_ signal rather than just clean it.

## What it produces

A `DISTILL.md` in the OS temp dir, never the workspace. There is **no fixed shape** — length follows how much the session generated: one real insight is one entry; an empty session gets a three-line "nothing to distill" and stops. Headings are containers reached for as the material warrants, not a checklist — one per kind of signal kept:

- **Decisions** — chosen, why, rejected.
- **Concepts** — a model or framing that clicked.
- **Lessons** — what to do differently next time.
- **Seeds** — a speculative new thing that could exist (a possible skill, tool, pattern).
- **Parking lot** — an open _question whose answer would change understanding_ (not a TODO in disguise; task-shaped questions are handoff's).

Empty headings are dropped; one insight gets one home; padding to look thorough is forbidden.

## The chain

Items reusable beyond the session are marked inline with `→ foundation` — portable principles, lessons, and mental models, not project-specific decisions or open questions. After writing the file, distill pulls the marked subset and **chains it to a persistence skill** (memory by default; the target is left pluggable), offering to run it on the user's OK. distill captures, marks, and recommends — it does **not** persist. Nothing marked → no chain; it stops after writing.

## Design notes

- **Density-first.** Gauge how much was generated _before_ writing, so output scales to substance, not to a template.
- **Mode is a tell, not a rule.** An instruction-heavy session can still be dense if the user dictated a sharp principle — judge by how much reasoning surfaced, not who originated it.
- **The "code-deleted" test.** A candidate line must still mean something with the code/diff removed; if it only makes sense next to the work, it's handoff's, not distill's.
- **Filter, not amplifier.** distill removes noise; it cannot manufacture signal — no processing adds information about the user's intent they didn't put in. Sharpening a point already present is denoising, not creation. The sole way to raise signal is to ask (the gap-fill step), and even then the user's answer, not the agent, is the signal.
