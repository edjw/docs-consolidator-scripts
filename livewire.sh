#!/bin/bash

# This script clones the Livewire documentation subdirectory and consolidates all the markdown files into a single file.

# https://livewire.laravel.com/docs/quickstart

set -e # Exit immediately if a command exits with a non-zero status

# Ensure git is installed
if ! command -v git &>/dev/null; then
    echo "git is not installed."
    exit 1
fi

# Remove the directory if it exists
if [ -d ./livewire-docs ]; then
    echo "Removing existing livewire-docs directory..."
    rm -rf ./livewire-docs
fi

echo "Cloning Livewire docs subdirectory..."
{
    git clone --depth 1 https://github.com/livewire/livewire.git livewire-docs
} || {
    echo "Failed to clone the repository. Please check your network connection or the repository URL."
    exit 1
}
echo "Subdirectory cloned."

cd livewire-docs || {
    echo "Failed to navigate to the livewire-docs directory"
    exit 1
}

# The root directory to operate within
ROOT_DIR="./docs"
OUTPUT_FILE="all-livewire-docs.md"
OUTPUT_PATH="../$OUTPUT_FILE"

# List of files to exclude
EXCLUDED_FILES=("Untitled.md" "Untitled1.md" "Untitled2.md" "__nav.md" "__outline.md")

# Function to check if a file is in the exclusion list
is_excluded() {
    local file_name="$1"
    for excluded_file in "${EXCLUDED_FILES[@]}"; do
        if [[ "$file_name" == *"$excluded_file" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to concatenate all .md files into a single file
concatenate_files() {
    echo "Creating $OUTPUT_PATH"
    true >"$OUTPUT_PATH" # Truncate the file if it exists

    # Find and concatenate .md files
    find "$ROOT_DIR" -type f -name "*.md" -print0 | while IFS= read -r -d '' FILE; do
        # Skip excluded files
        if is_excluded "$(basename "$FILE")"; then
            echo "Skipping $FILE"
            continue
        fi
        echo "Adding $FILE to $OUTPUT_FILE"
        {
            echo -e "\n\n# File: $FILE\n"
            cat "$FILE"
            echo -e "\n\n"
        } >>"$OUTPUT_PATH"
    done
}

# Concatenate all relevant files into a single file
echo "Starting the concatenation process..."
concatenate_files

echo "Consolidation completed."

ABSOLUTE_OUTPUT_PATH=$(realpath "$OUTPUT_PATH")

echo "Path of the consolidated file: $ABSOLUTE_OUTPUT_PATH"
