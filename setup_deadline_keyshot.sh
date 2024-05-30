#!/bin/bash

# Enable debug mode
set -x

# Log file for debugging
LOG_FILE=~/Documents/setup_deadline_keyshot_debug.log
exec > >(tee -i $LOG_FILE)
exec 2>&1

# Ensure pip3 is installed
if ! command -v pip3 &> /dev/null; then
    echo "pip3 is not installed. Installing pip3..."
    
    # Try installing pip3 using easy_install
    if command -v easy_install &> /dev/null; then
        sudo easy_install pip3
    else
        # If easy_install is not available, try with the system's default Python interpreter
        sudo python3 -m ensurepip --upgrade
    fi
    
    # Check if pip3 is successfully installed
    if ! command -v pip3 &> /dev/null; then
        echo "Error: pip3 installation failed!"
        exit 1
    fi
fi

# Script URL
SCRIPT_URL="https://raw.githubusercontent.com/aws-deadline/deadline-cloud-for-keyshot/mainline/keyshot_script/Submit%20to%20AWS%20Deadline%20Cloud.py"
LOCAL_SCRIPT_PATH="/tmp/Submit_to_AWS_Deadline_Cloud.py"

# Detect KeyShot version
echo "Detecting KeyShot version..."
KEYSHOT_VERSION=$(ls -d "/Library/Application Support/KeyShot"*/ 2>/dev/null | grep -o 'KeyShot[0-9]*' | head -n 1)
if [ -z "$KEYSHOT_VERSION" ]; then
    echo "Error: KeyShot version not found!"
    exit 1
fi
echo "KeyShot version detected: $KEYSHOT_VERSION"
KEYSHOT_SCRIPTS_DIR="/Library/Application Support/$KEYSHOT_VERSION/Scripts/"

# Check if pip3 is installed
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is not installed. Please install it before running this script."
    exit 1
fi

# Install necessary packages
echo "Installing deadline-cloud-for-keyshot, deadline[gui], and PySide6 packages..."
if ! pip3 install deadline-cloud-for-keyshot 'deadline[gui]' PySide6; then
    echo "Error: Package installation failed!"
    exit 1
fi

# Check if the script URL is valid
echo "Checking if the script URL is correct..."
if ! curl --output /dev/null --silent --head --fail "$SCRIPT_URL"; then
    echo "Error: The script URL is incorrect or the file does not exist."
    exit 1
fi

# Download the script
echo "Downloading the script..."
if ! curl -o "$LOCAL_SCRIPT_PATH" "$SCRIPT_URL"; then
    echo "Error: Downloading the script failed!"
    exit 1
fi

# Check if KeyShot Scripts folder exists
if [ ! -d "$KEYSHOT_SCRIPTS_DIR" ]; then
    echo "Creating KeyShot Scripts folder..."
    if ! sudo mkdir -p "$KEYSHOT_SCRIPTS_DIR"; then
        echo "Error: Folder creation failed!"
        exit 1
    fi
fi

# Move the script to the KeyShot Scripts folder
echo "Moving script to KeyShot Scripts folder..."
if ! sudo mv "$LOCAL_SCRIPT_PATH" "$KEYSHOT_SCRIPTS_DIR"; then
    echo "Error: Moving script failed!"
    exit 1
fi

# Find Python executable path
echo "Finding Python executable path..."
PYTHON_PATH=$(which python3)
if [ -z "$PYTHON_PATH" ]; then
    echo "Error: Python executable not found!"
    exit 1
fi
echo "Python executable path: $PYTHON_PATH"

# Set the DEADLINE_PYTHON environment variable
echo "Setting DEADLINE_PYTHON environment variable..."
export DEADLINE_PYTHON="$PYTHON_PATH"
if grep -q "export DEADLINE_PYTHON=" ~/.zshrc; then
    sed -i '' '/export DEADLINE_PYTHON=/d' ~/.zshrc
fi
echo "export DEADLINE_PYTHON=\"$PYTHON_PATH\"" >> ~/.zshrc

if grep -q "export DEADLINE_PYTHON=" ~/.bash_profile; then
    sed -i '' '/export DEADLINE_PYTHON=/d' ~/.bash_profile
fi
echo "export DEADLINE_PYTHON=\"$PYTHON_PATH\"" >> ~/.bash_profile

# Find path to the deadline keyshot submitter directory
echo "Finding path to deadline keyshot submitter folder..."
DEADLINE_KEYSHOT_PATH=$(python3 -c "import site; import os; paths = site.getsitepackages(); result = [os.path.join(path, 'deadline/keyshot_submitter') for path in paths if os.path.isdir(os.path.join(path, 'deadline/keyshot_submitter'))]; print(result[0] if result else '')")
if [ -z "$DEADLINE_KEYSHOT_PATH" ]; then
    echo "Error: Could not find deadline keyshot submitter folder!"
    exit 1
fi
echo "DEADLINE_KEYSHOT path: $DEADLINE_KEYSHOT_PATH"

# Set the DEADLINE_KEYSHOT environment variable
echo "Setting DEADLINE_KEYSHOT environment variable..."
export DEADLINE_KEYSHOT="$DEADLINE_KEYSHOT_PATH"
if grep -q "export DEADLINE_KEYSHOT=" ~/.zshrc; then
    sed -i '' '/export DEADLINE_KEYSHOT=/d' ~/.zshrc
fi
echo "export DEADLINE_KEYSHOT=\"$DEADLINE_KEYSHOT_PATH\"" >> ~/.zshrc

if grep -q "export DEADLINE_KEYSHOT=" ~/.bash_profile; then
    sed -i '' '/export DEADLINE_KEYSHOT=/d' ~/.bash_profile
fi
echo "export DEADLINE_KEYSHOT=\"$DEADLINE_KEYSHOT_PATH\"" >> ~/.bash_profile

# Verify environment variables
echo "Verifying environment variables..."
if [ -z "$DEADLINE_PYTHON" ] || [ -z "$DEADLINE_KEYSHOT" ]; then
    echo "Error: Environment variables not set correctly!"
    exit 1
fi

# Source the configuration file to apply changes
echo "Sourcing shell configuration file to apply changes..."
source ~/.zshrc

# Launch KeyShot
echo "Launching KeyShot..."

# Use the detected KeyShot version
KEYSHOT_APP="/Applications/$KEYSHOT_VERSION.app"

if [ ! -d "$KEYSHOT_APP" ]; then
    echo "Error: KeyShot application not found at $KEYSHOT_APP!"
    exit 1
fi

echo "KeyShot application found at: $KEYSHOT_APP"
open "$KEYSHOT_APP"

echo "Installation complete. Please restart KeyShot to use the AWS Deadline Cloud submission script."

# Disable debug mode
set +x
