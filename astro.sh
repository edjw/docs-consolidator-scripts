#!/bin/bash

# This script clones the Astro documentation subdirectory and consolidates all the markdown (.mdx) files into a single file.
# It gives you a single file of the Astro documentation
# https://docs.astro.build/en/getting-started/

set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure degit is installed
if ! command -v degit &>/dev/null; then
    echo "degit is not installed. Please install it using 'npm install -g degit'"
    exit 1
fi

# Remove the directory if it exists
if [ -d "$SCRIPT_DIR/astro-docs" ]; then
    echo "Removing existing astro-docs directory..."
    rm -rf "$SCRIPT_DIR/astro-docs"
fi

echo "Cloning Astro docs subdirectory..."
{
    degit withastro/docs/src/content/docs/en "$SCRIPT_DIR/astro-docs"
} || {
    echo "Failed to clone the repository. Please check your network connection or the repository URL."
    exit 1
}
echo "Subdirectory cloned."

cd "$SCRIPT_DIR/astro-docs" || {
    echo "Failed to navigate to the astro-docs directory"
    exit 1
}

# The root directory to operate within
ROOT_DIR="."
# Output file will be in the same directory as the script
OUTPUT_FILE="$SCRIPT_DIR/all-astro-docs.md"

# Function to concatenate all .mdx files into a single file
concatenate_files() {
    echo "Creating $OUTPUT_FILE"
    true >"$OUTPUT_FILE" # Truncate the file if it exists

    # Find and concatenate .mdx files
    find "$ROOT_DIR" -type f \( -name "*.mdx" \) -print0 | while IFS= read -r -d '' FILE; do
        echo "Adding $FILE to $OUTPUT_FILE"
        cat "$FILE" >>"$OUTPUT_FILE"
        echo -e "\n\n" >>"$OUTPUT_FILE" # Add some spacing between file contents
    done
}

# Concatenate all relevant files into a single file
echo "Starting the concatenation process..."
concatenate_files

echo "Consolidation completed."

echo "Path of the consolidated file: $OUTPUT_FILE"

# Clean up the temporary astro-docs directory
cd "$SCRIPT_DIR" || exit
rm -rf "$SCRIPT_DIR/astro-docs"

echo "Temporary astro-docs directory removed."
