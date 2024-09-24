#!/bin/bash

# This script clones the Filament repository and consolidates all the markdown files into a single file.
# It gives you a single markdown file of the Filament documentation
# https://filamentphp.com/docs

if ! command -v degit &>/dev/null; then
    echo "degit is not installed. Please install it using 'npm install -g degit'"
    exit 1
fi

# Remove the directory if it exists
if [ -d ./filamentphp-docs ]; then
    rm -rf ./filamentphp-docs
fi

degit https://github.com/filamentphp/filament/ filamentphp-docs

cd filamentphp-docs || exit

# The root directory to operate within
ROOT_DIR="."
OUTPUT_FILE="all-filament-docs.md"
OUTPUT_PATH="$ROOT_DIR/$OUTPUT_FILE"

# List of files to exclude
EXCLUDED_FILES=("CODE_OF_CONDUCT.md" "LICENSE.md" "SECURITY.md" "docs-assets/app/README.md")

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

# Function to concatenate all remaining .md files into a single file
concatenate_markdown_files() {
    echo "Creating $OUTPUT_PATH"
    true >"$OUTPUT_PATH" # Truncate the file if it exists
    find "$ROOT_DIR" -type f -name "*.md" -print0 | while IFS= read -r -d '' MD_FILE; do
        # Skip the output file and excluded files
        if [ "$(basename "$MD_FILE")" == "$OUTPUT_FILE" ] || is_excluded "$MD_FILE"; then
            echo "Skipping $MD_FILE"
            continue
        fi
        echo "Adding $MD_FILE to $OUTPUT_FILE"
        cat "$MD_FILE" >>"$OUTPUT_PATH"
        echo -e "\n\n" >>"$OUTPUT_PATH" # Add some spacing between file contents
    done
}

# Remove the output file if it exists
if [ -f "$OUTPUT_PATH" ]; then
    rm "$OUTPUT_PATH"
fi

# Concatenate all markdown files into a single file
concatenate_markdown_files

echo "Consolidation completed."

ABSOLUTE_OUTPUT_PATH=$(realpath "$OUTPUT_PATH")

echo "Path of the consolidated file: $ABSOLUTE_OUTPUT_PATH"
