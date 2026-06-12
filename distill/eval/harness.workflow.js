export const meta = {
  name: 'distill-eval',
  description: 'Output-quality eval for the distill skill: distill each planted synthetic session, then an intent-blind judge scores the output against ground truth.',
  phases: [
    { title: 'Distill', detail: 'run the distill skill on each fixture (fresh agent, no eval context)' },
    { title: 'Judge', detail: 'intent-blind judge scores properties vs planted ground truth' },
  ],
}

// args = { skillBody: <SKILL.md body, injected fresh so we always test the current skill>,
//          fixtures: <array from fixtures.json> }
let input = args
if (typeof input === 'string') {
  try { input = JSON.parse(input) } catch (e) { throw new Error('args was a string but not valid JSON: ' + e.message) }
}
const skillBody = input && input.skillBody
const fixtures = input && input.fixtures
if (!skillBody || !Array.isArray(fixtures)) {
  throw new Error('Workflow args must be { skillBody: string, fixtures: array }; got args type=' + typeof args)
}
const SAMPLES = Math.max(1, (input && input.samples) || 1)

const VERDICT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['density_ok', 'recall', 'mechanics_leaked', 'fabrications', 'parked_next_steps', 'duplicated', 'foundation_mark_ok', 'notes'],
  properties: {
    density_ok: { type: 'boolean', description: 'Does output length match the density label / length_expectation? (thin -> near-empty; dense -> fuller). No padding.' },
    recall: {
      type: 'object', additionalProperties: false, required: ['recovered', 'missed'],
      properties: {
        recovered: { type: 'array', items: { type: 'string' }, description: 'must_recover items present in the distillation (semantic match, not exact wording).' },
        missed: { type: 'array', items: { type: 'string' }, description: 'must_recover items absent from the distillation.' },
      },
    },
    mechanics_leaked: { type: 'array', items: { type: 'string' }, description: 'must_drop (work-mechanics) items that wrongly appear as content.' },
    fabrications: { type: 'array', items: { type: 'string' }, description: 'Claims in the distillation not supported by the transcript, including any must_not_fabricate item that appears.' },
    parked_next_steps: { type: 'array', items: { type: 'string' }, description: 'must_not_park items that wrongly appear under a Parking lot heading (forward next-steps belong in handoff, not distill).' },
    duplicated: { type: 'boolean', description: 'Does any single idea appear under two different headings?' },
    foundation_mark_ok: { type: 'boolean', description: 'Does presence/absence of an inline "foundation" mark match expect_foundation_mark?' },
    notes: { type: 'string', description: 'One or two sentences of justification.' },
  },
}

function transcriptText(turns) {
  return turns.map(m => `${m.role.toUpperCase()}: ${m.content}`).join('\n\n')
}

function distillPrompt(body, tx) {
  return [
    'You are executing a skill in EVAL MODE to produce a DISTILL.md from the session transcript below.',
    'Follow the skill\'s METHOD and OUTPUT rules exactly — but in eval mode two side-effecting steps are DISABLED:',
    '  (1) Do NOT write any file and do NOT use any tools. There is no real workspace.',
    '  (2) Do NOT add the chain/persist offer, path announcement, or any closing commentary.',
    'Return ONLY the DISTILL.md file body, wrapped between <distill> and </distill> tags.',
    'If the session is too thin to distill, return <distill>NOTHING TO DISTILL — &lt;one-line reason&gt;</distill>.',
    '',
    '=== SKILL INSTRUCTIONS ===',
    body,
    '',
    '=== SESSION TRANSCRIPT ===',
    tx,
  ].join('\n')
}

function extractBody(text) {
  const m = text.match(/<distill>([\s\S]*?)<\/distill>/i)
  return (m ? m[1] : text).trim()
}

