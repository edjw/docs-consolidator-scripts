#!/bin/bash

# This script clones the Alpine.js documentation subdirectory and consolidates all the markdown (.md) files into a single file.
# It gives you a single file of the Alpine.js documentation
# https://github.com/alpinejs/alpine/tree/main/packages/docs/src/en

set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure degit is installed
if ! command -v degit &>/dev/null; then
    echo "degit is not installed. Please install it using 'npm install -g degit'"
    exit 1
fi

# Remove the directory if it exists
if [ -d "$SCRIPT_DIR/alpinejs-docs" ]; then
    echo "Removing existing alpinejs-docs directory..."
    rm -rf "$SCRIPT_DIR/alpinejs-docs"
fi

echo "Cloning Alpine.js docs subdirectory..."
{
    degit alpinejs/alpine/packages/docs/src/en "$SCRIPT_DIR/alpinejs-docs"
} || {
    echo "Failed to clone the repository. Please check your network connection or the repository URL."
    exit 1
}
echo "Subdirectory cloned."

cd "$SCRIPT_DIR/alpinejs-docs" || {
    echo "Failed to navigate to the alpinejs-docs directory"
    exit 1
}

# The root directory to operate within
ROOT_DIR="."
OUTPUT_FILE="$SCRIPT_DIR/all-alpinejs-docs.md"

# Function to concatenate all .md files into a single file
concatenate_files() {
    echo "Creating $OUTPUT_FILE"
    true >"$OUTPUT_FILE" # Truncate the file if it exists

    # Find and concatenate .md files
    find "$ROOT_DIR" -type f -name "*.md" -print0 | sort -z | while IFS= read -r -d '' FILE; do
        echo "Adding $FILE to $OUTPUT_FILE"
        {
            echo -e "\n\n# File: $FILE\n"
            cat "$FILE"
            echo -e "\n\n"
        } >>"$OUTPUT_FILE"
    done
}

# Concatenate all relevant files into a single file
echo "Starting the concatenation process..."
concatenate_files

echo "Consolidation completed."

echo "Path of the consolidated file: $OUTPUT_FILE"

# Clean up the temporary alpinejs-docs directory
cd "$SCRIPT_DIR" || exit
rm -rf "$SCRIPT_DIR/alpinejs-docs"

echo "Temporary alpinejs-docs directory removed."
