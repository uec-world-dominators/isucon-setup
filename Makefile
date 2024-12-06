include .env
SHELL:=/bin/bash
MAKEFLAGS+=--no-print-directory

# Constants
SSH_DIR:=$(HOME)/.ssh
GIT_DEFAULT_BRANCH:=main
SSH_KEY_PATH:=$(SSH_DIR)/id_ed25519
WORKING_DIR:=$(HOME)/$(WORKING_DIR_RELATIVE)

# Default target is setup
default: setup

setup:
	@echo "Setting up..."
	@$(MAKE) check-env
	@$(MAKE) setup-ssh
	@$(MAKE) check-github-ssh
	@$(MAKE) setup-working-dir

mv-webapp:
	@echo "Moving $(HOME)/webapp to $(WORKING_DIR)/webapp"
	@mkdir -p $(WORKING_DIR)
	@cp $(HOME)/webapp $(HOME)/old-webapp
	@mv $(HOME)/webapp/* $(HOME)/webapp/.* $(WORKING_DIR)/webapp/
	@rm -rf $(HOME)/webapp
	@ln -s $(WORKING_DIR)/webapp $(HOME)/webapp

check-env:
	@echo "###############################################"
	@echo "Checking if enviorment variables are set..."
	@if [ -z $(GITHUB_SSH_URL) ]; then \
		echo "Error: GITHUB_SSH_URL is not set"; \
		exit 1; \
	fi
	@if [ -z $(WORKING_DIR_RELATIVE) ]; then \
		echo "Error: WORKING_DIR_RELATIVE is not set"; \
		exit 1; \
	fi
	@if [ -z $(FIRST_PULL) ]; then \
		echo "Error: FIRST_PULL is not set"; \
		exit 1; \
	fi
	@echo "All enviorment variables are set."

setup-ssh:
	@echo "###############################################"
	@echo "Setting up SSH..."
	@if [ ! -f $(SSH_KEY_PATH) ]; then \
		echo "Error: SSH key not found"; \
		exit 1; \
	fi
	@ssh-keygen -y -f $(SSH_KEY_PATH) > $(SSH_KEY_PATH).pub
	@cat ./ssh-config >> $(SSH_DIR)/config
	@echo "SSH setup complete."

check-github-ssh:
	@echo "###############################################"
	@echo "Checking if GitHub SSH key is added..."
	@if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then \
		echo "GitHub SSH key is added successfully."; \
	else \
		echo "Error: GitHub SSH key is not added"; \
		exit 1; \
	fi

setup-working-dir:
	@echo "###############################################"
	@echo "Setting up working directory in $(WORKING_DIR)..."
	@git config --global init.defaultBranch $(GIT_DEFAULT_BRANCH)
	@if [ $(FIRST_PULL) = "true" ]; then \
		cd $(WORKING_DIR) && \
		git init && \
		git remote add origin $(GITHUB_SSH_URL) && \
		git pull origin $(GIT_DEFAULT_BRANCH); \
	else \
		cd $(WORKING_DIR) && \
		git init && \
		git remote add origin $(GITHUB_SSH_URL) && \
		git fetch origin $(GIT_DEFAULT_BRANCH) && \
		git reset --hard origin/$(GIT_DEFAULT_BRANCH); \
	fi
	@echo "Working directory setup complete. Navigate to $(WORKING_DIR) to start working."

.PHONY: default setup setup-ssh check-github-ssh setup-working-dir 
