# Commit message style

Global default for git commits, across all repos.

- **One line.** A single concise subject line, no body — unless the user explicitly asks for a longer message.
- **No trailer.** Never append a `Co-Authored-By: Claude …` footer (or any other trailer).
- **Plain `-m`.** Commit with `git commit -m "<subject>"`; do not use a HEREDOC body.

The subject *format* is per-repo, not global — match the repo's existing `git log`. Some repos use Conventional Commits (`fix:`, `feat:`); others use freeform short subjects. Follow what's already there.
