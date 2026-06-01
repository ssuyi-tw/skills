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

STOW_SKILL := stow -d $(STOW_DIR) -t $(SKILLS_TARGET)
STOW_HOME  := stow -d $(STOW_DIR) -t $(HOME_TARGET)

.DEFAULT_GOAL := install

.PHONY: help install uninstall stow unstow restow stow-home unstow-home restow-home install-karpathy-guidelines uninstall-karpathy-guidelines list doctor bootstrap

help:
	@echo "Targets:"
	@echo "  install              bootstrap link farm + stow skills"
	@echo "  uninstall            unstow skills (leaves dirs/symlinks alone)"
	@echo "  install-karpathy-guidelines    stow guidelines + add CLAUDE.md import"
	@echo "  uninstall-karpathy-guidelines  remove CLAUDE.md import + unstow guidelines"
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
