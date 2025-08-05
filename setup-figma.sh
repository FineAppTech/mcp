#!/bin/bash

# Figma MCP Setup Script
# Usage: ./setup-figma.sh [API_KEY]

set -e

GEMINI_SETTINGS_FILE="$HOME/.gemini/settings.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Figma MCP Setup for Gemini${NC}"
echo

# Check if API key is provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Enter your Figma API key:${NC}"
    read -p "API Key: " API_KEY
    if [ -z "$API_KEY" ]; then
        echo -e "${RED}❌ API key is required${NC}"
        exit 1
    fi
else
    API_KEY="$1"
fi

# Check if Gemini CLI is available
echo "🔍 Checking Gemini CLI installation..."
if ! command -v gemini &> /dev/null; then
    echo -e "${RED}❌ Gemini CLI not found${NC}"
    echo "Installing Gemini CLI via Homebrew..."
    
    # Check if Homebrew is available
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}❌ Homebrew not found. Please install it first:${NC}"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    brew install gemini-cli
    echo -e "${GREEN}✅ Gemini CLI installed${NC}"
else
    echo -e "${GREEN}✅ Gemini CLI found${NC}"
fi

# Check if Node.js/npx is available
echo "🔍 Checking Node.js installation..."
if ! command -v node &> /dev/null || ! command -v npx &> /dev/null; then
    echo -e "${RED}❌ Node.js/npx not found${NC}"
    echo "Installing Node.js via Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}❌ Homebrew not found. Please install it first${NC}"
        exit 1
    fi
    
    brew install node
    echo -e "${GREEN}✅ Node.js installed${NC}"
else
    echo -e "${GREEN}✅ Node.js $(node --version) and npx found${NC}"
fi

# Create directory if it doesn't exist
mkdir -p "$(dirname "$GEMINI_SETTINGS_FILE")"

# Create or update settings file
echo "⚙️  Updating Gemini settings..."

if [ ! -f "$GEMINI_SETTINGS_FILE" ]; then
    echo '{"selectedAuthType": "oauth-personal", "mcpServers": {}}' > "$GEMINI_SETTINGS_FILE"
    echo "Created new settings file"
fi

# Update settings using Python
python3 -c "
import json
import sys

try:
    with open('$GEMINI_SETTINGS_FILE', 'r') as f:
        data = json.load(f)
    
    if 'mcpServers' not in data:
        data['mcpServers'] = {}
    
    data['mcpServers']['Framelink Figma MCP'] = {
        'command': 'npx',
        'args': ['-y', 'figma-developer-mcp', '--figma-api-key=$API_KEY', '--stdio']
    }
    
    with open('$GEMINI_SETTINGS_FILE', 'w') as f:
        json.dump(data, f, indent=2)
    
    print('Settings updated successfully')
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"

echo
echo -e "${GREEN}✅ Framelink Figma MCP has been added to Gemini settings!${NC}"
echo -e "${YELLOW}📁 Settings file: $GEMINI_SETTINGS_FILE${NC}"
echo
echo "🔄 Run 'gemini' command to start using Figma MCP"