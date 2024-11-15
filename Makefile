include env
ENV_FILE:=env
SHELL:=/bin/bash
MAKEFLAGS+=--no-print-directory

# Constants
HOSTNAME:=$(CONTEST)-$(STACK)-$(SERVER_ID)
SSH_DIR:=$(HOME)/.ssh
GIT_DEFAULT_BRANCH:=main
SSH_KEY_PATH:=$(SSH_DIR)/id_ed25519
GIT_USER:=$(STACK)@$(CONTEST)-$(SERVER_ID)
WORKING_DIR:=$(HOME)/$(WORKING_DIR_RELATIVE)

# Default target is setup
default: setup

setup:
	@echo "Setting up..."
	@$(MAKE) check-env
	@$(MAKE) set-hostname
	@$(MAKE) setup-git
	@$(MAKE) setup-ssh
	@$(MAKE) add-hosts
	@$(MAKE) add-authorized-keys
	@$(MAKE) check-github-ssh
	@$(MAKE) setup-working-dir

check-env:
	@echo "Checking if enviorment variables are set..."
	@if [ -z $(CONTEST) ]; then \
		echo "Error: CONTEST is not set"; \
		exit 1; \
	fi
	@if [ -z $(STACK) ]; then \
		echo "Error: STACK is not set"; \
		exit 1; \
	fi
	@if [ -z $(SERVER_ID) ]; then \
		echo "Error: SERVER_ID is not set"; \
		exit 1; \
	fi
	@if [ -z $(GIT_EMAIL) ]; then \
		echo "Error: GIT_EMAIL is not set"; \
		exit 1; \
	fi
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
	@if [ -z $(S1_IP) ] || [ -z $(S2_IP) ] || [ -z $(S3_IP) ]; then \
		echo "Error: S1_IP, S2_IP, or S3_IP is not set"; \
		exit 1; \
	fi

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
	@ssh-keygen -y -f $(SSH_KEY_PATH) > $(SSH_KEY_PATH).pub
	@cp ./ssh-config $(SSH_DIR)/config
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

add-authorized-keys:
	@echo "###############################################"
	@echo "Setting up authorized_keys..."
	@cat $(SSH_KEY_PATH).pub >> $(SSH_DIR)/authorized_keys
	@echo "authorized_keys setup complete."

add-hosts:
	@echo "###############################################"
	@echo "Setting up /etc/hosts..."
	@sudo bash -c "echo $(S1_IP) s1 >> /etc/hosts"
	@sudo bash -c "echo $(S2_IP) s2 >> /etc/hosts"
	@sudo bash -c "echo $(S3_IP) s3 >> /etc/hosts"
	@echo "Add hosts complete."

.PHONY: default setup check-env set-hostname setup-ssh setup-git wait-for-enter setup-working-dir check-github-ssh add-authorized-keys add-hosts
