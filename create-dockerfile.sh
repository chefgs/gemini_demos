#!/bin/bash
#
# Dockerfile Generator Script
#
# This script generates a customized Dockerfile from a template.
# It allows you to choose the base OS and which programming languages to include.
#

# Display help message with examples
display_help_message() {
    echo
    echo "📦 Dockerfile Generator 📦"
    echo "========================="
    echo "This tool helps you create customized Dockerfiles for your projects."
    echo
    echo "Examples:"
    echo "  1. Create a Ubuntu-based Dockerfile with Python:"
    echo "     ./create-dockerfile.sh --base ubuntu --python"
    echo
    echo "  2. Create an Alpine-based Dockerfile with Go and Node.js:"
    echo "     ./create-dockerfile.sh --base alpine --golang --nodejs"
    echo
    echo "  3. Create a Dockerfile with all languages:"
    echo "     ./create-dockerfile.sh --all"
    echo
    echo "  4. Specify custom versions and output file:"
    echo "     ./create-dockerfile.sh --golang --go-version 1.21.0 --nodejs --node-version 18 --output MyDockerfile"
    echo
    echo "For more options, run: ./create-dockerfile.sh --help"
    echo "========================="
    echo
}

# Default values
BASE_OS="ubuntu"
GO_VERSION="1.22.2"
NODE_VERSION="20"
JAVA_VERSION="17"
OUTPUT_FILE="Dockerfile"
TEMPLATE_FILE="templates/Dockerfile-Template"
INCLUDE_GOLANG=false
INCLUDE_RUST=false
INCLUDE_PYTHON=false
INCLUDE_NODEJS=false
INCLUDE_JAVA=false
INCLUDE_ALL=false

# Print usage information
function print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --base <ubuntu|alpine>   Base OS for the Dockerfile (default: ubuntu)"
    echo "  --golang                 Include Golang"
    echo "  --go-version <version>   Golang version to install (default: 1.22.2)"
    echo "  --rust                   Include Rust"
    echo "  --python                 Include Python"
    echo "  --nodejs                 Include Node.js"
    echo "  --node-version <version> Node.js major version to install (default: 20)"
    echo "  --java                   Include Java"
    echo "  --java-version <version> Java version to install (default: 17)"
    echo "  --output <file>          Output file path (default: Dockerfile)"
    echo "  --template <file>        Path to the Dockerfile template (default: templates/Dockerfile-Template)"
    echo "  --all                    Include all programming languages"
    echo "  --help                   Display this help message"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --base)
            BASE_OS="$2"
            if [[ "$BASE_OS" != "ubuntu" && "$BASE_OS" != "alpine" ]]; then
                echo "Error: Base OS must be 'ubuntu' or 'alpine'"
                exit 1
            fi
            shift 2
            ;;
        --golang)
            INCLUDE_GOLANG=true
            shift
            ;;
        --go-version)
            GO_VERSION="$2"
            shift 2
            ;;
        --rust)
            INCLUDE_RUST=true
            shift
            ;;
        --python)
            INCLUDE_PYTHON=true
            shift
            ;;
        --nodejs)
            INCLUDE_NODEJS=true
            shift
            ;;
        --node-version)
            NODE_VERSION="$2"
            shift 2
            ;;
        --java)
            INCLUDE_JAVA=true
            shift
            ;;
        --java-version)
            JAVA_VERSION="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --template)
            TEMPLATE_FILE="$2"
            shift 2
            ;;
        --all)
            INCLUDE_ALL=true
            shift
            ;;
        --help)
            print_usage
            ;;
        *)
            echo "Error: Unknown option '$1'"
            print_usage
            ;;
    esac
done

