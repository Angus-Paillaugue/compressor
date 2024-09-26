#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
currentOutputFile=""

# Check if ffmpeg is installed
if [ ! -x "$(command -v ffmpeg)" ]; then
  throwError "ffmpeg is not installed. Please install ffmpeg to continue."
  exit 1
fi

# Function to handle errors
function errorHandling() {
  # $1: line number
  # $2: error message
  echo -e "${RED}Error on line $1: $2${NC}"
  exit 1
}

# Function to throw error and exit
function throwError() {
  # $1: error message
  echo -e " ${RED}✖${NC} $1"
  local exitCode=${2:true}
  if [ "$exitCode" = true ]; then
    exit 1
  fi
}

# Function to cleanup incomplete files
function handleCtrlC() {
  echo ""
  throwError "Caught <Ctrl>+C, cleaning up..." false
  if [[ -n "$currentOutputFile" && -f "$currentOutputFile" ]]; then
    local fileName="$(basename -- "$currentOutputFile")"
    echo -e "Removing incomplete file: $fileName"
    rm -f "$currentOutputFile"
  fi
  exit 1
}

# Function to display help
function displayHelp() {
  echo "Usage: compress-copy.sh -i <inputPath> [options]"
  echo ""
  echo "Options:"
  echo "  -i, --inputPath <inputPath>   Specify the input path."
  echo "  -r, --recursive               Recursively compress all the videos in the input path."
  echo "  -preset <presetValue>         Specify the preset value (default: fast)."
  echo "                                Valid presets: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo."
  echo "  -crf <value>                  Specify the CRF value (default: 23)."
  echo "                                Valid range: 0-51."
  echo "  -h, --help                    Display this help message and exit."
  echo "  --rename <inputPath>      Rename the processed files to remove the trailing \"-p\" in their name."
}

# Function to display spinner
function spinner() {
  # $1: text to display
  # $2: variable name for the spinner
  local text="$1"
  local UNI_DOTS="⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏"
  local UNI_DOTS2="⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷"
  local UNI_DOTS3="⣷ ⣯ ⣟ ⡿ ⢿ ⣻ ⣽ ⣾"
  local UNI_DOTS4="⠋ ⠙ ⠚ ⠞ ⠖ ⠦ ⠴ ⠲ ⠳ ⠓"
  local UNI_DOTS5="⠄ ⠆ ⠇ ⠋ ⠙ ⠸ ⠰ ⠠ ⠰ ⠸ ⠙ ⠋ ⠇ ⠆"
  local UNI_DOTS6="⠋ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋"
  local UNI_DOTS7="⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠴ ⠲ ⠒ ⠂ ⠂ ⠒ ⠚ ⠙ ⠉ ⠁"
  local UNI_DOTS8="⠈ ⠉ ⠋ ⠓ ⠒ ⠐ ⠐ ⠒ ⠖ ⠦ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈"
  local UNI_DOTS9="⠁ ⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈ ⠈"

  local SYMBOLS="${!2:-$UNI_DOTS3}"
  while true; do
    for c in $SYMBOLS; do
      echo -ne " $c $text"\\r
      sleep 0.1
    done
  done
}

# Checks if file has already been processed
function isProcessed() {
  # $1: file path
  local file="$1"
  local fileName=$(basename -- "$file")
  local fileNameWithoutExtension="${fileName%.*}"
  [[ $fileNameWithoutExtension == *"-p" ]]
}

# Function to compress the video
function compress() {
  local file="$1"
  local filePath="$(dirname -- "$file")"
  local fileName="$(basename -- "$file")"
  local fileNameWithoutExtension="${fileName%.*}"
  local extension="${fileName##*.}"
  local outputName="$filePath/$fileNameWithoutExtension-p.$extension"
  currentOutputFile="$outputName"
  # Check if the file is already processed
  if isProcessed "$file"; then
    return
  fi

  # Compress the video
  ffmpeg -i "$file" -vcodec libx265 -movflags use_metadata_tags -map_metadata 0 -crf $crf -preset "$preset" "$outputName" > /dev/null 2>&1 &
  videoPid=$!

  # Displays the spinner and waits for the videoPid to finish
  spinner "Compressing $fileName (${RED}$baseSize${NC})" &
  spinnerPid=$!
  wait $videoPid
  kill $spinnerPid
  rm "$1" # Remove the original file
}

