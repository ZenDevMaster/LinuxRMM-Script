#!/bin/bash
# Upgrade TacticalRMM to latest version for Linux
# 2024-05-25 johnra

# Function to download and set the execute permission for the script
download_script() {
    
    SCRIPT_URL="https://raw.githubusercontent.com/ZenDevMaster/LinuxRMM-Script/main/rmmagent-linux.sh"
    SCRIPT_NAME="/tmp/rmmagent-linux.sh"
    
    # Download the script to /tmp
    if ! wget -O "$SCRIPT_NAME" "$SCRIPT_URL"; then
        echo "Error: Failed to download $SCRIPT_NAME"
        exit 1
    fi
    
    # Set execute permission on the downloaded script
    if ! chmod +x "$SCRIPT_NAME"; then
        echo "Error: Failed to set execute permission on $SCRIPT_NAME"
        exit 1
    fi
    
    echo "$SCRIPT_NAME downloaded and execute permission set successfully."
}

verify_service() {

    # Check if the service is running
    if ! systemctl is-active --quiet tacticalagent; then
        echo "Error: tacticalagent service is not running."
        exit 1
    fi
    
    echo "tacticalagent service is running successfully."
    exit 0
}

echo "Starting the TacticalRMM upgrade script"

# Define the file to be renamed
file_path="/tmp/rmmagent-linux.sh"
backup_path="$file_path.old"

# Check if the file exists
if [ -f "$file_path" ]; then
    # File exists, proceed to rename
    mv "$file_path" "$backup_path"
    echo "File has been renamed to $backup_path."
fi


download_script

# Determine the system architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64|i386|i686)
        ARCH="x86"
        ;;
    amd64)
        ARCH="amd64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        ;;
    arm*)
        ARCH="armv6"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Execute the script with the detected architecture
cd /tmp
./rmmagent-linux.sh update $ARCH

rm /tmp/rmmagent-linux.sh
verify_service
exit 0
