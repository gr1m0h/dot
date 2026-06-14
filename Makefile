# Convenience entry points for tools shipped with this dotfiles repo.
# Run from the repository root.

SHELL := /bin/bash
APPLESCRIPT_DEST := $(HOME)/.local/share/chezmoi-scripts/Ghostty-Nvim.applescript

.PHONY: help ghostty-nvim apply

help:
	@echo "Available targets:"
	@echo "  apply         - chezmoi apply (sync all dotfiles)"
	@echo "  ghostty-nvim  - render the AppleScript via chezmoi and rebuild ~/Applications/Ghostty-Nvim.app"

apply:
	chezmoi apply

# Render the AppleScript template into $(APPLESCRIPT_DEST) via chezmoi, then
# rebuild the .app bundle. The build script is also wired into
# home/.chezmoiscripts/run_onchange_07-..., so `chezmoi apply` keeps it in sync
# automatically; this target is for one-shot rebuilds during local development.
ghostty-nvim:
	chezmoi apply "$(APPLESCRIPT_DEST)"
	bash tools/applescript/ghostty-nvim/build-ghostty-nvim-app.sh "$(APPLESCRIPT_DEST)"
