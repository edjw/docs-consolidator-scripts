#!/bin/bash

# This script clones the Tailwind Labs TailwindCSS documentation subdirectory and consolidates all the markdown (.mdx) and JavaScript (.js) files into a single file.
# It gives you a single file of the TailwindCSS documentation
# https://tailwindcss.com/docs

set -e # Exit immediately if a command exits with a non-zero status

# Ensure degit is installed
if ! command -v degit &>/dev/null; then
    echo "degit is not installed. Please install it using 'npm install -g degit'"
    exit 1
fi

# Remove the directory if it exists
if [ -d ./tailwindcss-docs ]; then
    echo "Removing existing tailwindcss-docs directory..."
    rm -rf ./tailwindcss-docs
fi

echo "Cloning TailwindCSS docs subdirectory..."
{
    degit tailwindlabs/tailwindcss.com/src/pages/docs tailwindcss-docs
} || {
    echo "Failed to clone the repository. Please check your network connection or the repository URL."
    exit 1
}
echo "Subdirectory cloned."

cd tailwindcss-docs || {
    echo "Failed to navigate to the tailwindcss-docs directory"
    exit 1
}

# The root directory to operate within
ROOT_DIR="."
# Append the current date and time to the filename to avoid overwriting old files
OUTPUT_FILE="all-tailwind-docs_$(date +'%Y-%m-%d_%H-%M-%S').md"
OUTPUT_PATH="$ROOT_DIR/$OUTPUT_FILE"

# Function to concatenate all .mdx and .js files into a single file
concatenate_files() {
    echo "Creating $OUTPUT_PATH"
    true >"$OUTPUT_PATH" # Truncate the file if it exists

    # Find and concatenate .mdx and .js files
    find "$ROOT_DIR" -type f \( -name "*.mdx" -o -name "*.js" \) -print0 | while IFS= read -r -d '' FILE; do
        # Skip the output file
        if [ "$(basename "$FILE")" == "$OUTPUT_FILE" ]; then
            echo "Skipping $FILE"
            continue
        fi
        echo "Adding $FILE to $OUTPUT_FILE"
        cat "$FILE" >>"$OUTPUT_PATH"
        echo -e "\n\n" >>"$OUTPUT_PATH" # Add some spacing between file contents
    done
}

# Concatenate all relevant files into a single file
echo "Starting the concatenation process..."
concatenate_files

echo "Consolidation completed."

ABSOLUTE_OUTPUT_PATH=$(realpath "$OUTPUT_PATH")

echo "Path of the consolidated file: $ABSOLUTE_OUTPUT_PATH"
