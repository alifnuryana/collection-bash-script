#!/bin/bash

# Define source and destination folders
source_folder="/usr/share/applications/"
destination_folder="$HOME/.local/share/applications/"

# Ensure source folder exists
if [ ! -d "$source_folder" ]; then
    echo "Source folder not found: $source_folder"
    exit 1
fi

# Ensure destination folder exists
if [ ! -d "$destination_folder" ]; then
    echo "Creating destination folder: $destination_folder"
    mkdir -p "$destination_folder"
fi

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
            echo "Updated $filename in $destination_folder"
        else
            echo "Skipped $filename, already exists and up-to-date in $destination_folder"
        fi
    else
        # File doesn't exist in destination folder, copy it
        cp "$file" "$destination_folder"
        echo "Copied $filename to $destination_folder"
    fi
done

echo "Desktop entries synchronization complete."
