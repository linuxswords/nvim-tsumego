.PHONY: test test-unit test-all clean

# Default Neovim command
NVIM ?= nvim

# Plenary directory (can be overridden)
PLENARY_DIR ?= $(shell pwd)/.deps/plenary.nvim

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

test: test-unit ## Run unit tests

test-unit: deps ## Run unit tests only
	@echo "$(GREEN)Running unit tests...$(NC)"
	@PLENARY_DIR=$(PLENARY_DIR) $(NVIM) --headless --noplugin -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }" \
		|| (echo "$(RED)Tests failed!$(NC)" && exit 1)
	@echo "$(GREEN)All tests passed!$(NC)"

test-all: test-unit ## Run all tests

deps: ## Install test dependencies
	@if [ ! -d "$(PLENARY_DIR)" ]; then \
		echo "$(YELLOW)Installing plenary.nvim...$(NC)"; \
		mkdir -p .deps; \
		git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git $(PLENARY_DIR); \
		echo "$(GREEN)plenary.nvim installed$(NC)"; \
	fi

clean: ## Clean test dependencies
	@echo "$(YELLOW)Cleaning dependencies...$(NC)"
	@rm -rf .deps
	@echo "$(GREEN)Clean complete$(NC)"

help: ## Show this help message
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
