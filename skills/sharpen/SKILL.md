---
name: sharpen
description: Sharpen a vague prompt before acting on it — surface what's underspecified and ask the user, instead of silently rewriting and guessing at the intent they never gave. Use when the user explicitly asks to sharpen / improve / tighten a prompt or request, or says they're unsure they've asked clearly. Triggered by "/sharpen", "improve this prompt", "help me ask this better".
---

# Sharpen — tighten a vague prompt before acting on it

A prompt is the user's **encoding** of what they want; a vague prompt is a lossy one. You cannot recover detail that was never encoded: rewriting it yourself only **re-encodes** what's already there — and "filling in" the gaps invents intent, passing your guess off as the user's requirement. Only the user holds the missing intent, so the real work is to **surface what's missing and ask**: their answer is the one move that adds intent; everything else re-encodes.

## The core rule — read before anything else

**Do not silently rewrite.** The default urge is to hand back a polished prompt; resist it. The order is fixed: **diagnose → ask → re-encode**, and the `AskUserQuestion` call in step 2 is the gate — you cannot reach the re-encode until the user has answered. Skipping the ask is the one failure this skill exists to prevent.

## Flow

### 1. Diagnose (do not rewrite yet)

- **Enumerate readings.** List every *materially different* way the request could be read, and the success criterion each implies. Force divergence — include at least one reading **other than** the obvious one; don't collapse to your first interpretation.
- **List missing load-bearing slots:** success criterion (what counts as a good answer?), scope / constraints, audience, output format.
- **Flag dangling references:** "it / that / the usual / like before" with no clear referent.

Done when every materially different reading and every load-bearing gap is named — not when the first plausible reading is in hand.

### 2. Ask — the only step that adds intent (use `AskUserQuestion`)

- Put the divergent readings to the user **as the options** — the readings you found *are* the multiple-choice.
- Ask for the missing slots in the **same round** (one question set is cheapest for the user). Respect the tool's limits: a few questions, 2–4 options each.
- **Only ask about load-bearing gaps** — ones that would change the answer. Skip trivia; over-asking is its own cost.

### 3. Re-encode (now safe)

- Rewrite the prompt around the user's answers: clean, structured, success criterion stated explicitly.
- If anything is **still** unresolved (the user skipped it or said "you decide"), mark it inline as `[ASSUMED: …]` — **never bury an assumption**. The user must be able to see and override every guess.
- Output the sharpened prompt plus a one-line note of what changed and what you assumed.

## Guardrails

- **Ask, don't guess.** When unsure whether a gap is load-bearing, asking is cheap; a wrong silent assumption is not.
- **Don't add scope.** Sharpen what they asked; don't expand the request into something bigger.
- **Stop when the load-bearing gaps are closed.** Don't interrogate forever — close the gaps that matter, then re-encode.
