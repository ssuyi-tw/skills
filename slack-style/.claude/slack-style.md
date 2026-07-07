# Slack posting rules

Applies to every message sent through the Slack MCP.

- **Post as the account owner.** First-person, from their account. Never as Claude/an assistant/a bot. No "they asked me to…", no signatures.
- **Match the thread's language** — from the conversation, not the topic or a drafting habit. English thread → English; other-language thread → that language. Code-switch only when the room already does, or the user asks.
- **One message by default.** Consolidate into a single message with blank lines between thoughts. Split only when asked.
- **"Ping <person>" about a PR/issue = reply in that link's thread** (`thread_ts`) — not a DM, not just a GitHub mention.
- **Never send a bare URL** — always `[text](url)`. A trailing bare URL swallows the next line's first word into the link (`…/pull/434␊daily`).
- **Linkify file refs** — real `https://github.com/<org>/<repo>/blob/<branch>/<path>`, never a bare path.
- **Blank line after a `>` blockquote**, else the next line merges into the quote (lazy continuation).
- **Backtick code tokens** — identifiers, shas, paths, field names, call_ids: anything to copy or grep.
