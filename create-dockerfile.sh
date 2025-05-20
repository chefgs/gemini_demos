#!/bin/bash
#
# Dockerfile Generator Script
#
# This script generates a customized Dockerfile directly.
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

# If --all is specified, include all languages
if [[ "$INCLUDE_ALL" == true ]]; then
    INCLUDE_GOLANG=true
    INCLUDE_RUST=true
    INCLUDE_PYTHON=true
    INCLUDE_NODEJS=true
    INCLUDE_JAVA=true
fi

# Create the Dockerfile content
generate_dockerfile() {
    # Start with the base image
    if [[ "$BASE_OS" == "ubuntu" ]]; then
        echo "FROM ubuntu:22.04"
        echo ""
        echo "# Avoid prompts from apt"
        echo "ENV DEBIAN_FRONTEND=noninteractive"
        echo ""
        echo "# Update package lists and install common tools"
        echo "RUN apt-get update && apt-get install -y \\"
        echo "    curl \\"
        echo "    wget \\"
        echo "    git \\"
        echo "    build-essential \\"
        echo "    ca-certificates \\"
        echo "    && apt-get clean \\"
        echo "    && rm -rf /var/lib/apt/lists/*"
    else # alpine
        echo "FROM alpine:latest"
        echo ""
        echo "# Update package lists and install common tools"
        echo "RUN apk update && apk add --no-cache \\"
        echo "    curl \\"
        echo "    wget \\"
        echo "    git \\"
        echo "    build-base \\"
        echo "    ca-certificates"
    fi
    
    echo ""
    echo "# Create a working directory"
    echo "WORKDIR /app"
    echo ""
    
    # Add language-specific sections based on user selection
    
    # Go installation
    if [[ "$INCLUDE_GOLANG" == true ]]; then
        echo "# Install Golang"
        if [[ "$BASE_OS" == "ubuntu" ]]; then
            echo "RUN curl -LO https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \\"
            echo "    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \\"
            echo "    && rm go${GO_VERSION}.linux-amd64.tar.gz"
        else # alpine
            echo "RUN wget -O go.tgz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \\"
            echo "    && tar -C /usr/local -xzf go.tgz \\"
            echo "    && rm go.tgz"
        fi
        echo "ENV PATH=\$PATH:/usr/local/go/bin"
        echo "ENV GOPATH=/go"
        echo "ENV PATH=\$PATH:\$GOPATH/bin"
        echo ""
    fi
    
    # Rust installation
    if [[ "$INCLUDE_RUST" == true ]]; then
        echo "# Install Rust"
        if [[ "$BASE_OS" == "ubuntu" ]]; then
            echo "RUN apt-get update && apt-get install -y \\"
            echo "    rustc \\"
            echo "    cargo \\"
            echo "    && apt-get clean \\"
            echo "    && rm -rf /var/lib/apt/lists/*"
        else # alpine
            echo "RUN apk add --no-cache \\"
            echo "    rust \\"
            echo "    cargo"
        fi
        echo ""
    fi
    
    # Python installation
    if [[ "$INCLUDE_PYTHON" == true ]]; then
        echo "# Install Python"
        if [[ "$BASE_OS" == "ubuntu" ]]; then
            echo "RUN apt-get update && apt-get install -y \\"
            echo "    python3 \\"
            echo "    python3-pip \\"
            echo "    python3-venv \\"
            echo "    && apt-get clean \\"
            echo "    && rm -rf /var/lib/apt/lists/* \\"
            echo "    && ln -s /usr/bin/python3 /usr/bin/python"
        else # alpine
            echo "RUN apk add --no-cache \\"
            echo "    python3 \\"
            echo "    py3-pip \\"
            echo "    && ln -sf /usr/bin/python3 /usr/bin/python"
        fi
        echo "ENV PATH=\$PATH:/usr/local/bin"
        echo ""
    fi
    
    # Node.js installation
    if [[ "$INCLUDE_NODEJS" == true ]]; then
        echo "# Install Node.js"
        if [[ "$BASE_OS" == "ubuntu" ]]; then
            echo "RUN apt-get update && apt-get install -y ca-certificates curl gnupg \\"
            echo "    && mkdir -p /etc/apt/keyrings \\"
            echo "    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \\"
            echo "    && echo \"deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main\" | tee /etc/apt/sources.list.d/nodesource.list \\"
            echo "    && apt-get update && apt-get install -y nodejs \\"
            echo "    && apt-get clean \\"
            echo "    && rm -rf /var/lib/apt/lists/*"
        else # alpine
            echo "RUN apk add --no-cache \\"
            echo "    nodejs \\"
            echo "    npm"
        fi
        echo ""
    fi
    
    # Java installation
    if [[ "$INCLUDE_JAVA" == true ]]; then
        echo "# Install Java"
        if [[ "$BASE_OS" == "ubuntu" ]]; then
            echo "RUN apt-get update && apt-get install -y \\"
            echo "    openjdk-${JAVA_VERSION}-jdk \\"
            echo "    && apt-get clean \\"
            echo "    && rm -rf /var/lib/apt/lists/*"
        else # alpine
            echo "RUN apk add --no-cache \\"
            echo "    openjdk${JAVA_VERSION}"
        fi
        echo "ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk"
        echo "ENV PATH=\$PATH:\$JAVA_HOME/bin"
        echo ""
    fi
    
    # Set the default command
    if [[ "$BASE_OS" == "ubuntu" ]]; then
        echo "# Set default command"
        echo "CMD [\"/bin/bash\"]"
    else # alpine
        echo "# Set default command"
        echo "CMD [\"/bin/ash\"]"
    fi
}

# Generate the Dockerfile and write to the output file
generate_dockerfile > "$OUTPUT_FILE"

echo "Dockerfile successfully generated at: $OUTPUT_FILE"
echo "Base OS: ${BASE_OS}"

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
