<br/>
<div align="center">
  <img src="https://cdn-icons-png.flaticon.com/512/1387/1387554.png" alt="Logo" width="80" height="80">
  <h1 align="center">Automatic Compressor</h1>
</div>

# Introduction

These simple scripts are used to easily compress videos and images.

<!-- <div align="center">
  <video src="./ressources/exemple.mp4" width="676" height="532" controls></video>
</div> -->

# Getting Started

### Prerequisites

You need to have ffmpeg installed on your system (Follow the installation guides [here](https://www.ffmpeg.org/download.html))

### Installation

To install this tool, just run the following command :
```bash
curl -sSL https://raw.githubusercontent.com/Angus-Paillaugue/compressor/refs/heads/main/install.sh | bash
```

# Usage

To compress videos, use the `video-compressor` command and pass the directory with your videos as an input using the `-i` flag (ex : `video-compressor -i /path/to/your/videos`)

```sh
Usage: video-compressor -i <inputPath> [options]

Options:
  -i, --inputPath <inputPath>   Specify the input path.
  -r, --recursive               Recursively compress all the videos in the input path.
  -preset <presetValue>         Specify the preset value (default: fast).
                                Valid presets: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo.
  -crf <value>                  Specify the CRF value (default: 23).
                                Valid range: 0-51.
  -h, --help                    Display this help message and exit.
  --rename <inputPath>          Rename the processed files to remove the trailing "-p" in their name.
```
