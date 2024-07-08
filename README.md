
<br/>
<div align="center">
  <img src="https://cdn-icons-png.flaticon.com/512/1387/1387554.png" alt="Logo" width="80" height="80">
  <h1 align="center">Automatic Compressor</h1>
</div>


## Introduction
These simple scripts are used to easley compress videos and images.
<div align="center">
  <video src="./ressources/exemple.mp4" width="676" height="532" controls></video>
</div>

## Getting Started
### Prerequisites
You ned to have Ffmpeg installed on your system (Follow the installation guides [here](https://www.ffmpeg.org/download.html))

### Installation
To install this tool globally, just tun the install script (`./install.sh`). You can now run the script via the `compressor` command!

## Video compression
To compress videos, use the `video-compressor` command and pass the directory with your videos an an input using the `-i` flag (ex : `video-compressor -i /path/to/your/videos`)
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

## Image compression
To compress videos, use the `image-compressor` command and pass the directory with your videos an an input using the `-i` flag (ex : `image-compressor -i /path/to/your/images`)
```sh
Usage: <script> -i <inputPath> [options]

Options:
  -i, --inputPath <inputPath>   Specify the input path.
  -q, --quality <percentage>    Specify the quality percentage (default: 50%)
  -r, --rename <inputPath>      Rename the processed files to remove the trailing "-p" in their name.
```
