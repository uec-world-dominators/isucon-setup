include env
ENV_FILE:=env
SHELL:=/bin/bash
MAKEFLAGS+=--no-print-directory

# Constants
SSH_DIR:=$(HOME)/.ssh
SSH_KEY:=$(SSH_DIR)/id_ed25519
GIT_DEFAULT_BRANCH:=main
WORKING_DIR:=$(HOME)/$(WORKING_DIR_RELATIVE)

# Default target is setup
default: setup

setup:
	@echo "Setting up..."
	@$(MAKE) check-env
	@$(MAKE) update-os
	@$(MAKE) set-hostname
	@$(MAKE) setup-git
	@$(MAKE) setup-ssh
	@$(MAKE) check-github-ssh
	@$(MAKE) setup-working-dir

check-env:
	@echo "Checking if enviorment variables are set..."
	@if [ -z "$(HOSTNAME)" ]; then \
		echo "Error: HOSTNAME is not set"; \
		exit 1; \
	fi
	@if [ -z "$(GIT_USER)" ]; then \
		echo "Error: GIT_USER is not set"; \
		exit 1; \
	fi
	@if [ -z "$(GIT_EMAIL)" ]; then \
		echo "Error: GIT_EMAIL is not set"; \
		exit 1; \
	fi
	@if [ -z "$(GITHUB_SSH_URL)" ]; then \
		echo "Error: GITHUB_SSH_URL is not set"; \
		exit 1; \
	fi
	@if [ -z "$(WORKING_DIR_RELATIVE)" ]; then \
		echo "Error: WORKING_DIR_RELATIVE is not set"; \
		exit 1; \
	fi
	@if [ -z "$(FIRST_PULL)" ]; then \
		echo "Error: FIRST_PULL is not set"; \
		exit 1; \
	fi

update-os:
	@echo "###############################################"
	@echo "Updating OS..."
	@sudo apt update
	@sudo apt upgrade
	@echo "OS updated."

set-hostname:
	@echo "###############################################"
	@echo "Setting hostname..."
	@sudo hostnamectl set-hostname $(HOSTNAME)
	@sudo sed -i "s/$(shell hostname)/$(HOSTNAME)/g" /etc/hosts
	@echo "Hostname set to $(HOSTNAME)."

setup-git:
	@echo "###############################################"
	@echo "Setting up Git..."
	@git config --global user.name $(GIT_USER)
	@git config --global user.email $(GIT_EMAIL)
	@git config --global init.defaultBranch $(GIT_DEFAULT_BRANCH)
	@echo "Git setup complete."

setup-ssh:
	@echo "###############################################"
	@echo "Setting up SSH..."
	@mkdir -p $(SSH_DIR)
	@ssh-keygen -t ed25519 -C $(HOSTNAME) -f $(SSH_KEY) -N '' > /dev/null
	@cp ./ssh-config $(SSH_DIR)/config
	@echo "Add the following public key to GitHub:"	
	@cat $(SSH_KEY).pub
	@$(MAKE) wait-for-enter
	@echo "SSH setup complete."

wait-for-enter:
	@echo "Press enter to continue..."
	@read _

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
	@if [ "$(FIRST_PULL)" = "true" ]; then \
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

.PHONY: default setup check-env update-os set-hostname setup-ssh setup-git wait-for-enter setup-working-dir check-github-ssh
