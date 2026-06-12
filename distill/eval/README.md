# distill — output-quality eval harness

Triggering accuracy is one question; **output quality** is the hard one — no ground truth, author bias, whole-session cost. This harness sidesteps "is it good?" (unjudgeable) by turning each design claim into a **falsifiable property** checked against **planted ground truth**, scored by an **intent-blind judge** that never sees `SKILL.md`.

## Properties checked

| Property | What it catches | Fixture(s) |
|---|---|---|
| **density → length** | padding a thin session into full sections | `thin-directive`, `unresolved-question` |
| **recall** | dropping durable signal that was actually generated | `dense-exploratory`, `user-correction` |
| **mechanism-stripping** | keeping "I edited X / ran Y" worklog lines | `dense-exploratory` |
| **no fabrication** | inventing a decision/lesson never reached | `unresolved-question` |
| **parking-lot ≠ handoff** | parking forward next-steps instead of routing them to handoff | `next-steps-trap` |
| **no duplication** | one idea under two headings | all |
| **foundation mark** | nothing tagged compounding, so the chain has nothing to carry | all |

`user-correction` specifically guards the signal distill empirically tends to miss: a lesson that came from the user correcting the assistant.

## Files

- `fixtures.json` — synthetic sessions with planted ground truth (`must_recover`, `must_drop`, `must_not_park`, `must_not_fabricate`, `expect_foundation_mark`, `length_expectation`). The irreplaceable part; expand it as the skill evolves.
- `harness.workflow.js` — generic runner. Per fixture: a fresh agent runs the skill to produce a DISTILL.md, then an intent-blind judge scores it against that fixture's truth. Returns a scorecard.

## Run it

The runner is a Workflow script. The skill body is injected at run time, so the harness always tests the *current* skill (not a stale copy):

1. Read `distill/distill/SKILL.md` (body) and `distill/eval/fixtures.json`.
2. Invoke the Workflow tool:
   - `scriptPath`: `distill/eval/harness.workflow.js`
   - `args`: `{ "skillBody": "<SKILL.md contents>", "fixtures": <the fixtures array>, "samples": 3 }`
3. Read the returned `summary` (per-fixture `pass_rate`, `flaky` flag, `prop_fail_counts`, and `sample_fails`) and `examples` (one distillation per fixture, for spot-checking the judge).

A single trial passes only if: full recall, no mechanics leaked, no fabrications, no next-steps parked, not duplicated, density ok, and foundation mark as expected.

**Always run `samples` ≥ 3.** A single sample is noise — empirically, the same skill flips a fixture pass↔fail run to run. `pass_rate` (e.g. `2/3`) plus `prop_fail_counts` tells you *which* property is flaky vs. systematically broken. A property that fails every sample is a real skill gap; one that fails intermittently is variance (or a borderline fixture/judge call).

## Caveats

- **Synthetic ≠ real.** Fixtures are constructed; they catch regressions and validate the design rules, but a real transcript corpus would have more face validity. Add real (sanitized) sessions over time.
- **Judge is an LLM.** For the near-objective checks (planted recall/mechanics/parking) it's reliable; density and fabrication involve judgment. Spot-check `distillations` against verdicts. Add multi-vote judging if a property proves noisy.
- Build cost is real — only worth running when the skill's method or boundary rules change.
