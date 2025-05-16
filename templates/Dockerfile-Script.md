## Here's how to use the Dockerfile creation script:

### Using the Shell Script

1. First, make the script executable:

```bash
chmod +x /Users/gsaravanan/Documents/github/gemini_demos/create-dockerfile.sh
```

2. Then you can run the script with various options to generate a Dockerfile with your desired configuration:

```bash
./create-dockerfile.sh [options]
```

### Using the Python Script

1. First, make the Python script executable:

```bash
chmod +x /Users/gsaravanan/Documents/github/gemini_demos/create-dockerfile.py
```

2. Then you can run the Python script with the same options:

```bash
./create-dockerfile.py [options]
```

## Script Features

The script provides the following options:

- `-h, --help`: Show help message
- `-o, --output FILE`: Specify the output Dockerfile name (default: `Dockerfile`)
- `--os OS`: Choose base OS (`ubuntu` or `alpine`, default: `ubuntu`)
- `--golang`: Include Golang
- `--rust`: Include Rust
- `--python`: Include Python
- `--nodejs`: Include Node.js
- `--java`: Include Java
- `--go-version VERSION`: Specify Golang version (default: 1.22.2)
- `--node-version VERSION`: Specify Node.js major version (default: 20)
- `--java-version VERSION`: Specify Java version (default: 17)
- `--template PATH`: Path to the template file (default: ./templates/Dockerfile-Template)

## Examples

Here are some examples of how to use the script:

1. Create a Dockerfile for a Node.js application using Alpine Linux:

```bash
./create-dockerfile.sh --os alpine --nodejs --node-version 18 -o Dockerfile.node
```

2. Create a Dockerfile for a Java application:

```bash
./create-dockerfile.sh --java --java-version 17 -o Dockerfile.java
```

3. Create a Dockerfile for a full-stack development environment:

```bash
./create-dockerfile.sh --golang --nodejs --python --java -o Dockerfile.fullstack
```

The script will automatically:
- Set the correct base OS image
- Enable/disable languages as specified
- Configure the correct versions
- Adjust OS-specific installations
- Update the shell command (bash for Ubuntu, ash for Alpine)

After running the script, you'll get a generated Dockerfile that's ready to use without any manual editing required.

Would you like me to add any additional features to the script or would you like me to explain any part of it in more detail?