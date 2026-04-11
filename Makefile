STOW_DIR := $(shell pwd)
STOW_TARGET := $(HOME)
PACKAGES := zsh git nvim

.PHONY: all install uninstall

all: install

install:
	@for pkg in $(PACKAGES); do \
		echo "Stowing $$pkg..."; \
		stow --dir=$(STOW_DIR) --target=$(STOW_TARGET) $$pkg; \
	done
	@echo "Done."

uninstall:
	@for pkg in $(PACKAGES); do \
		echo "Unstowing $$pkg..."; \
		stow --dir=$(STOW_DIR) --target=$(STOW_TARGET) -D $$pkg; \
	done
	@echo "Done."
