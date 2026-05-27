SHELL := /bin/bash

STOW_DIR  := $(CURDIR)
TARGET    := $(HOME)/.agent/skills
CLAUDE    := $(HOME)/.claude/skills
META      := LICENSE Makefile README.md .gitignore .git
SKILLS    := $(filter-out $(META),$(patsubst %/,%,$(wildcard */)))

STOW := stow -d $(STOW_DIR) -t $(TARGET)

.DEFAULT_GOAL := install

.PHONY: help install uninstall stow unstow restow list doctor bootstrap

help:
	@echo "Targets:"
	@echo "  install              bootstrap link farm + stow every skill"
	@echo "  uninstall            unstow every skill (leaves dirs/symlinks alone)"
	@echo "  stow SKILL=<name>    stow one skill"
	@echo "  unstow SKILL=<name>  unstow one skill"
	@echo "  restow               re-stow every skill (refresh after edits)"
	@echo "  list                 print discovered skills"
	@echo "  doctor               print resolved paths and current state"

bootstrap:
	@mkdir -p $(CLAUDE)
	@mkdir -p $(HOME)/.agent
	@if [ -e $(TARGET) ] && [ ! -L $(TARGET) ]; then \
		echo "error: $(TARGET) exists and is not a symlink — refusing to overwrite"; exit 1; \
	fi
	@if [ ! -L $(TARGET) ]; then \
		ln -s $(CLAUDE) $(TARGET); \
		echo "linked $(TARGET) -> $(CLAUDE)"; \
	fi

install: bootstrap
	@for s in $(SKILLS); do \
		echo "stow $$s"; \
		$(STOW) $$s; \
	done

uninstall:
	@for s in $(SKILLS); do \
		echo "unstow $$s"; \
		$(STOW) -D $$s; \
	done

stow:
	@test -n "$(SKILL)" || (echo "usage: make stow SKILL=<name>"; exit 1)
	@$(MAKE) bootstrap
	$(STOW) $(SKILL)

unstow:
	@test -n "$(SKILL)" || (echo "usage: make unstow SKILL=<name>"; exit 1)
	$(STOW) -D $(SKILL)

restow: bootstrap
	@for s in $(SKILLS); do \
		echo "restow $$s"; \
		$(STOW) -R $$s; \
	done

list:
	@for s in $(SKILLS); do echo "  $$s"; done

doctor:
	@echo "STOW_DIR   = $(STOW_DIR)"
	@echo "TARGET     = $(TARGET)"
	@echo "CLAUDE     = $(CLAUDE)"
	@echo
	@echo "-- paths --"
	@if [ -L $(TARGET) ]; then \
		echo "$(TARGET) -> $$(readlink $(TARGET))"; \
	elif [ -d $(TARGET) ]; then \
		echo "$(TARGET) exists (not a symlink)"; \
	else \
		echo "$(TARGET) does not exist"; \
	fi
	@if [ -d $(CLAUDE) ]; then echo "$(CLAUDE) exists"; else echo "$(CLAUDE) does not exist"; fi
	@echo
	@echo "-- skills detected --"
	@for s in $(SKILLS); do echo "  $$s"; done
	@echo
	@echo "-- currently linked in $(CLAUDE) --"
	@if [ -d $(CLAUDE) ]; then ls -1 $(CLAUDE) 2>/dev/null | sed 's/^/  /'; else echo "  (none)"; fi