# Function to print the time taken to compress the video(s)
function printTimeTaken() {
  echo -ne "\n 👍 All done in "
  T=$1
  D=$((T/60/60/24))
  H=$((T/60/60%24))
  M=$((T/60%60))
  S=$((T%60))
  (( D > 0 )) && echo -n "$D days "
  (( H > 0 )) && echo -n "$H hours "
  (( M > 0 )) && echo -n "$M minutes "
  (( D > 0 || H > 0 || M > 0 )) && echo -n "and "
  echo "$S seconds"
}

# Function to rename the processed files
function renameFiles() {
  if [ -z "$1" ]; then
    throwError "File path is required to rename the file(s)"
    exit 1
  fi
  if [ -d "$1" ]; then
    # Create a find command to find all the video files having an extension in validFormats
    findCommand="find \"$1\" -maxdepth 1 -type f -name "*-p.*" -print0"

    # Execute the find command and read the files into an array
    files=() # Create an empty array to store the files
    while IFS= read -r -d $'\0' file; do
      files+=("$file")
    done < <(eval "$findCommand")

    if [ ${#files[@]} -eq 0 ]; then
      throwError "No files to rename found in $1"
      exit 1
    fi

    # Loop through files in inputPath
    for file in "${files[@]}"; do
      # Check if file is a regular file
      if [ -f "$file" ]; then
        renameFile "$file"
      fi
    done

    echo -e " ${GREEN}✓${NC} Renamed ${#files[@]} files successfully"
  else
    renameFile "$1"
    echo -e " ${GREEN}✓${NC} File renamed successfully"
  fi
}
function renameFile() {
  local file="$1"
  local fileName=$(basename -- "$file")
  local fileNameWithoutExtension="${fileName%.*}"
  local extension="${fileName##*.}"
  local newFileName="${fileNameWithoutExtension%-p}.$extension"
  mv "$file" "$(dirname -- "$file")/$newFileName"
}

# Trap SIGINT (Ctrl+C) and call handleCtrlC function
trap handleCtrlC SIGINT
# Use trap to catch ERR and call the errorHandling function
trap 'errorHandling $LINENO $BASH_COMMAND' ERR SIGTERM

# Flags
preset="fast" # Default value for the preset
valid_presets=("ultrafast" "superfast" "veryfast" "faster" "fast" "medium" "slow" "slower" "veryslow" "placebo")
crf=23 # Default value for the crf to 23 (best I found for my use case)
inputPath=""
validFormats=("mp4" "mov" "avi" "mkv") # Valid video formats
recursive=false

# Parse the arguments
while [ "$1" != "" ]; do
  case $1 in
    -h | --help )
      displayHelp
      exit 0
      ;;
    --rename )
      shift
      renameFiles "$1"
      exit 0
      ;;
    -r | --recursive )
      recursive=true
      ;;
    -i | --inputPath )
      shift
      inputPath="$1"
      ;;
    -preset )
      shift
      preset="$1"
      ;;
    -crf )
      shift
      crf="$1"
      ;;
    *)
      echo -e "${RED}Unknown option${NC}: $1"
      displayHelp
      exit 1
  esac
  shift
done
# Validate inputPath
if [ -z "$inputPath" ]; then
  throwError "Input path is required."
  displayHelp
  exit 1
fi
# Validate preset
if [[ ! " ${valid_presets[@]} " =~ " ${preset} " ]]; then
  throwError "Invalid preset value '$preset'. Valid options are: ${valid_presets[*]}"
  exit 1
fi
# Validate crf
if [[ ! $crf =~ ^[0-9]+$ ]] || [ $crf -lt 0 ] || [ $crf -gt 51 ]; then
  throwError "Invalid crf value '$crf'. crf value should be an integer between 0 and 51"
  exit 1
fi
# Input path validation
if [[ ! -d "$inputPath" && ! -f "$inputPath" ]]; then
  throwError "$inputPath is not a valid directory or file"
  exit 1
