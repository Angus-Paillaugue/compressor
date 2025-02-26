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
  # $2: error message
  echo -e "${RED}Error on line $1: $2${NC}"
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

# Install the script
sudo cp "$localDir/$scriptName.sh" /usr/local/bin/$scriptName
sudo chmod +x /usr/local/bin/$scriptName

echo -e " ${GREEN}✓${NC} The $scriptName script have been installed successfully."
