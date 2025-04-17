.PHONY: install-bun download unzip setup socket mcp figma-all

ZIP_URL=https://github.com/sonnylazuardi/cursor-talk-to-figma-mcp/archive/refs/heads/main.zip
ZIP_FILE=cursor-talk-to-figma-mcp.zip
DIR_NAME=cursor-talk-to-figma-mcp-main
BUN_PATH=$(HOME)/.bun/bin

export PATH := $(BUN_PATH):$(PATH)

install-bun:
	@which bun > /dev/null 2>&1 || { \
		echo "🔧 Bun not found. Installing..."; \
		curl -fsSL https://bun.sh/install | bash; \
		echo "✅ Bun installed. Restart your shell if this is the first install."; \
	}

download:
	@echo "🌐 Downloading source zip..."
	curl -L $(ZIP_URL) -o $(ZIP_FILE)

unzip:
	@echo "📦 Unzipping..."
	unzip -q -o $(ZIP_FILE)

setup: install-bun download unzip
	cd $(DIR_NAME) && $(BUN_PATH)/bun setup

socket:
	cd $(DIR_NAME) && $(BUN_PATH)/bun socket

mcp:
	cd $(DIR_NAME) && $(BUN_PATH)/bunx cursor-talk-to-figma-mcp

figma-all: setup socket mcp