function judgePrompt(fix, tx, distillation) {
  return [
    'You are an impartial evaluator of a session distillation. You do NOT see the skill that produced it — judge ONLY against the planted ground truth and the rubric below, so the skill\'s own framing cannot bias you.',
    '',
    '=== SESSION TRANSCRIPT (the source of truth for what was actually said) ===',
    tx,
    '',
    '=== PLANTED GROUND TRUTH ===',
    `density label: ${fix.density}`,
    JSON.stringify(fix.truth, null, 2),
    '',
    '=== DISTILLATION UNDER TEST ===',
    distillation,
    '',
    '=== RUBRIC ===',
    '- recall: for each must_recover item, decide if the distillation captures it (semantic match is fine). List recovered vs missed.',
    '- mechanics_leaked: list any must_drop item that appears as content (an "I did X" worklog line).',
    '- fabrications: list any claim not grounded in the transcript, and any must_not_fabricate item that appears.',
    '- parked_next_steps: list any must_not_park item that appears under a "Parking lot" heading. Forward "to-do to finish/harden the work" items belong in handoff, not here.',
    '- duplicated: true if one idea is stated under two headings.',
    '- density_ok: does the length match length_expectation? A thin session padded into full sections is NOT ok.',
    '- foundation_mark_ok: does the presence/absence of an inline "foundation" mark match expect_foundation_mark?',
    'Be strict and concrete.',
  ].join('\n')
}

// Run each fixture SAMPLES times to measure pass-RATE, not a noisy single verdict.
const trials = []
for (const fix of fixtures) {
  for (let s = 0; s < SAMPLES; s++) trials.push({ fix, s })
}

const results = await pipeline(
  trials,
  ({ fix, s }) => {
    const tx = transcriptText(fix.transcript)
    return agent(distillPrompt(skillBody, tx), { label: `distill:${fix.id}#${s}`, phase: 'Distill' })
      .then(raw => ({ fix, s, tx, distillation: extractBody(raw) }))
  },
  ({ fix, s, tx, distillation }) =>
    agent(judgePrompt(fix, tx, distillation), { label: `judge:${fix.id}#${s}`, phase: 'Judge', schema: VERDICT_SCHEMA })
      .then(verdict => ({ id: fix.id, targets: fix.targets, s, verdict, distillation })),
)

const scored = results.filter(Boolean)

function pass(v) {
  return v.density_ok
    && v.recall.missed.length === 0
    && v.mechanics_leaked.length === 0
    && v.fabrications.length === 0
    && v.parked_next_steps.length === 0
    && !v.duplicated
    && v.foundation_mark_ok
}

// Named failing properties for one verdict — lets us see WHICH check is flaky across samples.
function failedProps(v) {
  const f = []
  if (!v.density_ok) f.push('density')
  if (v.recall.missed.length) f.push('recall')
  if (v.mechanics_leaked.length) f.push('mechanics')
  if (v.fabrications.length) f.push('fabrication')
  if (v.parked_next_steps.length) f.push('parked-next-steps')
  if (v.duplicated) f.push('duplication')
  if (!v.foundation_mark_ok) f.push('foundation-mark')
  return f
}

const byId = {}
for (const r of scored) (byId[r.id] || (byId[r.id] = [])).push(r)

const summary = Object.keys(byId).map(id => {
  const rs = byId[id]
  const passes = rs.filter(r => pass(r.verdict)).length
  const propFailCounts = {}
  for (const r of rs) for (const p of failedProps(r.verdict)) propFailCounts[p] = (propFailCounts[p] || 0) + 1
  return {
    id,
    targets: rs[0].targets,
    pass_rate: `${passes}/${rs.length}`,
    flaky: passes > 0 && passes < rs.length,
    prop_fail_counts: propFailCounts,
    sample_fails: rs.filter(r => !pass(r.verdict)).map(r => ({
      sample: r.s,
      failed: failedProps(r.verdict),
      missed: r.verdict.recall.missed,
      mechanics_leaked: r.verdict.mechanics_leaked,
      parked_next_steps: r.verdict.parked_next_steps,
      duplicated: r.verdict.duplicated,
      notes: r.verdict.notes,
    })),
  }
})

const totalPass = scored.filter(r => pass(r.verdict)).length
log(`distill-eval: ${SAMPLES} samples/fixture — ${totalPass}/${scored.length} trials passed`)

return {
  samples_per_fixture: SAMPLES,
  trials_passed: `${totalPass}/${scored.length}`,
  summary,
  examples: Object.keys(byId).map(id => ({ id, distillation: byId[id][0].distillation })),
}
