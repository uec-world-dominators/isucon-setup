include env
ENV_FILE:=env

# Constants
SSH_DIR:=$(HOME)/.ssh
SSH_KEY:=$(SSH_DIR)/id_ed25519
GIT_DEFAULT_BRANCH:=main
WORKING_DIR:=$(HOME)/$(WORKING_DIR_RELATIVE)

# Default target is setup
default: setup

setup:
	@echo "Setting up..."
	@check-env
	@update-os
	@set-hostname
	@setup-git
	@setup-ssh
	@wait-for-enter
	@setup-working-dir

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
	@echo "Updating OS..."
	@sudo apt update
	@sudo apt upgrade

set-hostname:
	@echo "Setting hostname..."
	@sudo hostnamectl set-hostname $(HOSTNAME)
	@sudo sed -i "s/$(shell hostname)/$(HOSTNAME)/g" /etc/hosts

setup-git:
	@echo "Setting up Git..."
	@git config --global user.name $(GIT_USER)
	@git config --global user.email $(GIT_EMAIL)
	@git config --global init.defaultBranch $(GIT_DEFAULT_BRANCH)

setup-ssh:
	@echo "Setting up SSH..."
	@mkdir -p $(SSH_DIR)
	@ssh-keygen -t ed25519 -C $(HOSTNAME) -f $(SSH_KEY)
	@cp ./ssh-config $(SSH_DIR)/config
	@echo "Add the following public key to GitHub:"	
	@cat $(SSH_KEY).pub

wait-for-enter:
	@echo "Press enter to continue..."
	@read

setup-working-dir:
	@echo "Setting up working directory..."
	@cd $(WORKING_DIR)
	@git init
	@git remote add origin $(GITHUB_SSH_URL)

	@if [ "$(FIRST_PULL)" = "true" ]; then \
		git pull origin $(GIT_DEFAULT_BRANCH); \
	else \
		git fetch origin $(GIT_DEFAULT_BRANCH); \
		git reset --hard origin/$(GIT_DEFAULT_BRANCH); \
	fi

.PHONY: default setup check-env update-os set-hostname setup-ssh setup-git wait-for-enter setup-working-dir
