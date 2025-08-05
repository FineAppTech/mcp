# Gemini Settings Manager for Framelink Figma MCP
# Usage: make setup-figma API_KEY=your_figma_api_key

API_KEY ?=
GEMINI_SETTINGS_FILE := $(HOME)/.gemini/settings.json

.PHONY: help check-node setup-figma install-node-brew install-node-nvm

help:
	@echo "Available commands:"
	@echo "  setup-figma API_KEY=<key>  - Add Figma MCP to Gemini settings"
	@echo "  check-node                 - Check if Node.js/npx is available"
	@echo "  install-node-nvm          - Install Node.js via nvm (recommended)"
	@echo "  install-node-brew         - Install Node.js via Homebrew"
	@echo "  help                      - Show this help"

check-node:
	@echo "Checking Node.js installation..."
	@which node > /dev/null 2>&1 || { \
		echo "❌ Node.js not found. Run 'make install-node-nvm' or 'make install-node-brew'"; \
		exit 1; \
	}
	@which npx > /dev/null 2>&1 || { \
		echo "❌ npx not found. Please reinstall Node.js"; \
		exit 1; \
	}
	@echo "✅ Node.js and npx are available"
	@node --version
	@npx --version

install-node-nvm:
	@echo "Installing Node.js via nvm..."
	@curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
	@echo "Please run: source ~/.bashrc && nvm install node"

install-node-brew:
	@echo "Installing Node.js via Homebrew..."
	@which brew > /dev/null 2>&1 || { \
		echo "❌ Homebrew not found. Install from https://brew.sh"; \
		exit 1; \
	}
	@brew install node

setup-figma: check-node
	@if [ -z "$(API_KEY)" ]; then \
		echo "❌ API_KEY is required. Usage: make setup-figma API_KEY=your_key"; \
		exit 1; \
	fi
	@echo "Setting up Framelink Figma MCP in Gemini settings..."
	@mkdir -p $(dir $(GEMINI_SETTINGS_FILE))
	@if [ ! -f "$(GEMINI_SETTINGS_FILE)" ]; then \
		echo '{"selectedAuthType": "oauth-personal", "mcpServers": {}}' > $(GEMINI_SETTINGS_FILE); \
		echo "Created new settings file"; \
	fi
	@python3 -c "import json; \
data = json.load(open('$(GEMINI_SETTINGS_FILE)', 'r')); \
data.setdefault('mcpServers', {}); \
data['mcpServers']['Framelink Figma MCP'] = {'command': 'npx', 'args': ['-y', 'figma-developer-mcp', '--figma-api-key=$(API_KEY)', '--stdio']}; \
json.dump(data, open('$(GEMINI_SETTINGS_FILE)', 'w'), indent=2)"
	@echo "✅ Framelink Figma MCP added to Gemini settings"
	@echo "Settings file: $(GEMINI_SETTINGS_FILE)"