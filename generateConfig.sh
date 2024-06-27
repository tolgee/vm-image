#!/bin/bash

set -e

# Function to generate a random alphanumeric string of a specified length
generate_random_string() {
    local length="$1"
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length" || true
}

# Length of the random string, default is 12
length=32

# Files to be processed
files=("templates/config.template.yaml" "templates/docker-compose.template.yaml")

# Generate a random string
random_string=$(generate_random_string "$length")
image_version=$(curl -s "https://hub.docker.com/v2/namespaces/tolgee/repositories/tolgee/tags?page_size=20" \
| jq -r '.results[] | select(.name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$")) | .name' \
| sort -V \
| tail -n 1)

for file in "${files[@]}"; do
    # Check if the file exists
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found!"
        continue
    fi

    # Output file path (current working directory without '.template' suffix)
    output_file="${file#templates/}"
    output_file="${output_file%.template.yaml}.yaml"

    # Replace placeholders and create output file in the current directory
    sed "s/{postgresPassword}/$random_string/g" "$file" \
    | sed "s/{imageVersion}/$image_version/g" \
    > "$output_file"

    echo "Processed '$file' and saved as '$output_file'."
done

echo "Replacement completed in all files."
