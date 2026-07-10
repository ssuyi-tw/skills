SHELL := /bin/bash

STOW_DIR      := $(CURDIR)
SKILLS_TARGET := $(HOME)/.agent/skills
CLAUDE_SKILLS := $(HOME)/.claude/skills
CLAUDE_HOME   := $(HOME)/.claude
CLAUDE_MD     := $(CLAUDE_HOME)/CLAUDE.md
CODEX_HOME    := $(HOME)/.codex
CODEX_MD      := $(CODEX_HOME)/AGENTS.md
CODEX_SKILLS_DIR := $(CODEX_HOME)/skills
CODEX_PERSONAL_SKILLS := $(CODEX_SKILLS_DIR)/personal
CODEX_SKILLS_SOURCE := $(STOW_DIR)/skills
CODEX_RTK := $(CODEX_HOME)/RTK.md
CODEX_KARPATHY := $(CODEX_HOME)/karpathy-guidelines.md
CODEX_COMMIT_STYLE := $(CODEX_HOME)/commit-style.md
CODEX_SLACK_STYLE := $(CODEX_HOME)/slack-style.md
HOME_TARGET   := $(HOME)
SKILLS_PACKAGE := skills
SKILL_NAMES    := $(sort $(notdir $(patsubst %/SKILL.md,%,$(wildcard skills/*/SKILL.md))))
HOME_FILES    := $(filter-out %/.claude/CLAUDE.md,$(wildcard */.claude/*.md))
HOME_PACKAGES := $(sort $(foreach f,$(HOME_FILES),$(firstword $(subst /, ,$(f)))))
# Home packages whose install also adds/removes an `@<package>.md` import in
# CLAUDE.md. Each name is both the stow package and the include basename.
# Adding one is a single entry here — it generates install-<name>/uninstall-<name>.
CLAUDE_MD_PACKAGES := karpathy-guidelines commit-style slack-style
GUARDRAIL_PACKAGE := git-guardrails
GUARDRAIL_DIR     := $(CLAUDE_HOME)/hooks
SETTINGS_JSON     := $(CLAUDE_HOME)/settings.json
GUARDRAIL_CMD     := ~/.claude/hooks/block-dangerous-git.sh
AEQ_PACKAGE := aeq-bin
LOCAL_BIN   := $(HOME)/.local/bin
AWARENESS_PACKAGE := aeq-awareness
AWARENESS_CMD     := ~/.claude/hooks/aeq-session-awareness.sh

STOW_SKILL := stow -d $(STOW_DIR) -t $(SKILLS_TARGET)
STOW_HOME  := stow -d $(STOW_DIR) -t $(HOME_TARGET)

.DEFAULT_GOAL := install

.PHONY: help install uninstall restow install-codex uninstall-codex stow-home unstow-home restow-home install-git-guardrails uninstall-git-guardrails install-aeq uninstall-aeq install-aeq-awareness uninstall-aeq-awareness list doctor bootstrap check check-skills check-shell check-markdown

help:
	@echo "Targets:"
	@echo "  install              bootstrap link farm + stow skills"
	@echo "  uninstall            unstow skills (leaves dirs/symlinks alone)"
	@echo "  install-codex        link Codex AGENTS.md fragments + personal skills"
	@echo "  uninstall-codex      remove Codex links/files managed by install-codex"
	@echo "  install-karpathy-guidelines    stow guidelines + add CLAUDE.md import"
	@echo "  uninstall-karpathy-guidelines  remove CLAUDE.md import + unstow guidelines"
	@echo "  install-commit-style           stow commit-style + add CLAUDE.md import"
	@echo "  uninstall-commit-style         remove CLAUDE.md import + unstow commit-style"
	@echo "  install-slack-style            stow slack-style + add CLAUDE.md import"
	@echo "  uninstall-slack-style          remove CLAUDE.md import + unstow slack-style"
	@echo "  install-git-guardrails         stow PreToolUse hook + register in settings.json"
	@echo "  uninstall-git-guardrails       unregister hook + unstow it"
	@echo "  install-aeq          stow the aeq queue CLI into ~/.local/bin"
	@echo "  uninstall-aeq        unstow the aeq queue CLI"
	@echo "  install-aeq-awareness          stow SessionStart hook + register in settings.json"
	@echo "  uninstall-aeq-awareness        unregister hook + unstow it"
	@echo "  restow               re-stow the skills package (after add/remove)"
	@echo "  stow-home PACKAGE=<name>    stow one home package"
	@echo "  unstow-home PACKAGE=<name>  unstow one home package"
	@echo "  restow-home                 re-stow home packages"
	@echo "  check                run all validation checks"
	@echo "  check-skills         validate SKILL.md frontmatter and structure"
	@echo "  check-shell          syntax-check all .sh scripts"
	@echo "  check-markdown       lint markdown (requires markdownlint-cli2)"
	@echo "  list                 print discovered skills"
	@echo "  doctor               print resolved paths and current state"

bootstrap:
	@mkdir -p $(CLAUDE_SKILLS)
	@mkdir -p $(HOME)/.agent
	@if [ -e $(SKILLS_TARGET) ] && [ ! -L $(SKILLS_TARGET) ]; then \
		echo "error: $(SKILLS_TARGET) exists and is not a symlink — refusing to overwrite"; exit 1; \
	fi
	@if [ ! -L $(SKILLS_TARGET) ]; then \
		ln -s $(CLAUDE_SKILLS) $(SKILLS_TARGET); \
		echo "linked $(SKILLS_TARGET) -> $(CLAUDE_SKILLS)"; \
	fi

install: bootstrap
	$(STOW_SKILL) $(SKILLS_PACKAGE)

uninstall:
	$(STOW_SKILL) -D $(SKILLS_PACKAGE)

restow: bootstrap
	$(STOW_SKILL) -R $(SKILLS_PACKAGE)

install-codex:
	@if [ ! -e $(CLAUDE_HOME)/RTK.md ]; then \
		echo "error: $(CLAUDE_HOME)/RTK.md does not exist"; \
		echo "       install-codex links ~/.codex/RTK.md -> $(CLAUDE_HOME)/RTK.md"; \
		echo "       create RTK.md first, then re-run make install-codex"; \
		exit 1; \
	fi
	@mkdir -p $(CODEX_SKILLS_DIR)
	@if [ -e $(CODEX_PERSONAL_SKILLS) ] && [ ! -L $(CODEX_PERSONAL_SKILLS) ]; then \
		echo "error: $(CODEX_PERSONAL_SKILLS) exists and is not a symlink — refusing to overwrite"; exit 1; \
	fi
	@if [ -L $(CODEX_PERSONAL_SKILLS) ] && [ "$$(readlink $(CODEX_PERSONAL_SKILLS))" != "$(CODEX_SKILLS_SOURCE)" ]; then \
		echo "error: $(CODEX_PERSONAL_SKILLS) points to $$(readlink $(CODEX_PERSONAL_SKILLS)), expected $(CODEX_SKILLS_SOURCE)"; exit 1; \
	fi
	@if [ ! -L $(CODEX_PERSONAL_SKILLS) ]; then \
		ln -s $(CODEX_SKILLS_SOURCE) $(CODEX_PERSONAL_SKILLS); \
		echo "linked $(CODEX_PERSONAL_SKILLS) -> $(CODEX_SKILLS_SOURCE)"; \
	else \
		echo "$(CODEX_PERSONAL_SKILLS) already points to $(CODEX_SKILLS_SOURCE)"; \
	fi
	@if [ -e $(CODEX_RTK) ] && [ ! -L $(CODEX_RTK) ]; then \
		echo "error: $(CODEX_RTK) exists and is not a symlink — refusing to overwrite"; exit 1; \
	fi
	@if [ -L $(CODEX_RTK) ] && [ "$$(readlink $(CODEX_RTK))" != "$(CLAUDE_HOME)/RTK.md" ]; then \
		echo "error: $(CODEX_RTK) points to $$(readlink $(CODEX_RTK)), expected $(CLAUDE_HOME)/RTK.md"; exit 1; \
	fi
	@if [ ! -L $(CODEX_RTK) ]; then ln -s $(CLAUDE_HOME)/RTK.md $(CODEX_RTK); echo "linked $(CODEX_RTK) -> $(CLAUDE_HOME)/RTK.md"; fi
	@if [ -e $(CODEX_KARPATHY) ] && [ ! -L $(CODEX_KARPATHY) ]; then \
		echo "error: $(CODEX_KARPATHY) exists and is not a symlink — refusing to overwrite"; exit 1; \
	fi
	@if [ -L $(CODEX_KARPATHY) ] && [ "$$(readlink $(CODEX_KARPATHY))" != "$(STOW_DIR)/karpathy-guidelines/.claude/karpathy-guidelines.md" ]; then \
		echo "error: $(CODEX_KARPATHY) points to $$(readlink $(CODEX_KARPATHY)), expected $(STOW_DIR)/karpathy-guidelines/.claude/karpathy-guidelines.md"; exit 1; \
	fi
	@if [ ! -L $(CODEX_KARPATHY) ]; then ln -s $(STOW_DIR)/karpathy-guidelines/.claude/karpathy-guidelines.md $(CODEX_KARPATHY); echo "linked $(CODEX_KARPATHY)"; fi
	@if [ -e $(CODEX_COMMIT_STYLE) ] && [ ! -L $(CODEX_COMMIT_STYLE) ]; then \
		echo "error: $(CODEX_COMMIT_STYLE) exists and is not a symlink — refusing to overwrite"; exit 1; \
	fi
	@if [ -L $(CODEX_COMMIT_STYLE) ] && [ "$$(readlink $(CODEX_COMMIT_STYLE))" != "$(STOW_DIR)/commit-style/.claude/commit-style.md" ]; then \
		echo "error: $(CODEX_COMMIT_STYLE) points to $$(readlink $(CODEX_COMMIT_STYLE)), expected $(STOW_DIR)/commit-style/.claude/commit-style.md"; exit 1; \
	fi
	@if [ ! -L $(CODEX_COMMIT_STYLE) ]; then ln -s $(STOW_DIR)/commit-style/.claude/commit-style.md $(CODEX_COMMIT_STYLE); echo "linked $(CODEX_COMMIT_STYLE)"; fi
	@if [ -e $(CODEX_SLACK_STYLE) ] && [ ! -L $(CODEX_SLACK_STYLE) ]; then \
		echo "error: $(CODEX_SLACK_STYLE) exists and is not a symlink — refusing to overwrite"; exit 1; \
	fi
	@if [ -L $(CODEX_SLACK_STYLE) ] && [ "$$(readlink $(CODEX_SLACK_STYLE))" != "$(STOW_DIR)/slack-style/.claude/slack-style.md" ]; then \
		echo "error: $(CODEX_SLACK_STYLE) points to $$(readlink $(CODEX_SLACK_STYLE)), expected $(STOW_DIR)/slack-style/.claude/slack-style.md"; exit 1; \
	fi
	@if [ ! -L $(CODEX_SLACK_STYLE) ]; then ln -s $(STOW_DIR)/slack-style/.claude/slack-style.md $(CODEX_SLACK_STYLE); echo "linked $(CODEX_SLACK_STYLE)"; fi
	@if [ -e $(CODEX_MD) ] && [ ! -f $(CODEX_MD) ]; then \
		echo "error: $(CODEX_MD) exists and is not a regular file — refusing to overwrite"; exit 1; \
	fi
	@tmp="$$(mktemp)" && printf '%s\n%s\n%s\n%s\n' '@RTK.md' '@karpathy-guidelines.md' '@commit-style.md' '@slack-style.md' > "$$tmp" && \
		if [ -f $(CODEX_MD) ] && ! cmp -s "$$tmp" $(CODEX_MD); then \
			rm "$$tmp"; echo "error: $(CODEX_MD) exists with different content — refusing to overwrite"; exit 1; \
		fi && \
		mv "$$tmp" $(CODEX_MD) && echo "wrote $(CODEX_MD)"

uninstall-codex:
	@if [ -L $(CODEX_PERSONAL_SKILLS) ] && [ "$$(readlink $(CODEX_PERSONAL_SKILLS))" = "$(CODEX_SKILLS_SOURCE)" ]; then \
		rm $(CODEX_PERSONAL_SKILLS); echo "removed $(CODEX_PERSONAL_SKILLS)"; \
	fi
	@if [ -L $(CODEX_RTK) ] && [ "$$(readlink $(CODEX_RTK))" = "$(CLAUDE_HOME)/RTK.md" ]; then rm $(CODEX_RTK); echo "removed $(CODEX_RTK)"; fi
	@if [ -L $(CODEX_KARPATHY) ] && [ "$$(readlink $(CODEX_KARPATHY))" = "$(STOW_DIR)/karpathy-guidelines/.claude/karpathy-guidelines.md" ]; then rm $(CODEX_KARPATHY); echo "removed $(CODEX_KARPATHY)"; fi
	@if [ -L $(CODEX_COMMIT_STYLE) ] && [ "$$(readlink $(CODEX_COMMIT_STYLE))" = "$(STOW_DIR)/commit-style/.claude/commit-style.md" ]; then rm $(CODEX_COMMIT_STYLE); echo "removed $(CODEX_COMMIT_STYLE)"; fi
	@if [ -L $(CODEX_SLACK_STYLE) ] && [ "$$(readlink $(CODEX_SLACK_STYLE))" = "$(STOW_DIR)/slack-style/.claude/slack-style.md" ]; then rm $(CODEX_SLACK_STYLE); echo "removed $(CODEX_SLACK_STYLE)"; fi
	@tmp="$$(mktemp)" && printf '%s\n%s\n%s\n%s\n' '@RTK.md' '@karpathy-guidelines.md' '@commit-style.md' '@slack-style.md' > "$$tmp" && \
		if [ -f $(CODEX_MD) ] && cmp -s "$$tmp" $(CODEX_MD); then \
			rm $(CODEX_MD); echo "removed $(CODEX_MD)"; \
		fi; \
		rm -f "$$tmp"

stow-home:
	@test -n "$(PACKAGE)" || (echo "usage: make stow-home PACKAGE=<name>"; exit 1)
	$(STOW_HOME) $(PACKAGE)

unstow-home:
	@test -n "$(PACKAGE)" || (echo "usage: make unstow-home PACKAGE=<name>"; exit 1)
	$(STOW_HOME) -D $(PACKAGE)

restow-home:
	@for p in $(HOME_PACKAGES); do \
		echo "restow home $$p"; \
		$(STOW_HOME) -R $$p; \
	done

# Generate install-<pkg>/uninstall-<pkg> for each CLAUDE_MD_PACKAGES entry.
# Install stows the package and idempotently appends `@<pkg>.md` to CLAUDE.md;
# uninstall strips that line and unstows. $$ escapes one expansion pass (eval),
# $$$$ escapes two (eval + recipe) so the shell sees a literal $.
define claude_md_pkg_rules
.PHONY: install-$(1) uninstall-$(1)
install-$(1):
	@mkdir -p $$(CLAUDE_HOME)
	$$(STOW_HOME) $(1)
	@touch $$(CLAUDE_MD)
	@if grep -Fxq '@$(1).md' $$(CLAUDE_MD); then \
		echo "$$(CLAUDE_MD) already imports @$(1).md"; \
	else \
		printf '\n%s\n' '@$(1).md' >> $$(CLAUDE_MD); \
		echo "added @$(1).md to $$(CLAUDE_MD)"; \
	fi

uninstall-$(1):
	@if [ -f $$(CLAUDE_MD) ]; then \
		tmp="$$$$(mktemp)"; \
		grep -Fxv '@$(1).md' $$(CLAUDE_MD) > "$$$$tmp"; \
		mv "$$$$tmp" $$(CLAUDE_MD); \
	fi
	$$(STOW_HOME) -D $(1)
endef

$(foreach p,$(CLAUDE_MD_PACKAGES),$(eval $(call claude_md_pkg_rules,$(p))))

# stow the hook script into ~/.claude/hooks, then register it as a Bash
# PreToolUse hook in ~/.claude/settings.json (idempotent; preserves other keys).
install-git-guardrails:
	@command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }
	@mkdir -p $(GUARDRAIL_DIR)
	$(STOW_HOME) $(GUARDRAIL_PACKAGE)
	@touch $(SETTINGS_JSON)
	@if [ ! -s $(SETTINGS_JSON) ]; then echo '{}' > $(SETTINGS_JSON); fi
	@tmp="$$(mktemp)" && jq --arg cmd '$(GUARDRAIL_CMD)' '.hooks //= {} | .hooks.PreToolUse //= [] | if ([.hooks.PreToolUse[]?.hooks[]?.command] | index($$cmd)) then . else .hooks.PreToolUse += [{matcher:"Bash",hooks:[{type:"command",command:$$cmd}]}] end' $(SETTINGS_JSON) > "$$tmp" && mv "$$tmp" $(SETTINGS_JSON) && echo "registered guardrail hook in $(SETTINGS_JSON)"

uninstall-git-guardrails:
	@if [ -f $(SETTINGS_JSON) ]; then \
		tmp="$$(mktemp)"; \
		jq --arg cmd '$(GUARDRAIL_CMD)' 'if .hooks.PreToolUse then .hooks.PreToolUse |= map(select([.hooks[]?.command] | index($$cmd) | not)) else . end' $(SETTINGS_JSON) > "$$tmp" && mv "$$tmp" $(SETTINGS_JSON) && echo "unregistered guardrail hook from $(SETTINGS_JSON)"; \
	fi
	$(STOW_HOME) -D $(GUARDRAIL_PACKAGE)

install-aeq:
	@mkdir -p $(LOCAL_BIN)
	$(STOW_HOME) $(AEQ_PACKAGE)
	@if echo "$$PATH" | tr ':' '\n' | grep -qx '$(LOCAL_BIN)'; then \
		echo "linked $(LOCAL_BIN)/aeq (on PATH — try: aeq help)"; \
	else \
		echo "linked $(LOCAL_BIN)/aeq — NOTE: $(LOCAL_BIN) is not on your PATH"; \
	fi

uninstall-aeq:
	$(STOW_HOME) -D $(AEQ_PACKAGE)

# stow the SessionStart hook into ~/.claude/hooks, then register it in
# ~/.claude/settings.json (idempotent; preserves other keys). awareness != execution:
# the hook only surfaces the repo's open queue read-only, it never grabs/runs.
install-aeq-awareness:
	@command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }
	@mkdir -p $(CLAUDE_HOME)/hooks
	$(STOW_HOME) $(AWARENESS_PACKAGE)
	@touch $(SETTINGS_JSON)
	@if [ ! -s $(SETTINGS_JSON) ]; then echo '{}' > $(SETTINGS_JSON); fi
	@tmp="$$(mktemp)" && jq --arg cmd '$(AWARENESS_CMD)' '.hooks //= {} | .hooks.SessionStart //= [] | if ([.hooks.SessionStart[]?.hooks[]?.command] | index($$cmd)) then . else .hooks.SessionStart += [{matcher:"*",hooks:[{type:"command",command:$$cmd}]}] end' $(SETTINGS_JSON) > "$$tmp" && mv "$$tmp" $(SETTINGS_JSON) && echo "registered aeq awareness hook in $(SETTINGS_JSON)"

uninstall-aeq-awareness:
	@if [ -f $(SETTINGS_JSON) ]; then \
		tmp="$$(mktemp)"; \
		jq --arg cmd '$(AWARENESS_CMD)' 'if .hooks.SessionStart then .hooks.SessionStart |= map(select([.hooks[]?.command] | index($$cmd) | not)) else . end' $(SETTINGS_JSON) > "$$tmp" && mv "$$tmp" $(SETTINGS_JSON) && echo "unregistered aeq awareness hook from $(SETTINGS_JSON)"; \
	fi
	$(STOW_HOME) -D $(AWARENESS_PACKAGE)

check: check-skills check-shell check-markdown

check-skills:
	@python3 scripts/validate-skills.py

check-shell:
	@fail=0; for f in $$(find . -name '*.sh' -not -path './.git/*'); do \
		bash -n "$$f" || fail=1; \
	done; exit $$fail

check-markdown:
	@if command -v markdownlint-cli2 >/dev/null 2>&1; then \
		markdownlint-cli2 --config .markdownlint.jsonc "README.md" "skills/*/SKILL.md" "docs/*.md"; \
	elif command -v markdownlint >/dev/null 2>&1; then \
		markdownlint -c .markdownlint.jsonc README.md skills/*/SKILL.md docs/*.md; \
	else \
		echo "skip: markdownlint not found (npm i -g markdownlint-cli2)"; \
	fi

list:
	@echo "skills:"
	@for s in $(SKILL_NAMES); do echo "  $$s"; done
	@echo "home packages:"
	@for p in $(HOME_PACKAGES); do echo "  $$p"; done

doctor:
	@echo "STOW_DIR   = $(STOW_DIR)"
	@echo "SKILLS_TARGET = $(SKILLS_TARGET)"
	@echo "CLAUDE_SKILLS = $(CLAUDE_SKILLS)"
	@echo "HOME_TARGET   = $(HOME_TARGET)"
	@echo
	@echo "-- paths --"
	@if [ -L $(SKILLS_TARGET) ]; then \
		echo "$(SKILLS_TARGET) -> $$(readlink $(SKILLS_TARGET))"; \
	elif [ -d $(SKILLS_TARGET) ]; then \
		echo "$(SKILLS_TARGET) exists (not a symlink)"; \
	else \
		echo "$(SKILLS_TARGET) does not exist"; \
	fi
	@if [ -d $(CLAUDE_SKILLS) ]; then echo "$(CLAUDE_SKILLS) exists"; else echo "$(CLAUDE_SKILLS) does not exist"; fi
	@if [ -L $(CLAUDE_MD) ]; then \
		echo "$(CLAUDE_MD) -> $$(readlink $(CLAUDE_MD))"; \
	elif [ -e $(CLAUDE_MD) ]; then \
		echo "$(CLAUDE_MD) exists (not a symlink)"; \
	else \
		echo "$(CLAUDE_MD) does not exist"; \
	fi
	@if [ -L $(CODEX_PERSONAL_SKILLS) ]; then \
		echo "$(CODEX_PERSONAL_SKILLS) -> $$(readlink $(CODEX_PERSONAL_SKILLS))"; \
	elif [ -e $(CODEX_PERSONAL_SKILLS) ]; then \
		echo "$(CODEX_PERSONAL_SKILLS) exists (not a symlink)"; \
	else \
		echo "$(CODEX_PERSONAL_SKILLS) does not exist"; \
	fi
	@if [ -e $(CODEX_MD) ]; then echo "$(CODEX_MD) exists"; else echo "$(CODEX_MD) does not exist"; fi
	@for f in $(CODEX_RTK) $(CODEX_KARPATHY) $(CODEX_COMMIT_STYLE) $(CODEX_SLACK_STYLE); do \
		if [ -L $$f ]; then \
			echo "$$f -> $$(readlink $$f)"; \
		elif [ -e $$f ]; then \
			echo "$$f exists (not a symlink)"; \
		else \
			echo "$$f does not exist"; \
		fi; \
	done
	@echo
	@echo "-- skills detected --"
	@for s in $(SKILL_NAMES); do echo "  $$s"; done
	@echo
	@echo "-- home packages detected --"
	@for p in $(HOME_PACKAGES); do echo "  $$p"; done
	@echo
	@echo "-- currently linked in $(CLAUDE_SKILLS) --"
	@if [ -d $(CLAUDE_SKILLS) ]; then ls -1 $(CLAUDE_SKILLS) 2>/dev/null | sed 's/^/  /'; else echo "  (none)"; fi
	@echo
	@echo "-- required commands --"
	@for cmd in stow jq python3; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo "  $$cmd: $$(command -v $$cmd)"; \
		else \
			echo "  $$cmd: NOT FOUND"; \
		fi; \
	done
	@if command -v aeq >/dev/null 2>&1; then \
		echo "  aeq: $$(command -v aeq)"; \
	elif [ -x $(LOCAL_BIN)/aeq ]; then \
		echo "  aeq: $(LOCAL_BIN)/aeq (not on PATH)"; \
	else \
		echo "  aeq: NOT INSTALLED"; \
	fi
	@echo
	@echo "-- hook registration --"
	@if [ -f $(SETTINGS_JSON) ] && command -v jq >/dev/null 2>&1; then \
		if jq -e '[.hooks.PreToolUse[]?.hooks[]?.command] | index("$(GUARDRAIL_CMD)")' $(SETTINGS_JSON) >/dev/null 2>&1; then \
			echo "  git-guardrails (PreToolUse): registered"; \
		else \
			echo "  git-guardrails (PreToolUse): not registered"; \
		fi; \
		if jq -e '[.hooks.SessionStart[]?.hooks[]?.command] | index("$(AWARENESS_CMD)")' $(SETTINGS_JSON) >/dev/null 2>&1; then \
			echo "  aeq-awareness (SessionStart): registered"; \
		else \
			echo "  aeq-awareness (SessionStart): not registered"; \
		fi; \
	else \
		echo "  (cannot check — jq or settings.json missing)"; \
	fi
