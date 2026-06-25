SHELL := /bin/bash

STOW_DIR      := $(CURDIR)
SKILLS_TARGET := $(HOME)/.agent/skills
CLAUDE_SKILLS := $(HOME)/.claude/skills
CLAUDE_HOME   := $(HOME)/.claude
CLAUDE_MD     := $(CLAUDE_HOME)/CLAUDE.md
HOME_TARGET   := $(HOME)
SKILLS        := $(sort $(foreach f,$(wildcard */*/SKILL.md),$(firstword $(subst /, ,$(f)))))
HOME_FILES    := $(filter-out %/.claude/CLAUDE.md,$(wildcard */.claude/*.md))
HOME_PACKAGES := $(sort $(foreach f,$(HOME_FILES),$(firstword $(subst /, ,$(f)))))
KARPATHY_PACKAGE := karpathy-guidelines
KARPATHY_INCLUDE := @karpathy-guidelines.md
COMMIT_STYLE_PACKAGE := commit-style
COMMIT_STYLE_INCLUDE := @commit-style.md
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

.PHONY: help install uninstall stow unstow restow stow-home unstow-home restow-home install-karpathy-guidelines uninstall-karpathy-guidelines install-commit-style uninstall-commit-style install-git-guardrails uninstall-git-guardrails install-aeq uninstall-aeq install-aeq-awareness uninstall-aeq-awareness list doctor bootstrap

help:
	@echo "Targets:"
	@echo "  install              bootstrap link farm + stow skills"
	@echo "  uninstall            unstow skills (leaves dirs/symlinks alone)"
	@echo "  install-karpathy-guidelines    stow guidelines + add CLAUDE.md import"
	@echo "  uninstall-karpathy-guidelines  remove CLAUDE.md import + unstow guidelines"
	@echo "  install-commit-style           stow commit-style + add CLAUDE.md import"
	@echo "  uninstall-commit-style         remove CLAUDE.md import + unstow commit-style"
	@echo "  install-git-guardrails         stow PreToolUse hook + register in settings.json"
	@echo "  uninstall-git-guardrails       unregister hook + unstow it"
	@echo "  install-aeq          stow the aeq queue CLI into ~/.local/bin"
	@echo "  uninstall-aeq        unstow the aeq queue CLI"
	@echo "  install-aeq-awareness          stow SessionStart hook + register in settings.json"
	@echo "  uninstall-aeq-awareness        unregister hook + unstow it"
	@echo "  stow SKILL=<name>    stow one skill"
	@echo "  unstow SKILL=<name>  unstow one skill"
	@echo "  restow               re-stow every skill (refresh after edits)"
	@echo "  stow-home PACKAGE=<name>    stow one home package"
	@echo "  unstow-home PACKAGE=<name>  unstow one home package"
	@echo "  restow-home                 re-stow home packages"
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
	@for s in $(SKILLS); do \
		echo "stow $$s"; \
		$(STOW_SKILL) $$s; \
	done

uninstall:
	@for s in $(SKILLS); do \
		echo "unstow $$s"; \
		$(STOW_SKILL) -D $$s; \
	done

stow:
	@test -n "$(SKILL)" || (echo "usage: make stow SKILL=<name>"; exit 1)
	@$(MAKE) bootstrap
	$(STOW_SKILL) $(SKILL)

unstow:
	@test -n "$(SKILL)" || (echo "usage: make unstow SKILL=<name>"; exit 1)
	$(STOW_SKILL) -D $(SKILL)

restow: bootstrap
	@for s in $(SKILLS); do \
		echo "restow $$s"; \
		$(STOW_SKILL) -R $$s; \
	done

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

install-karpathy-guidelines:
	@mkdir -p $(CLAUDE_HOME)
	$(STOW_HOME) $(KARPATHY_PACKAGE)
	@touch $(CLAUDE_MD)
	@if grep -Fxq '$(KARPATHY_INCLUDE)' $(CLAUDE_MD); then \
		echo "$(CLAUDE_MD) already imports $(KARPATHY_INCLUDE)"; \
	else \
		printf '\n%s\n' '$(KARPATHY_INCLUDE)' >> $(CLAUDE_MD); \
		echo "added $(KARPATHY_INCLUDE) to $(CLAUDE_MD)"; \
	fi

uninstall-karpathy-guidelines:
	@if [ -f $(CLAUDE_MD) ]; then \
		tmp="$$(mktemp)"; \
		grep -Fxv '$(KARPATHY_INCLUDE)' $(CLAUDE_MD) > "$$tmp"; \
		mv "$$tmp" $(CLAUDE_MD); \
	fi
	$(STOW_HOME) -D $(KARPATHY_PACKAGE)

install-commit-style:
	@mkdir -p $(CLAUDE_HOME)
	$(STOW_HOME) $(COMMIT_STYLE_PACKAGE)
	@touch $(CLAUDE_MD)
	@if grep -Fxq '$(COMMIT_STYLE_INCLUDE)' $(CLAUDE_MD); then \
		echo "$(CLAUDE_MD) already imports $(COMMIT_STYLE_INCLUDE)"; \
	else \
		printf '\n%s\n' '$(COMMIT_STYLE_INCLUDE)' >> $(CLAUDE_MD); \
		echo "added $(COMMIT_STYLE_INCLUDE) to $(CLAUDE_MD)"; \
	fi

uninstall-commit-style:
	@if [ -f $(CLAUDE_MD) ]; then \
		tmp="$$(mktemp)"; \
		grep -Fxv '$(COMMIT_STYLE_INCLUDE)' $(CLAUDE_MD) > "$$tmp"; \
		mv "$$tmp" $(CLAUDE_MD); \
	fi
	$(STOW_HOME) -D $(COMMIT_STYLE_PACKAGE)

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

list:
	@echo "skills:"
	@for s in $(SKILLS); do echo "  $$s"; done
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
	@echo
	@echo "-- skills detected --"
	@for s in $(SKILLS); do echo "  $$s"; done
	@echo
	@echo "-- home packages detected --"
	@for p in $(HOME_PACKAGES); do echo "  $$p"; done
	@echo
	@echo "-- currently linked in $(CLAUDE_SKILLS) --"
	@if [ -d $(CLAUDE_SKILLS) ]; then ls -1 $(CLAUDE_SKILLS) 2>/dev/null | sed 's/^/  /'; else echo "  (none)"; fi
