---
name: sharpen
description: "Sharpen a vague prompt before acting on it — surface what's missing and ask the user, instead of silently rewriting and guessing at the intent they never gave. Use when the user explicitly asks to sharpen / improve / tighten a prompt or request, or says they're unsure they've asked clearly. Triggered by \"/sharpen\", \"improve this prompt\", \"help me ask this better\"."
---

# Sharpen — tighten a vague prompt before acting on it

A request travels down a chain: **expectation** (the product they want) → **intent** (the solution they have in mind) → **prompt** (the words they typed). A vague prompt lost something between two of those links, and *which* link leaked decides how hard you work.

- **Prompt lost what intent held → lossy.** The solution was decided; the words just dropped part of it — a dangling reference, a missing constraint. Recover it: read the piece back, one confirm/veto. Cheap and shallow.
- **Intent never fully formed → loose.** The solution itself was open. Resolve it: make them choose, which *creates* the intent. This is the only place exploring the readings is worth its cost.

You cannot recover what was never encoded. Filling gaps yourself invents intent and passes your guess off as their requirement. Only their answer adds intent; everything else just re-encodes what was already there.

## The one rule

Don't silently rewrite. The order is fixed — **diagnose → ask → re-encode** — and the ask is the gate: no re-encoding until they've answered. Skipping the ask is the single failure this skill exists to prevent.

## How hard to look — decide this first

Effort is not a dial you set up front. It falls out of two cheap reads:

- **Which link leaked?** — the lossy/loose read above. Dangling ref or dropped constraint → lossy (confirm); several live approaches or no stated success bar → loose (explore).
- **What's at stake?** Cheap and reversible output → take the obvious reading and answer. Expensive or hard to undo → pay for a question round.

Explore only when it's **loose *and* high-stakes**. Everywhere else, take the obvious reading, mark what you assumed, and move on — unless there's no obvious reading to take (a dangling reference carrying the whole request), where you still ask even at low stakes. Depth ≈ divergence × stakes.

## Flow

### 1. Diagnose — cheap first, deep only if forced

Run a fixed checklist first — pure lookup, no open reasoning:

- success criterion — what counts as a good answer?
- scope / constraints
- audience
- output format
- dangling references — "it / that / the usual / like before" with no clear referent

For each gap **that would change the answer**, tag it lossy or loose (the two reads above pick which). Ignore gaps that wouldn't move the output.

Only if the checklist leaves real ambiguity *and* the deliverable is expensive: enumerate the materially different readings, forcing at least one past the obvious. **Stop the moment the next reading wouldn't change the question you'd ask or the answer you'd give** — not when the list feels "complete." Exhaustiveness is the cost bomb; marginal value is the budget.

### 2. Ask — the only step that adds intent (use `AskUserQuestion`)

- Route by tag. **Lossy → recover:** state the assumption or read the referent back; they confirm or veto (cheapest — they fix only what's wrong). **Loose → resolve:** the divergent readings *are* the options; their pick supplies the intent.
- One round. Ask every gap together, ranked by how much it moves the answer.
- The tool caps you at ~3 questions — treat that cap as the budget, not a limit to fight. Past the top three, drop the rest to `[ASSUMED: …]` rather than opening another round.
- Fold in the run choice as the last question: run it now (default), or hand the prompt back?

### 3. Re-encode — now safe

- Rewrite around their answers: clean, structured, success criterion stated explicitly.
- Anything still open — they skipped it, said "you decide," or the prior was peaked enough that asking would have bought nothing — goes inline as `[ASSUMED: …]`. Assuming on a clear prior isn't a fallback; it's the cheapest control you have. Every guess stays visible and one word to override — never buried.
- Show the sharpened prompt with a one-line note of what changed and what you assumed, then act on the run choice:
  - **Run** (default): execute now, same turn. The answered questions are the agreement — don't make them re-confirm.
  - **Hand back**: stop at the prompt; the prompt itself is the deliverable (e.g. to reuse elsewhere).

## Guardrails

- **Assume, don't ask, when the prior is peaked; ask, don't guess, only when a gap both changes the answer and is genuinely open.** Two different cheap moves — pick by confidence, not by habit.
- **Don't add scope.** Sharpen what they asked; don't grow the request into something bigger.
- **Re-check, then stop.** If answers conflict or open a new answer-changing gap, run one more targeted round. Stop when the gaps close or a round buys no new intent; whatever's left falls to `[ASSUMED: …]`. Don't interrogate forever.
