# AWS Deadline Cloud for KeyShot - macOS Setup Script

This repository contains a setup script to integrate AWS Deadline Cloud with KeyShot on macOS. The script ensures that all necessary packages are installed and the environment is configured correctly.

## Features

- Automatically detects the installed KeyShot version.
- Installs required Python packages: `deadline-cloud-for-keyshot`, `deadline[gui]`, and `PySide6`.
- Downloads the AWS Deadline Cloud submission script and places it in the appropriate KeyShot Scripts folder.
- Sets necessary environment variables for AWS Deadline Cloud integration.
- Launches KeyShot for immediate use after setup.

## Prerequisites

- macOS
- KeyShot installed
- Python 3 installed

## Installation
1. **Download setup_deadline_keyshot.sh**
2. **Make the setup script executable:**
```chmod +x setup_deadline_keyshot.sh```
3. **Run the setup script:**
```./setup_deadline_keyshot.sh```
4. **Follow any prompts during the installation process.**

# Troubleshooting
If you encounter any issues during the setup process, refer to the log file located at ~/Documents/setup_deadline_keyshot_debug.log for detailed information.

# Acknowledgements
This script is based on the [AWS Deadline Cloud for KeyShot] (https://github.com/aws-deadline/deadline-cloud-for-keyshot) project.

