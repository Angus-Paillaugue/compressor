#!/bin/bash


GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

scriptName="video-compressor"

# Function to throw error and exit
function throwError() {
  # $1: error message
  echo -e "${RED}✖${NC} $1"
  local exitCode=${2:true}
  if [ "$exitCode" = true ]; then
    exit 1
  fi
}

# Function to handle errors
function errorHandling() {
  # $1: line number
  # Message, ...args
  local lineNum=$1
  shift 1
  local message="$*"
  echo -e "${RED}Error on line $lineNum:${NC}\n$message"
  exit 1
}

# Function to cleanup incomplete files
function handleCtrlC() {
  echo ""
  throwError "Caught <Ctrl>+C, exiting..." false
  exit 1
}

# Trap SIGINT (Ctrl+C) and call handleCtrlC function
trap handleCtrlC SIGINT
# Use trap to catch ERR and call the errorHandling function
trap 'errorHandling $LINENO $BASH_COMMAND' ERR SIGTERM

localDir=$(dirname "$0")

# Download the video-compressor script
curl -s https://raw.githubusercontent.com/Angus-Paillaugue/compressor/refs/heads/main/video-compressor.sh -o $localDir/$scriptName

# Copy the script
sudo cp ${localDir}/$scriptName /usr/local/bin/$scriptName

# Remove the downloaded script
rm ${localDir}/$scriptName

# Make the video-compressor script executable
sudo chmod +x /usr/local/bin/$scriptName


# Check if the video-compressor script has been installed successfully
if [ ! -f /usr/local/bin/${scriptName} ]; then
  throwError "The $scriptName script could not be installed."
fi


echo -e " ${GREEN}✓${NC} The $scriptName script have been installed successfully."
