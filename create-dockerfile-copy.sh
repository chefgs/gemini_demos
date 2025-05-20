#!/bin/bash

# Script to generate a Dockerfile from the template
# Usage: ./create-dockerfile.sh [options]

# Default values
OUTPUT_FILE="Dockerfile"
BASE_OS="ubuntu"
INSTALL_GOLANG="false"
INSTALL_RUST="false"
INSTALL_PYTHON="false"
INSTALL_NODEJS="false"
INSTALL_JAVA="false"
GO_VERSION="1.22.2"
NODE_MAJOR="20"
JAVA_VERSION="17"
TEMPLATE_PATH="./templates/Dockerfile-Template"

# Function to display help
show_help() {
    echo "Usage: ./create-dockerfile.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -o, --output FILE       Output Dockerfile name (default: Dockerfile)"
    echo "  --os OS                 Base OS: ubuntu or alpine (default: ubuntu)"
    echo "  --golang                Include Golang"
    echo "  --rust                  Include Rust"
    echo "  --python                Include Python"
    echo "  --nodejs                Include Node.js"
    echo "  --java                  Include Java"
    echo "  --go-version VERSION    Golang version (default: 1.22.2)"
    echo "  --node-version VERSION  Node.js major version (default: 20)"
    echo "  --java-version VERSION  Java version (default: 17)"
    echo "  --template PATH         Path to template file (default: ./templates/Dockerfile-Template)"
    echo ""
    echo "Example:"
    echo "  ./create-dockerfile.sh --os alpine --golang --nodejs --node-version 18 -o Dockerfile.node"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --os)
            BASE_OS="$2"
            shift 2
            ;;
        --golang)
            INSTALL_GOLANG="true"
            shift
            ;;
        --rust)
            INSTALL_RUST="true"
            shift
            ;;
        --python)
            INSTALL_PYTHON="true"
            shift
            ;;
        --nodejs)
            INSTALL_NODEJS="true"
            shift
            ;;
        --java)
            INSTALL_JAVA="true"
            shift
            ;;
        --go-version)
            GO_VERSION="$2"
            shift 2
            ;;
        --node-version)
            NODE_MAJOR="$2"
            shift 2
            ;;
        --java-version)
            JAVA_VERSION="$2"
            shift 2
            ;;
        --template)
            TEMPLATE_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate OS choice
if [[ "$BASE_OS" != "ubuntu" && "$BASE_OS" != "alpine" ]]; then
    echo "Error: OS must be either 'ubuntu' or 'alpine'"
    exit 1
fi

# Check if template exists
if [[ ! -f "$TEMPLATE_PATH" ]]; then
    echo "Error: Template file not found at $TEMPLATE_PATH"
    exit 1
fi

# Create a copy of the template
cp "$TEMPLATE_PATH" "$OUTPUT_FILE"

# Function to uncomment a section
uncomment_section() {
    local section=$1
    local file=$2
    sed -i.bak "/^#--------- $section ---------/,/^#---------/ s/^# //" "$file"
    rm -f "${file}.bak"
}

# Function to enable/disable a language
configure_language() {
    local lang=$1
    local install=$2
    local file=$3
    sed -i.bak "s/ARG INSTALL_${lang}=true/ARG INSTALL_${lang}=${install}/" "$file"
    rm -f "${file}.bak"
}

# Set versions
sed -i.bak "s/ARG GO_VERSION=1.22.2/ARG GO_VERSION=${GO_VERSION}/" "$OUTPUT_FILE"
sed -i.bak "s/ARG NODE_MAJOR=20/ARG NODE_MAJOR=${NODE_MAJOR}/" "$OUTPUT_FILE"
sed -i.bak "s/ARG JAVA_VERSION=17/ARG JAVA_VERSION=${JAVA_VERSION}/" "$OUTPUT_FILE"
rm -f "${OUTPUT_FILE}.bak"

# Configure base OS
if [[ "$BASE_OS" == "alpine" ]]; then
    # Comment out Ubuntu section
    sed -i.bak '/^FROM ubuntu/,/^$/ s/^/#/' "$OUTPUT_FILE"
    # Uncomment Alpine section
    sed -i.bak '/^# FROM alpine/,/^$/ s/^# //' "$OUTPUT_FILE"
    # Uncomment Alpine-specific installations
    if [[ "$INSTALL_GOLANG" == "true" ]]; then
        sed -i.bak '/^# RUN if \[ "\$INSTALL_GOLANG" = "true" \]; then \\$/,/^#     fi/ s/^# //' "$OUTPUT_FILE"
    fi
    if [[ "$INSTALL_PYTHON" == "true" ]]; then
        sed -i.bak '/^# RUN if \[ "\$INSTALL_PYTHON" = "true" \]; then \\$/,/^#     fi/ s/^# //' "$OUTPUT_FILE"
    fi
    if [[ "$INSTALL_NODEJS" == "true" ]]; then
        sed -i.bak '/^# RUN if \[ "\$INSTALL_NODEJS" = "true" \]; then \\$/,/^#     fi/ s/^# //' "$OUTPUT_FILE"
    fi
    if [[ "$INSTALL_JAVA" == "true" ]]; then
        sed -i.bak '/^# RUN if \[ "\$INSTALL_JAVA" = "true" \]; then \\$/,/^#     fi/ s/^# //' "$OUTPUT_FILE"
    fi
    # Change default CMD to ash
    sed -i.bak 's/CMD \["\/bin\/bash"\]/CMD \["\/bin\/ash"\]/' "$OUTPUT_FILE"
    rm -f "${OUTPUT_FILE}.bak"
fi

# Configure languages
configure_language "GOLANG" "$INSTALL_GOLANG" "$OUTPUT_FILE"
configure_language "RUST" "$INSTALL_RUST" "$OUTPUT_FILE"
configure_language "PYTHON" "$INSTALL_PYTHON" "$OUTPUT_FILE"
configure_language "NODEJS" "$INSTALL_NODEJS" "$OUTPUT_FILE"
configure_language "JAVA" "$INSTALL_JAVA" "$OUTPUT_FILE"

echo "Dockerfile generated at $OUTPUT_FILE"
echo ""
echo "Configuration:"
echo "  Base OS: $BASE_OS"
echo "  Golang: $INSTALL_GOLANG (version $GO_VERSION)"
echo "  Rust: $INSTALL_RUST"
echo "  Python: $INSTALL_PYTHON"
echo "  Node.js: $INSTALL_NODEJS (version $NODE_MAJOR)"
echo "  Java: $INSTALL_JAVA (version $JAVA_VERSION)"