# Show help message if no language options are specified
if [[ "$INCLUDE_GOLANG" == false && \
      "$INCLUDE_RUST" == false && \
      "$INCLUDE_PYTHON" == false && \
      "$INCLUDE_NODEJS" == false && \
      "$INCLUDE_JAVA" == false && \
      "$INCLUDE_ALL" == false && \
      $# -eq 0 ]]; then
    display_help_message
    exit 0
fi

# Check if template exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

# If --all is specified, include all languages
if [[ "$INCLUDE_ALL" == true ]]; then
    INCLUDE_GOLANG=true
    INCLUDE_RUST=true
    INCLUDE_PYTHON=true
    INCLUDE_NODEJS=true
    INCLUDE_JAVA=true
fi

# Create temporary file for processing
TEMP_FILE=$(mktemp)

# Copy template to temp file
cp "$TEMPLATE_FILE" "$TEMP_FILE"

# Process base OS selection
if [[ "$BASE_OS" == "ubuntu" ]]; then
    # Uncomment Ubuntu, keep Alpine commented
    sed -i.bak 's/#FROM ubuntu:22.04/FROM ubuntu:22.04/' "$TEMP_FILE"
    sed -i.bak 's/# RUN apt-get update/RUN apt-get update/' "$TEMP_FILE"
else # alpine
    # Uncomment Alpine, keep Ubuntu commented
    sed -i.bak 's/FROM ubuntu:22.04/# FROM ubuntu:22.04/' "$TEMP_FILE"
    sed -i.bak 's/# FROM alpine:latest/FROM alpine:latest/' "$TEMP_FILE"
    # Uncomment Alpine specific commands and comment Ubuntu ones
    sed -i.bak 's/# RUN apk update/RUN apk update/' "$TEMP_FILE"
    # Set the default shell to ash for Alpine
    sed -i.bak 's/CMD \["\/bin\/bash"\]/# CMD \["\/bin\/bash"\]/' "$TEMP_FILE"
    sed -i.bak 's/# For Alpine, use "\/bin\/ash" instead of "\/bin\/bash"/CMD \["\/bin\/ash"\]/' "$TEMP_FILE"
fi

# Configure Go
if [[ "$INCLUDE_GOLANG" == true ]]; then
    sed -i.bak "s/ARG INSTALL_GOLANG=true/ARG INSTALL_GOLANG=true/" "$TEMP_FILE"
    sed -i.bak "s/ARG GO_VERSION=1.22.2/ARG GO_VERSION=$GO_VERSION/" "$TEMP_FILE"
else
    sed -i.bak "s/ARG INSTALL_GOLANG=true/ARG INSTALL_GOLANG=false/" "$TEMP_FILE"
fi

# Configure Rust
if [[ "$INCLUDE_RUST" == true ]]; then
    sed -i.bak "s/ARG INSTALL_RUST=true/ARG INSTALL_RUST=true/" "$TEMP_FILE"
else
    sed -i.bak "s/ARG INSTALL_RUST=true/ARG INSTALL_RUST=false/" "$TEMP_FILE"
fi

# Configure Python
if [[ "$INCLUDE_PYTHON" == true ]]; then
    sed -i.bak "s/ARG INSTALL_PYTHON=true/ARG INSTALL_PYTHON=true/" "$TEMP_FILE"
else
    sed -i.bak "s/ARG INSTALL_PYTHON=true/ARG INSTALL_PYTHON=false/" "$TEMP_FILE"
fi

# Configure Node.js
if [[ "$INCLUDE_NODEJS" == true ]]; then
    sed -i.bak "s/ARG INSTALL_NODEJS=true/ARG INSTALL_NODEJS=true/" "$TEMP_FILE"
    sed -i.bak "s/ARG NODE_MAJOR=20/ARG NODE_MAJOR=$NODE_VERSION/" "$TEMP_FILE"
else
    sed -i.bak "s/ARG INSTALL_NODEJS=true/ARG INSTALL_NODEJS=false/" "$TEMP_FILE"
fi

# Configure Java
if [[ "$INCLUDE_JAVA" == true ]]; then
    sed -i.bak "s/ARG INSTALL_JAVA=true/ARG INSTALL_JAVA=true/" "$TEMP_FILE"
    sed -i.bak "s/ARG JAVA_VERSION=17/ARG JAVA_VERSION=$JAVA_VERSION/" "$TEMP_FILE"
else
    sed -i.bak "s/ARG INSTALL_JAVA=true/ARG INSTALL_JAVA=false/" "$TEMP_FILE"
fi

# Move processed file to output destination
mv "$TEMP_FILE" "$OUTPUT_FILE"
rm -f "$TEMP_FILE.bak"  # Remove backup file created by sed

echo "Dockerfile successfully generated at: $OUTPUT_FILE"
echo "Base OS: ${BASE_OS^}"  # Capitalize first letter

# Print what languages were included
LANGUAGES=()
if [[ "$INCLUDE_GOLANG" == true ]]; then LANGUAGES+=("Go $GO_VERSION"); fi
if [[ "$INCLUDE_RUST" == true ]]; then LANGUAGES+=("Rust"); fi
if [[ "$INCLUDE_PYTHON" == true ]]; then LANGUAGES+=("Python"); fi
if [[ "$INCLUDE_NODEJS" == true ]]; then LANGUAGES+=("Node.js $NODE_VERSION"); fi
if [[ "$INCLUDE_JAVA" == true ]]; then LANGUAGES+=("Java $JAVA_VERSION"); fi

if [[ ${#LANGUAGES[@]} -gt 0 ]]; then
    echo "Included languages: ${LANGUAGES[*]}"
else
    echo "No programming languages were enabled"
fi

# Display next steps helper message
echo
echo "📋 Next Steps:"
echo "1. Review your Dockerfile: cat $OUTPUT_FILE"
echo "2. Build your Docker image: docker build -t my-image -f $OUTPUT_FILE ."
echo "3. Run your Docker container: docker run -it --rm my-image"

# Make sure the generated Dockerfile has proper permissions
chmod 644 "$OUTPUT_FILE"

exit 0
