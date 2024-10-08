#!/bin/bash

# This script clones the Tailwind Labs TailwindCSS documentation subdirectory and consolidates all the markdown (.mdx) and JavaScript (.js) files into a single file.
# It gives you a single file of the TailwindCSS documentation
# https://tailwindcss.com/docs

set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure degit is installed
if ! command -v degit &>/dev/null; then
    echo "degit is not installed. Please install it using 'npm install -g degit'"
    exit 1
fi

# Remove the directory if it exists
if [ -d "$SCRIPT_DIR/tailwindcss-docs" ]; then
    echo "Removing existing tailwindcss-docs directory..."
    rm -rf "$SCRIPT_DIR/tailwindcss-docs"
fi

echo "Cloning TailwindCSS docs subdirectory..."
{
    degit tailwindlabs/tailwindcss.com/src/pages/docs "$SCRIPT_DIR/tailwindcss-docs"
} || {
    echo "Failed to clone the repository. Please check your network connection or the repository URL."
    exit 1
}
echo "Subdirectory cloned."

cd "$SCRIPT_DIR/tailwindcss-docs" || {
    echo "Failed to navigate to the tailwindcss-docs directory"
    exit 1
}

# The root directory to operate within
ROOT_DIR="."

OUTPUT_FILE="$SCRIPT_DIR/all-tailwind-docs.md"

# Function to concatenate all .mdx and .js files into a single file
concatenate_files() {
    echo "Creating $OUTPUT_FILE"
    true >"$OUTPUT_FILE" # Truncate the file if it exists

    # Find and concatenate .mdx and .js files
    find "$ROOT_DIR" -type f \( -name "*.mdx" -o -name "*.js" \) -print0 | while IFS= read -r -d '' FILE; do
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

# Clean up the temporary tailwindcss-docs directory
cd "$SCRIPT_DIR" || exit
rm -rf "$SCRIPT_DIR/tailwindcss-docs"

echo "Temporary tailwindcss-docs directory removed."
