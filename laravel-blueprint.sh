#!/bin/bash
# This script clones the Laravel Blueprint documentation and consolidates all the markdown (.md) files into a single file.
# It gives you a single file of the Laravel Blueprint documentation

set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define paths
TEMP_DIR="$SCRIPT_DIR/temp_blueprint"
OUTPUT_FILE="$SCRIPT_DIR/all-laravel-blueprint-docs.md"

# Clean up any existing directories
if [ -d "$TEMP_DIR" ]; then
    echo "Removing existing temporary directory..."
    rm -rf "$TEMP_DIR"
fi

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Clone the repository
echo "Cloning Laravel Blueprint documentation repository..."
git clone --depth 1 https://github.com/laravel-shift/blueprint-docs.git "$TEMP_DIR" || {
    echo "Failed to clone the repository. Please check your network connection or the repository URL."
    rm -rf "$TEMP_DIR"
    exit 1
}

# Navigate to the docs directory
cd "$TEMP_DIR/source/docs" || {
    echo "Failed to navigate to the docs directory"
    cd "$SCRIPT_DIR"
    rm -rf "$TEMP_DIR"
    exit 1
}

# Create the output file
echo "Creating consolidated documentation file..."
true > "$OUTPUT_FILE"

# Function to process markdown files
process_markdown_files() {
    local dir="$1"
    local indent="$2"

    # Process files in current directory first
    for file in "$dir"/*.md; do
        if [ -f "$file" ]; then
            local relative_path="${file#./}"
            echo "${indent}Processing: $relative_path"

            # Add section header
            echo -e "\n\n# ${relative_path}\n" >> "$OUTPUT_FILE"

            # Add file contents
            cat "$file" >> "$OUTPUT_FILE"

            # Add separator
            echo -e "\n---\n" >> "$OUTPUT_FILE"
        fi
    done

    # Process subdirectories
    for subdir in "$dir"/*/; do
        if [ -d "$subdir" ]; then
            process_markdown_files "$subdir" "  $indent"
        fi
    done
}

# Show directory structure before processing
echo -e "\nAvailable documentation files:"
find . -type f -name "*.md" | grep -v "^./all-.*-docs\.md" | sort | sed 's/^.//' | sed 's/^/  /'

# Start processing from the current directory
echo -e "\nStarting documentation consolidation..."
process_markdown_files "." ""

# Clean up
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

echo "Documentation consolidation completed. Running verification..."

# Verification steps
echo -e "\nVerifying content:"

# Count original files
ORIGINAL_COUNT=$(find . -type f -name "*.md" | wc -l)
echo "Number of source markdown files: $ORIGINAL_COUNT"

# Count sections in consolidated file
SECTION_COUNT=$(grep -c "^# " "$OUTPUT_FILE")
echo "Number of sections in consolidated file: $SECTION_COUNT"

# List all source files and their presence in consolidated file
echo -e "\nChecking individual files:"
find . -type f -name "*.md" | grep -v "^./all-.*-docs\.md" | while read -r file; do
    # Get the first line of the source file
    first_line=$(head -n 1 "$file")
    if grep -q "$first_line" "$OUTPUT_FILE"; then
        echo "✓ Found: $file (matched content)"
    else
        # Try to match the file content another way
        file_content=$(cat "$file" | head -n 20) # Check first 20 lines
        if grep -q -F "$file_content" "$OUTPUT_FILE"; then
            echo "✓ Found: $file (matched extended content)"
        else
            echo "✗ Missing: $file"
        fi
    fi
done

# Generate table of contents
echo -e "\nGenerating table of contents..."
echo -e "# Table of Contents\n" > "$OUTPUT_FILE.toc"
grep "^# " "$OUTPUT_FILE" | sed 's/# /- /' >> "$OUTPUT_FILE.toc"

echo -e "\nTable of contents generated: $OUTPUT_FILE.toc"
echo "Documentation consolidation completed successfully!"
echo "Output file: $OUTPUT_FILE"

# Display file size and first few lines
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "\nFile size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    echo -e "\nFirst few lines of the consolidated file:"
    head -n 5 "$OUTPUT_FILE"
else
    echo "Error: Output file was not created successfully."
    exit 1
fi