fi

# Start the timer
start=$(date +%s)

# If inputPath is a file
if [ -f "$inputPath" ]; then
  file="$inputPath"
  filePath="$(dirname -- "$file")"
  fileName="$(basename -- "$file")"
  filePath="$(dirname -- "$file")"
  fileName="$(basename -- "$file")"
  fileNameWithoutExtension="${fileName%.*}"
  extension="${fileName##*.}"
  outputName="$filePath/$fileNameWithoutExtension-p.$extension"

  # Check if the file is already processed
  if isProcessed "$file"; then
    echo -e " ${GREEN}✓${NC} ${fileName} is already processed"
  else
    # Get the original file size
    baseSize=$(du -h "$file" | cut -f1)

    # Actual compression
    compress "$file"

    # Get the new file size
    newSize=$(du -h "$outputName" | cut -f1)

    echo -e " ${GREEN}✓${NC} ${fileName} : ${RED}${baseSize}${NC} → ${GREEN}${newSize}${NC}"

    # Print the time taken
    printTimeTaken $(($(date +%s) - $start))
  fi
else
  maxdepth="-maxdepth 1"
  if [ "$recursive" = true ]; then
    maxdepth=""
  fi
  # Create a find command to find all the video files having an extension in validFormats
  findCommand="find \"$inputPath\" $maxdepth -type f -not -name \"*-p.*\" \( "
  for format in "${validFormats[@]}"; do
    findCommand+=" -iname \"*.$format\" -o"
  done
  # Remove the trailing " -o"
  findCommand="${findCommand% -o}"
  findCommand+=" \) -print0"

  # Execute the find command and read the files into an array
  files=() # Create an empty array to store the files
  while IFS= read -r -d $'\0' file; do
    files+=("$file")
  done < <(eval "$findCommand")

  numberOfFiles=${#files[@]}

  # If no files found in $inputPath, exit
  if [ $numberOfFiles -eq 0 ]; then
    throwError "No videos to compress found in $inputPath"
    exit 1
  fi

  # Display the number of files found
  echo -e " ${GREEN}✓${NC} Found $numberOfFiles videos to compress"

  # Get the original directory size
  originalDirSize=$(du -s "$inputPath" | cut -f1)
  originalDirSizeHR=$(du -s -h "$inputPath" | cut -f1)

  filesToGo=$numberOfFiles

  # Loop through files in inputPath
  for file in "${files[@]}"; do
    # Check if file is a regular file
    if [ -f "$file" ]; then
      # Extracting file information
      filesToGo=$((filesToGo-1))
      filePath="$(dirname -- "$file")"
      fileName="$(basename -- "$file")"
      fileNameWithoutExtension="${fileName%.*}"
      extension="${fileName##*.}"
      outputName="$filePath/$fileNameWithoutExtension-p.$extension"

      # Check if the file is already processed
      if isProcessed "$file"; then
        echo -e " ${YELLOW}󰒬${NC} Skipping already processed file: $fileName (${YELLOW}${filesToGo}${NC} to go)"
        continue
      fi

      # Get the original file size
      baseSize=$(du -h "$file" | cut -f1)

      # Actual compression
      compress "$file"

      # Get the new file size
      newSize=$(du -h "$outputName" | cut -f1)

      echo -e " ${GREEN}✓${NC} ${fileName} : ${RED}${baseSize}${NC} → ${GREEN}${newSize}${NC} (${YELLOW}${filesToGo}${NC} to go)"
    fi
  done

  # Print the time taken
  printTimeTaken $(($(date +%s) - $start))
  finalDirSize=$(du -s "$inputPath" | cut -f1)
  finalDirSizeHr=$(du -h -s "$inputPath" | cut -f1)
  compressionRate=$(echo "scale=1; ($originalDirSize - $finalDirSize) / $originalDirSize * 100" | bc)
  echo -e " ${GREEN}✓${NC} Reduced the directory size by ${YELLOW}$compressionRate${NC}% : ${RED}$originalDirSizeHR${NC} → ${GREEN}$finalDirSizeHr${NC}"

  exit 0
fi
