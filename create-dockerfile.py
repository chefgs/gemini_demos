#!/usr/bin/env python3
"""
Dockerfile Generator Script

This script generates a customized Dockerfile from a template.
It allows you to choose the base OS and which programming languages to include.
"""

import os
import sys
import argparse
import shutil


def display_help_message():
    """Display a helpful message with examples when no arguments are provided"""
    print("\n📦 Dockerfile Generator 📦")
    print("=========================")
    print("This tool helps you create customized Dockerfiles for your projects.")
    print("\nExamples:")
    print("  1. Create a Ubuntu-based Dockerfile with Python:")
    print("     python3 create-dockerfile.py --base ubuntu --python")
    print("\n  2. Create an Alpine-based Dockerfile with Go and Node.js:")
    print("     python3 create-dockerfile.py --base alpine --golang --nodejs")
    print("\n  3. Create a Dockerfile with all languages:")
    print("     python3 create-dockerfile.py --all")
    print("\n  4. Specify custom versions and output file:")
    print("     python3 create-dockerfile.py --golang --go-version 1.21.0 --nodejs --node-version 18 --output MyDockerfile")
    print("\nFor more options, run: python3 create-dockerfile.py --help")
    print("=========================\n")


def parse_arguments():
    parser = argparse.ArgumentParser(description='Generate a Dockerfile from template')
    
    # Base OS selection
    parser.add_argument('--base', choices=['ubuntu', 'alpine'], default='ubuntu',
                      help='Base OS for the Dockerfile (ubuntu or alpine)')
    
    # Programming languages options
    parser.add_argument('--golang', action='store_true', help='Include Golang')
    parser.add_argument('--go-version', default='1.22.2', help='Golang version to install')
    
    parser.add_argument('--rust', action='store_true', help='Include Rust')
    
    parser.add_argument('--python', action='store_true', help='Include Python')
    
    parser.add_argument('--nodejs', action='store_true', help='Include Node.js')
    parser.add_argument('--node-version', default='20', help='Node.js major version to install')
    
    parser.add_argument('--java', action='store_true', help='Include Java')
    parser.add_argument('--java-version', default='17', help='Java version to install')
    
    # Output options
    parser.add_argument('--output', default='Dockerfile', 
                      help='Output file path (default: Dockerfile in current directory)')
    
    # Template location
    parser.add_argument('--template', default='templates/Dockerfile-Template',
                      help='Path to the Dockerfile template')
    
    # Include all languages option
    parser.add_argument('--all', action='store_true', 
                      help='Include all programming languages')
    
    return parser.parse_args()


def generate_dockerfile(args):
    # Check if template exists
    if not os.path.exists(args.template):
        print(f"Error: Template file not found at {args.template}")
        sys.exit(1)
    
    # Read template content
    with open(args.template, 'r') as template_file:
        content = template_file.read()
    
    # Process base OS selection
    if args.base == 'ubuntu':
        # Uncomment Ubuntu, keep Alpine commented
        content = content.replace('#FROM ubuntu:22.04', 'FROM ubuntu:22.04')
        content = content.replace('# RUN apt-get update', 'RUN apt-get update')
    else:  # alpine
        # Uncomment Alpine, keep Ubuntu commented
        content = content.replace('FROM ubuntu:22.04', '# FROM ubuntu:22.04')
        content = content.replace('# FROM alpine:latest', 'FROM alpine:latest')
        # Uncomment Alpine specific commands and comment Ubuntu ones
        content = content.replace('# RUN apk update', 'RUN apk update')
        # Set the default shell to ash for Alpine
        content = content.replace('CMD ["/bin/bash"]', '# CMD ["/bin/bash"]')
        content = content.replace('# For Alpine, use "/bin/ash" instead of "/bin/bash"', 'CMD ["/bin/ash"]')
    
    # Handle language selections
    # If --all is specified, enable all languages
    if args.all:
        args.golang = args.rust = args.python = args.nodejs = args.java = True
    
    # Configure Go
    if args.golang:
        content = content.replace('ARG INSTALL_GOLANG=true', 'ARG INSTALL_GOLANG=true')
        content = content.replace('ARG GO_VERSION=1.22.2', f'ARG GO_VERSION={args.go_version}')
    else:
        content = content.replace('ARG INSTALL_GOLANG=true', 'ARG INSTALL_GOLANG=false')
    
    # Configure Rust
    if args.rust:
        content = content.replace('ARG INSTALL_RUST=true', 'ARG INSTALL_RUST=true')
    else:
        content = content.replace('ARG INSTALL_RUST=true', 'ARG INSTALL_RUST=false')
    
    # Configure Python
    if args.python:
        content = content.replace('ARG INSTALL_PYTHON=true', 'ARG INSTALL_PYTHON=true')
    else:
        content = content.replace('ARG INSTALL_PYTHON=true', 'ARG INSTALL_PYTHON=false')
    
    # Configure Node.js
    if args.nodejs:
        content = content.replace('ARG INSTALL_NODEJS=true', 'ARG INSTALL_NODEJS=true')
        content = content.replace('ARG NODE_MAJOR=20', f'ARG NODE_MAJOR={args.node_version}')
    else:
        content = content.replace('ARG INSTALL_NODEJS=true', 'ARG INSTALL_NODEJS=false')
    
    # Configure Java
    if args.java:
        content = content.replace('ARG INSTALL_JAVA=true', 'ARG INSTALL_JAVA=true')
        content = content.replace('ARG JAVA_VERSION=17', f'ARG JAVA_VERSION={args.java_version}')
    else:
        content = content.replace('ARG INSTALL_JAVA=true', 'ARG INSTALL_JAVA=false')
    
    # Write the customized Dockerfile
    with open(args.output, 'w') as output_file:
        output_file.write(content)
    
    print(f"Dockerfile successfully generated at: {args.output}")
    print(f"Base OS: {args.base.capitalize()}")
    
    # Print what languages were included
    languages = []
    if args.golang: languages.append(f"Go {args.go_version}")
    if args.rust: languages.append("Rust")
    if args.python: languages.append("Python")
    if args.nodejs: languages.append(f"Node.js {args.node_version}")
    if args.java: languages.append(f"Java {args.java_version}")
    
    if languages:
        print(f"Included languages: {', '.join(languages)}")
    else:
        print("No programming languages were enabled")
    
    # Display next steps helper message
    print("\n📋 Next Steps:")
    print("1. Review your Dockerfile: cat", args.output)
    print("2. Build your Docker image: docker build -t my-image -f", args.output, ".")
    print("3. Run your Docker container: docker run -it --rm my-image")


def main():
    args = parse_arguments()
    
    # If no language flags are set and not using --all or --help, show help message
    if not any([args.golang, args.rust, args.python, args.nodejs, args.java, args.all]) and len(sys.argv) <= 2:
        display_help_message()
        sys.exit(0)
        
    generate_dockerfile(args)


if __name__ == "__main__":
    main()
