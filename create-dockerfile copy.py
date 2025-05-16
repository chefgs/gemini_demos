#!/usr/bin/env python3
"""
Script to generate a Dockerfile from a template.
This script automates the creation of customized Dockerfiles for different programming languages.
"""

import argparse
import os
import re
import sys


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate a Dockerfile from the template.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        "-o", "--output", 
        default="Dockerfile", 
        help="Output Dockerfile name (default: Dockerfile)"
    )
    parser.add_argument(
        "--os", 
        choices=["ubuntu", "alpine"], 
        default="ubuntu", 
        help="Base OS: ubuntu or alpine (default: ubuntu)"
    )
    parser.add_argument(
        "--golang", 
        action="store_true", 
        help="Include Golang"
    )
    parser.add_argument(
        "--rust", 
        action="store_true", 
        help="Include Rust"
    )
    parser.add_argument(
        "--python", 
        action="store_true", 
        help="Include Python"
    )
    parser.add_argument(
        "--nodejs", 
        action="store_true", 
        help="Include Node.js"
    )
    parser.add_argument(
        "--java", 
        action="store_true", 
        help="Include Java"
    )
    parser.add_argument(
        "--go-version", 
        default="1.22.2", 
        help="Golang version (default: 1.22.2)"
    )
    parser.add_argument(
        "--node-version", 
        default="20", 
        help="Node.js major version (default: 20)"
    )
    parser.add_argument(
        "--java-version", 
        default="17", 
        help="Java version (default: 17)"
    )
    parser.add_argument(
        "--template", 
        default="./templates/Dockerfile-Template", 
        help="Path to template file (default: ./templates/Dockerfile-Template)"
    )
    
    return parser.parse_args()


def read_template(template_path):
    """Read the Dockerfile template."""
    try:
        with open(template_path, 'r') as file:
            return file.read()
    except FileNotFoundError:
        print(f"Error: Template file not found at {template_path}")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading template: {e}")
        sys.exit(1)


def write_dockerfile(content, output_file):
    """Write content to the output Dockerfile."""
    try:
        with open(output_file, 'w') as file:
            file.write(content)
    except Exception as e:
        print(f"Error writing to {output_file}: {e}")
        sys.exit(1)


def configure_base_os(content, base_os):
    """Configure the base OS in the Dockerfile."""
    if base_os == "alpine":
        # Comment out Ubuntu section
        content = re.sub(r'^FROM ubuntu.*?^$', lambda m: '\n'.join('# ' + line for line in m.group(0).split('\n')), 
                        content, flags=re.MULTILINE | re.DOTALL)
        
        # Uncomment Alpine section
        content = re.sub(r'^# (FROM alpine.*?)$', r'\1', content, flags=re.MULTILINE)
        content = re.sub(r'^# (RUN apk update.*?)$', r'\1', content, flags=re.MULTILINE | re.DOTALL)
        
        # Change default CMD to ash
        content = re.sub(r'CMD \["\/bin\/bash"\]', r'CMD ["/bin/ash"]', content)
    
    return content


def configure_language(content, lang, install, version_arg=None, version_value=None):
    """Configure a programming language in the Dockerfile."""
    # Set language installation flag
    install_value = "true" if install else "false"
    content = re.sub(rf'ARG INSTALL_{lang}=true', f'ARG INSTALL_{lang}={install_value}', content)
    
    # Set version if provided
    if version_arg and version_value:
        content = re.sub(rf'ARG {version_arg}=.*', f'ARG {version_arg}={version_value}', content)
    
    # For Alpine, uncomment specific language sections
    if install:
        # This pattern matches commented-out language-specific RUN blocks for Alpine
        pattern = r'^# (RUN if \[ "\$INSTALL_{lang}" = "true" \]; then \\.*?^#     fi)$'
        pattern = pattern.replace('{lang}', lang)
        content = re.sub(pattern, lambda m: m.group(1), content, flags=re.MULTILINE | re.DOTALL)
    
    return content


def main():
    """Main function."""
    args = parse_arguments()
    
    # Read template
    content = read_template(args.template)
    
    # Configure base OS
    content = configure_base_os(content, args.os)
    
    # Configure languages
    content = configure_language(content, "GOLANG", args.golang, "GO_VERSION", args.go_version)
    content = configure_language(content, "RUST", args.rust)
    content = configure_language(content, "PYTHON", args.python)
    content = configure_language(content, "NODEJS", args.nodejs, "NODE_MAJOR", args.node_version)
    content = configure_language(content, "JAVA", args.java, "JAVA_VERSION", args.java_version)
    
    # Write the Dockerfile
    write_dockerfile(content, args.output)
    
    # Display configuration summary
    print(f"Dockerfile generated at {args.output}")
    print("\nConfiguration:")
    print(f"  Base OS: {args.os}")
    print(f"  Golang: {str(args.golang).lower()} (version {args.go_version})")
    print(f"  Rust: {str(args.rust).lower()}")
    print(f"  Python: {str(args.python).lower()}")
    print(f"  Node.js: {str(args.nodejs).lower()} (version {args.node_version})")
    print(f"  Java: {str(args.java).lower()} (version {args.java_version})")


if __name__ == "__main__":
    main()
