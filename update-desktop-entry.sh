#!/bin/bash

# ANSI color codes
RED='\033[0;31m'       # Red color for errors
GREEN='\033[0;32m'     # Green color for success
YELLOW='\033[1;33m'    # Yellow color for warnings
NC='\033[0m'           # No color (reset)

# Define source and destination folders
source_folder="/usr/share/applications/"
destination_folder="$HOME/.local/share/applications/"

# Ensure source folder exists
if [ ! -d "$source_folder" ]; then
    echo -e "${RED}Source folder not found: $source_folder${NC}"
    exit 1
fi

# Ensure destination folder exists
if [ ! -d "$destination_folder" ]; then
    echo -e "${YELLOW}Creating destination folder: $destination_folder${NC}"
    mkdir -p "$destination_folder"
fi

# Function to send desktop notification
send_notification() {
    local title="Sync Desktop Entry - $1"
    local message="$2"
    notify-send -i dialog-information "$title" "$message" --app-name "Sync Desktop Entry"
}

# Loop through desktop files in source folder
for file in "$source_folder"*.desktop; do
    # Extract filename without path
    filename=$(basename "$file")

    # Check if the file exists in the destination folder
    if [ -e "$destination_folder/$filename" ]; then
        # Compare modification times to determine if newer
        source_mtime=$(stat -c %Y "$file")
        dest_mtime=$(stat -c %Y "$destination_folder/$filename")

        if [ "$source_mtime" -gt "$dest_mtime" ]; then
            # Source file is newer, copy it
            cp "$file" "$destination_folder"
            echo -e "${GREEN}Updated $filename in $destination_folder${NC}"
            send_notification "Desktop Entry Updated" "Updated $filename in $destination_folder"
        else
            echo -e "${YELLOW}Skipped $filename, already exists and up-to-date in $destination_folder${NC}"
        fi
    else
        # File doesn't exist in destination folder, copy it
        cp "$file" "$destination_folder"
        echo -e "${GREEN}Copied $filename to $destination_folder${NC}"
        send_notification "Desktop Entry Copied" "Copied $filename to $destination_folder"
    fi
done

echo -e "${GREEN}Desktop entries synchronization complete.${NC}"
send_notification "Synchronization Complete" "Desktop entries synchronization complete."
