#!/bin/bash

# ANSI color codes for different states
RED='\033[0;31m'       # Red color for errors
GREEN='\033[0;32m'     # Green color for success
YELLOW='\033[1;33m'    # Yellow color for warnings
NC='\033[0m'           # No color (reset)

if [ $# -ne 2 ]; then
    echo -e "${RED}Error: Incorrect usage.${NC}"
    echo "Usage: $0 <font_name> <font_version>"
    echo "Example: $0 SourceCodePro v3.2.1"
    echo "Get the information font name and version from https://github.com/ryanoasis/nerd-fonts/releases"
    exit 1
fi

FONT_NAME="$1"
FONT_VERSION="$2"
FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

# Function to send desktop notification
send_notification() {
    local title="Nerd Font Installer - $1"
    local message="$2"
    notify-send -i dialog-information "$title" "$message" --app-name "Nerd Font Installer"
}

# Function to prompt user for upgrade/replace decision
prompt_for_upgrade() {
    while true; do
        read -p "A directory '${FONT_DIR}' already exists. Do you want to upgrade/replace the existing fonts? [Y/N] " yn
        case $yn in
            [Yy]* )
                echo -e "${YELLOW}Upgrading existing ${FONT_NAME} Nerd Font...${NC}"
                return 0
                ;;
            [Nn]* )
                echo -e "${RED}Installation aborted. No changes made.${NC}"
                send_notification "Installation Aborted" "Installation aborted. No changes made."
                exit 0
                ;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Check if the font directory already exists
if [ -d "$FONT_DIR" ]; then
    echo -e "${YELLOW}Font directory '${FONT_DIR}' already exists.${NC}"

    # Prompt user for upgrade/replace decision
    prompt_for_upgrade
fi

# Check if the font and version exist on GitHub releases
echo "Checking if ${FONT_NAME} Nerd Font (version ${FONT_VERSION}) exists on GitHub releases..."

# Use curl to fetch the GitHub release page and grep for the version tag
if ! curl -s "https://github.com/ryanoasis/nerd-fonts/releases/tag/${FONT_VERSION}" | grep -q "Release ${FONT_VERSION}"; then
    echo -e "${RED}Error: ${FONT_NAME} Nerd Font version ${FONT_VERSION} not found on GitHub releases.${NC}"
    send_notification "Installation Aborted" "${FONT_NAME} Nerd Font version ${FONT_VERSION} not found on GitHub releases."
    exit 1
fi

# Create directory if it doesn't exist (or if user opted to upgrade/replace)
mkdir -p "${FONT_DIR}"

# Download Nerd Font zip file
echo -e "${GREEN}Downloading ${FONT_NAME} Nerd Font (version ${FONT_VERSION})...${NC}"
curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${FONT_NAME}.zip" --output "${FONT_NAME}.zip"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to download ${FONT_NAME} Nerd Font.${NC}"
    send_notification "Installation Aborted" "Failed to download ${FONT_NAME} Nerd Font."
    exit 1
fi

# Extract only .ttf files from the zip
echo -e "${GREEN}Extracting ${FONT_NAME} Nerd Font...${NC}"
unzip -j "${FONT_NAME}.zip" "*.ttf" -d "${FONT_DIR}"

# Clean up - remove the downloaded zip file
rm "${FONT_NAME}.zip"

# Update font cache
echo -e "${GREEN}Updating font cache...${NC}"
fc-cache -f "${FONT_DIR}"

# Send desktop notification with icon
send_notification "Font Installed" "${FONT_NAME} Nerd Font (version ${FONT_VERSION}) has been successfully installed."
echo -e "${GREEN}Installation complete. ${FONT_NAME} Nerd Font (version ${FONT_VERSION}) is installed in ${FONT_DIR}.${NC}"

