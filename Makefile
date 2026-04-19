STOW_DIR    := $(shell pwd)
STOW_TARGET := $(HOME)
PACKAGES    := zsh git nvim systemd starship

NVIM_VERSION := v0.10.4
NVIM_DEB     := nvim-linux-x86_64.deb
NVIM_URL     := https://github.com/neovim/neovim/releases/download/$(NVIM_VERSION)/$(NVIM_DEB)

# All packages sourced from apt
APT_PKGS := git zsh curl stow build-essential unzip ripgrep fd-find \
            nodejs npm python3 python3-pip python3.12-venv direnv

.PHONY: all install uninstall apt neovim starship claude-code stow post-install

all: install

# Full install pipeline
install: apt neovim starship claude-code stow post-install

# ── 1. System packages ─────────────────────────────────────────────────────
apt:
	@echo "==> [apt] Updating package index..."
	@sudo apt-get update -qq
	@echo "==> [apt] Installing: $(APT_PKGS)"
	@sudo apt-get install -y $(APT_PKGS)
	@# fd-find ships as 'fdfind'; expose it as 'fd' for nvim/telescope
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $$(which fdfind) $(HOME)/.local/bin/fd
	@echo "==> [apt] Done."

# ── 2. Neovim (official .deb from GitHub releases) ────────────────────────
neovim:
	@if command -v nvim >/dev/null 2>&1 && \
	        [ "$$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')" = "$$(echo $(NVIM_VERSION) | tr -d v)" ]; then \
		echo "==> [neovim] Already at $(NVIM_VERSION), skipping."; \
	else \
		echo "==> [neovim] Downloading $(NVIM_VERSION)..."; \
		curl -fsSL $(NVIM_URL) -o /tmp/$(NVIM_DEB); \
		echo "==> [neovim] Installing .deb..."; \
		sudo apt-get install -y /tmp/$(NVIM_DEB); \
		rm -f /tmp/$(NVIM_DEB); \
		echo "==> [neovim] Done."; \
	fi

# ── 3. Starship (official install script) ─────────────────────────────────
starship:
	@if command -v starship >/dev/null 2>&1; then \
		echo "==> [starship] Already installed, skipping."; \
	else \
		echo "==> [starship] Installing via official script..."; \
		curl -fsSL https://starship.rs/install.sh | sh -s -- --yes; \
		echo "==> [starship] Done."; \
	fi

# ── 4. Claude Code (official install script) ──────────────────────────────
claude-code:
	@if command -v claude >/dev/null 2>&1; then \
		echo "==> [claude-code] Already installed, skipping."; \
	else \
		echo "==> [claude-code] Installing via official script..."; \
		curl -fsSL https://claude.ai/install.sh | bash; \
		echo "==> [claude-code] Done."; \
	fi

# ── 5. GNU Stow ────────────────────────────────────────────────────────────
stow:
	@for pkg in $(PACKAGES); do \
		echo "==> [stow] $$pkg"; \
		stow --dir=$(STOW_DIR) --target=$(STOW_TARGET) $$pkg; \
	done
	@echo "==> [stow] Done."

# ── 6. Post-install ────────────────────────────────────────────────────────
post-install:
	@# Set zsh as the default login shell
	@ZSH_PATH=$$(which zsh); \
	if [ "$$SHELL" != "$$ZSH_PATH" ]; then \
		echo "==> [shell] Setting default shell to $$ZSH_PATH..."; \
		grep -qxF "$$ZSH_PATH" /etc/shells || echo "$$ZSH_PATH" | sudo tee -a /etc/shells; \
		chsh -s "$$ZSH_PATH"; \
	else \
		echo "==> [shell] Default shell is already zsh, skipping."; \
	fi
	@# Reload systemd user daemon after stowing units
	@echo "==> [systemd] Reloading user daemon..."
	@systemctl --user daemon-reload 2>/dev/null || true
	@echo "==> [systemd] Done."
	@# Bootstrap Neovim plugins headlessly via Lazy.nvim
	@echo "==> [nvim] Syncing plugins (Lazy.nvim)..."
	@nvim --headless -c "Lazy! sync" -c "qa" 2>/dev/null; true
	@echo ""
	@echo "================================================================"
	@echo "  All done! Restart your terminal or run:  exec zsh"
	@echo "================================================================"

# ── Uninstall (remove symlinks only) ──────────────────────────────────────
uninstall:
	@for pkg in $(PACKAGES); do \
		echo "==> [unstow] $$pkg"; \
		stow --dir=$(STOW_DIR) --target=$(STOW_TARGET) -D $$pkg; \
	done
	@echo "==> [unstow] Done."
