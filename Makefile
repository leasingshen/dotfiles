STOW_DIR    := $(shell pwd)
STOW_TARGET := $(HOME)
PACKAGES    := zsh git nvim systemd

# Packages installed via apt
APT_PKGS := git zsh curl stow build-essential unzip ripgrep fd-find \
            nodejs npm python3 python3-pip

# Packages installed via Homebrew (neovim, starship, direnv are sourced in .zshrc)
BREW_PKGS := neovim starship direnv

BREW := /home/linuxbrew/.linuxbrew/bin/brew

.PHONY: all install uninstall apt brew stow post-install

all: install

# Full install pipeline: deps → stow → post
install: apt brew stow post-install

# ── 1. System packages ─────────────────────────────────────────────────────
apt:
	@echo "==> [apt] Updating package index..."
	@sudo apt-get update -qq
	@echo "==> [apt] Installing: $(APT_PKGS)"
	@sudo apt-get install -y $(APT_PKGS)
	@# fd-find ships the binary as 'fdfind'; expose it as 'fd' for nvim/telescope
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $$(which fdfind) $(HOME)/.local/bin/fd
	@echo "==> [apt] Done."

# ── 2. Homebrew + brew packages ────────────────────────────────────────────
brew:
	@if [ ! -x "$(BREW)" ]; then \
		echo "==> [brew] Installing Homebrew..."; \
		NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "==> [brew] Homebrew already installed, skipping."; \
	fi
	@echo "==> [brew] Installing: $(BREW_PKGS)"
	@eval "$$($(BREW) shellenv)" && brew install $(BREW_PKGS)
	@echo "==> [brew] Done."

# ── 3. GNU Stow ────────────────────────────────────────────────────────────
stow:
	@for pkg in $(PACKAGES); do \
		echo "==> [stow] $$pkg"; \
		stow --dir=$(STOW_DIR) --target=$(STOW_TARGET) $$pkg; \
	done
	@echo "==> [stow] Done."

# ── 4. Post-install ────────────────────────────────────────────────────────
post-install:
	@# Set zsh as the default login shell
	@ZSH_PATH=$$(which zsh 2>/dev/null || echo "$(BREW_PREFIX)/bin/zsh"); \
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
	@eval "$$($(BREW) shellenv)" && \
		nvim --headless -c "Lazy! sync" -c "qa" 2>/dev/null; true
	@echo ""
	@echo "================================================================"
	@echo "  All done! Restart your terminal or run:  exec zsh"
	@echo "================================================================"

# ── Uninstall (remove symlinks) ────────────────────────────────────────────
uninstall:
	@for pkg in $(PACKAGES); do \
		echo "==> [unstow] $$pkg"; \
		stow --dir=$(STOW_DIR) --target=$(STOW_TARGET) -D $$pkg; \
	done
	@echo "==> [unstow] Done."
