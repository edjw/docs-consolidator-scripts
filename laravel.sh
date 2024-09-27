#!/bin/bash

# This script uses degit to clone a specific branch of the Laravel documentation repository
# and consolidates all the markdown (.md) files for that version into a single file.
# https://github.com/laravel/docs

set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure degit is installed
if ! command -v degit &>/dev/null; then
    echo "degit is not installed. Please install it using 'npm install -g degit'"
    exit 1
fi

# Function to display usage information
usage() {
    echo "Usage: $0 [version]"
    echo "Example: $0 11.x"
    echo "If no version is specified, 11 will be used by default."
    echo "Available versions can be found at https://github.com/laravel/docs"
    exit 1
}

# Set default version to 11 if no argument is provided
VERSION=${1:-11}

# Remove the directory if it exists
if [ -d "$SCRIPT_DIR/laravel-docs" ]; then
    echo "Removing existing laravel-docs directory..."
    rm -rf "$SCRIPT_DIR/laravel-docs"
fi

echo "Cloning Laravel docs repository (version $VERSION)..."
degit "laravel/docs#$VERSION.x" "$SCRIPT_DIR/laravel-docs"

# The root directory to operate within
ROOT_DIR="$SCRIPT_DIR/laravel-docs"
OUTPUT_FILE="$SCRIPT_DIR/all-laravel-docs.md"

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

# Clean up the temporary laravel-docs directory
rm -rf "$SCRIPT_DIR/laravel-docs"

echo "Temporary laravel-docs directory removed."
