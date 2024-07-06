
<br/>
<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/FFmpeg_icon.svg/1200px-FFmpeg_icon.svg.png" alt="Logo" width="80" height="80">
  <h1 align="center">Automatic Video Compressor</h1>
</div>

## Introduction
This simple bash script is used to compress large amount of videos in a directory.
<div align="center">
  <video src="./ressources/exemple.mp4" width="676" height="532" controls></video>
</div>

## Getting Started
### Prerequisites
You ned to have Ffmpeg installed on your system (Follow the installation guides [here](https://www.ffmpeg.org/download.html))

### Installation
To install this tool globally, just tun the install script (`./install.sh`). You can now run the script via the `compressor` command!

### Usage
To do so, just call the script and pass the directory with your videos an an input using the `-i` flag (ex : `compressor -i /path/to/your/videos`)

```sh
Usage: <script> -i <inputPath> [options]

Options:
  -i, --inputPath <inputPath>   Specify the input path.
  -preset <presetValue>         Specify the preset value (default: fast).
                                Valid presets: ultrafast, superfast, veryfast, faster, fast, medium,
                                slow, slower, veryslow, placebo.
  -crf <value>                  Specify the CRF value (default: 23).
                                Valid range: 0-51.
  -h, --help                    Display this help message and exit.
  -r, --rename <inputPath>      Rename the processed files to remove the trailing "-p" in their name.
```
