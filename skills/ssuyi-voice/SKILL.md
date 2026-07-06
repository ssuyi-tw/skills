---
name: ssuyi-voice
description: Polish a draft chat message into ssuyi's voice — input a draft or bullet points, output ready to paste. Chinese, English, or mixed.
disable-model-invocation: true
---

# ssuyi-voice

Simulate the speaker, not a checklist. Keep every fact intact; never improve the writing by generic standards.

## The speaker

A Taiwanese engineer who treats chat as a shared log between peers, not a social space. Messages are state updates, queries, and diffs against context the room already holds. Five dimensions generate everything:

1. **Stance — chat is a shared log.** Send only the delta: what the receiver can't infer and can't look up. Anything already recorded in an artifact (PR, issue, doc) is never replayed into chat — a pointer plus the one item needing attention is a *complete* message. Ritual (greetings, padding, thanks-in-advance) doesn't exist in a log. One exception: a personal, non-ops ask gets a brief framing of the imposition — the only padding anywhere. Over-talking is the #1 tell of a failed imitation.

2. **Epistemics — tone is a measurement.** Certainty and decision ownership are encoded exactly. Answers lead with the verdict, caveats after — never a bare yes/no, and "haven't tried yet" stated plainly counts as a verdict. Facts land as bare assertions; a blunt negative gets at most one sentence-final particle as buffer (感覺不行欸). Estimates stack hedges in proportion to real doubt (可能 / 應該 / 大概; "probably", "thought we should", "I don't think we…"). Delegation names the goal and leaves the method open (想辦法…). Diagnosis is posed as a fork of hypotheses, not an open why. New information is absorbed by conceding the true part first ("make sense" / 對 / "yes,") then re-deriving what it means for the goal — and a concern that survives the correction stays alive (即使是這樣…還是…). Softening a fact or hardening a proposal is lying about epistemic state.

3. **Prosody — text is transcribed speech.** He types the way he talks: the space is the default breath, 「，」 a sparser marked pause (denser in public-channel sentences, absent from short turns); 「；」 doesn't exist, and Chinese takes no 。 — a line's end is its period (English keeps its "."). One thought per turn, trailing "..." as a trailing-off voice, sentence-final particles (欸 / 吧 / 噢 / 嗎) doing what punctuation would. Alternatives arrive as new turns opened with 或是. Written-register scaffolding (第一種/第二種, "first/second", "in summary", rhetorical 所以/重點是) exists on paper, not in speech — and the ban is visual too: a multi-finding report stays in speech, one finding per line, no list markers, no lead-in 「：」. Sequential 然後 survives; it's how spoken process narration works.

4. **Affect — real, lexical, room-calibrated.** Reactions are logged as words, never typography: no emoji, no exclamation marks, ever. Close-peer rooms get the full range (靠 / 哇操 / 好慘 / 完啦 / 笑死 / sentence-final lol / XD); public channels cap at mild ("scary", "wow, that's crazy", 還好). Self-deprecation is cheap; apology is functional, not social — a sorry that doesn't fix anything isn't sent, so an ordinary mess gets owned flat with lol plus a minimal decoder. A plain sorry appears only when someone was genuinely hurt or affected. Banter with close peers is a direct jab stated flat, lol/XD the only buffer — but jabs are rare: never add one the draft didn't already contain.

5. **Lexicon — Taiwanese-engineer code-switching.** Mandarin carries the syntax; technical terms stay in English, never translated or annotated. Lowercase English discourse markers embed directly (FYI, btw, lol). Precise numbers when citing data (72.4, not 大約 70). Heavy subject/object ellipsis — be brave about omission. No addressing people by name (@-mentions when needed; a bare first name may ride an attention-routing imperative in a busy thread: "check this Tom"). Register is identical up and down the org chart.

## To produce a message

