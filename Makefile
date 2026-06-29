# Convenience entry points for tools shipped with this dotfiles repo.
# Run from the repository root.

SHELL := /bin/bash
APPLESCRIPT_DEST := $(HOME)/.local/share/chezmoi-scripts/Ghostty-Nvim.applescript

.PHONY: help ghostty-nvim apply sync-claude sync-claude-dry

help:
	@echo "Available targets:"
	@echo "  apply            - chezmoi apply (sync all dotfiles)"
	@echo "  ghostty-nvim     - render the AppleScript via chezmoi and rebuild ~/Applications/Ghostty-Nvim.app"
	@echo "  sync-claude      - reflect live ~/.claude config into home/dot_claude/"
	@echo "  sync-claude-dry  - dry run of sync-claude (show changes, write nothing)"

apply:
	chezmoi apply

# Reflect the live ~/.claude config back into this repo's home/dot_claude/.
# Does not commit — review with `git diff` afterwards.
sync-claude:
	bash scripts/sync-claude.sh

sync-claude-dry:
	bash scripts/sync-claude.sh -n

# Render the AppleScript template into $(APPLESCRIPT_DEST) via chezmoi, then
# rebuild the .app bundle. The build script is also wired into
# home/.chezmoiscripts/run_onchange_07-..., so `chezmoi apply` keeps it in sync
# automatically; this target is for one-shot rebuilds during local development.
ghostty-nvim:
	chezmoi apply "$(APPLESCRIPT_DEST)"
	bash scripts/applescript/ghostty-nvim/build-ghostty-nvim-app.sh "$(APPLESCRIPT_DEST)"
