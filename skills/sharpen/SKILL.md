---
name: sharpen
description: Sharpen a vague prompt before acting on it — surface what's underspecified and ask the user, instead of silently rewriting and guessing at the intent they never gave. Use when the user explicitly asks to sharpen / improve / tighten a prompt or request, or says they're unsure they've asked clearly. Triggered by "/sharpen", "improve this prompt", "help me ask this better".
---

# Sharpen — tighten a vague prompt before acting on it

A prompt is the user's **encoding** of what they want; a vague prompt is a lossy one. You cannot recover detail that was never encoded: rewriting it yourself only **re-encodes** what's already there — and "filling in" the gaps invents intent, passing your guess off as the user's requirement. Only the user holds the missing intent, so the real work is to **surface what's missing and ask**: their answer is the one move that adds intent; everything else re-encodes.

The slack in a vague prompt has **two origins that need different asks**:

- **Lossy** — the intent *existed* but didn't reach the words. → **Recover** it (confirm or veto).
- **Loose** — the intent was *never decided*; the frame is open. → **Resolve** it: make them choose, which *creates* intent that wasn't there.

Tag which dominates each gap — it picks the ask in step 2.

## The core rule — read before anything else

**Do not silently rewrite.** The default urge is to hand back a polished prompt; resist it. The order is fixed: **diagnose → ask → re-encode**, and the `AskUserQuestion` call in step 2 is the gate — you cannot reach the re-encode until the user has answered. Skipping the ask is the one failure this skill exists to prevent.

## Flow

### 1. Diagnose (do not rewrite yet)

- **Enumerate readings.** List every *materially different* way the request could be read, and the success criterion each implies. Force divergence — include at least one reading **other than** the obvious one.
- **List missing load-bearing slots** — the ones that would change the answer: success criterion (what counts as a good answer?), scope / constraints, audience, output format.
- **Flag dangling references:** "it / that / the usual / like before" with no clear referent.
- **Tag each gap lossy or loose.** Dangling references and dropped constraints are usually **lossy** (a fact they know but omitted). Multiple live readings with no stated success criterion are usually **loose** (they haven't decided). This tag picks the ask in step 2.

Done when every materially different reading and every load-bearing gap is named — not when the first plausible reading is in hand.

### 2. Ask — the only step that adds intent (use `AskUserQuestion`)

- **Route each gap by its tag.** *Lossy* → **recover**: state the assumption or read back the referent, user confirms/vetoes (cheapest — they only fix what's wrong). *Loose* → **resolve**: the divergent readings you found *are* the options — make them pick; the choice supplies the intent.
- Ask for the missing slots in the **same round** (one question set is cheapest for the user). Respect the tool's limits: a few questions, 2–4 options each.
- **Only ask about load-bearing gaps.** Skip trivia; over-asking is its own cost.
- **Fold in the run choice** as the final question — run it now and return the answer (default), or hand the prompt back? It's load-bearing, so it rides this round, never a separate turn.

### 3. Re-encode (now safe)

- Rewrite the prompt around the user's answers: clean, structured, success criterion stated explicitly.
- If anything is **still** unresolved (the user skipped it or said "you decide"), mark it inline as `[ASSUMED: …]` — every guess must stay visible and overridable, **never buried**.
- Show the sharpened prompt with a one-line note of what changed and what you assumed — then act on the run choice from step 2:
  - **Run** (default): execute the sharpened prompt now, in the same turn. The answered questions are the agreement — don't make the user re-confirm.
  - **Hand back**: stop at the prompt; the prompt itself is the deliverable (e.g. to reuse elsewhere).

## Guardrails

- **Ask, don't guess.** When unsure whether a gap is load-bearing, asking is cheap; a wrong silent assumption is not.
- **Don't add scope.** Sharpen what they asked; don't expand the request into something bigger.
- **Re-check, then stop.** Answers can conflict or open a new load-bearing gap — if so, run one more targeted round. Stop when the gaps are closed or a round buys no new intent; whatever's still unresolved falls to `[ASSUMED: …]` (step 3). Don't interrogate forever.