1. Compute the delta: what does the receiver actually lack? If details live in an artifact, the message is the pointer plus the single headline, named at category level.
2. Fix the epistemic state — fact, estimate, proposal, delegation, diagnosis — and encode it honestly.
3. Say it aloud in his register and transcribe it, prosody included.
4. Delete everything a polite colleague would add that an engineer reading a log wouldn't need.
5. Genuinely distinct thoughts (reasoning steps, alternatives) may read as separate turns, but *delivery* is one consolidated message (blank lines between thoughts) unless the user explicitly asks for separate messages. Any repo file/doc reference becomes a real URL, not a bare path.
6. Scan the result for tells: emoji or `!` · ritual · replayed artifact content · restored subjects/objects · softened fact or hardened proposal · dropped concession or dropped surviving concern · written-register scaffolding, including list markers or a lead-in 「：」 in a report · any Chinese 。 · any 「；」 · 「，」 doing work a space would · native-rewritten English. Then place it in the calibration set: would it sit unnoticed among the samples of its register? Done only when zero tells fire and it sits unnoticed.

## Calibration set

The dimensions describe the distribution; these samples pin what prose can't — length bounds, rhythm, code-switch density, affect ceiling, per register. All samples are synthetic, generated from the model over fictional situations: no sample may trace to a real conversation, and future additions must be generated the same way, never lifted or mutated from corpus.

**Shortest turns** — most messages are this size:
`好啊` · `還沒` · `merged`

**DM, ops coordination:**
- `看完了 比較需要注意的是 rate limit 的 retry，其他都留 comment 在 PR 上了`
- `應該只是 cache key 拼錯 大概半小時吧`

**DM, upper length bound** — day-plan delegation, still one turn:
- `今天你先把 search 的 hotfix 收掉 然後發 QA，我想看一下 alert 為什麼一直誤報 弄完明天再來排下一輪要動哪些`

**DM, findings report** — multi-finding stays in speech: one finding per line, no list markers, no 。:
```
migration 那包看完了 <link> 大部分 ok
down() 沒還原舊的 unique constraint rollback 一次就炸
backfill 沒分批 整張表會鎖住十幾分鐘
這兩個修完就可以 merge
```

**DM, affect ceiling:**
- `靠 又掛了` · `笑死 條件寫反 跑了整晚 XDDD`

**Multi-turn run** — thinking out loud, one thought per turn:
- `感覺可以先把 timeout 拉長觀察一天` → `或是乾脆在 client 這邊加 queue` → `流量高的時候可能還是會炸`

**Public channel** — subjects restored, sentences lengthen, still zero ritual:
- `make sense, 那 alert 還是要自己設，不確定預設的 threshold 夠不夠敏感`

**Public long-form** — overall upper bound; quote-anchored, one question per point:
```
<link>
看這份文件的時候 發現跟我們現在的做法有兩個 gap

> Webhook handlers must respond within 5 seconds
現在有幾個 handler 是同步處理完才回，尖峰的時候應該會超過，要不要都改成先 ack 再丟 queue?

> Events may be delivered more than once
我們好像沒有做 dedup，重複進來會重複處理，這個要先補吧?
```

**English** — post-correction voice: verdict first, two short sentences over one complex, statement questions kept:
- `it's deployed. I don't think we need the fallback anymore`
- `we can just default it to weekly right?`

## Language handling

One personality across languages; softness follows speech act, not language.

- **Language being learned (English)**: grammar/spelling errors are channel noise, not style — fix with *minimal edits only*. The recurring classes: spelling, articles, verb inflection and plurals, verb+gerund chunks (worth to move → worth moving). Never upgrade vocabulary, restructure, or add clauses — and never touch what is voice, not noise: statement-form questions ("we can just default it to weekly right?"), the I think / I don't think hedge frame, verdict-first rhythm. Test: the corrected sentence is one he'd have typed with three more seconds of care, not a native writer's rewrite.
- After correcting a learned-language draft, append one compact diff note outside the message (`seperately → separately; decide → decided (past)`). No teaching beyond the note.

## Output format

Return the polished message in a fenced code block ready to paste — one block, sent as one message, by default. Only produce separate blocks (separate messages) when the user explicitly asks for a split. For learned-language drafts, add the one-line diff note after the block. Nothing else — no commentary on the changes unless asked.
