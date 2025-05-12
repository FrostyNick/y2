# y2

[![Bash](https://img.shields.io/badge/Bash-3E7720?logo=gnubash&logoColor=FFF)](#)
[![Code Size](https://custom-icon-badges.demolab.com/github/languages/code-size/FrostyNick/y2?logo=file-code&logoColor=white)](#)
[![License](https://custom-icon-badges.herokuapp.com/github/license/FrostyNick/y2?logo=law&color=EA3423&labelColor=191724)](LICENSE)

Automate `yt-dlp` downloading, storing, checking for duplicates and watching videos using `mpv`, `vlc`, or an alternative with concise commands.

## Table of Contents

- [Dependencies](#dependencies)
- [Installation](#installation)
- [Usage](#usage)
  - [Examples](#examples)
  - [Options](#options)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

You will need the following dependencies installed on your system:

- `bash`
- `coreutils` - If you don't know what this means, you probably have it.
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) (default) or [`youtube-dl`](https://github.com/youtube-dl/youtube-dl) (for downloading videos)
- [`mpv`](https://mpv.io/) (default), `cvlc`, [`vlc`](https://www.videolan.org/vlc/) or alternative for viewing videos (for viewing videos)
- [`fzf`](https://github.com/junegunn/fzf) (to be optional in the future; for interactive selection)

## Installation

1. Clone the repository:
  ```sh
  cd ~/projects
  git clone https://github.com/FrostyNick/y2.git
  ```

> [!NOTE]
> `ln` needs to be used again (as shown later) if `y2` is moved. Pick a place you don't plan to move it out of right away.

2. Make the script executable:
  ```sh
  chmod +x ./y2/y2.sh
  ```

3. Add it to path so it can be run anywhere. To see where your path(s) are: echo $PATH
  
  ```sh
  # Check that /usr/local/bin is in $PATH otherwise below will not work.
  sudo ln -s $HOME/projects/y2.sh /usr/local/bin/y2
  # For example, if choosing ~/.local/bin instead if above is not found in $PATH:
  sudo ln -s $HOME/projects/y2.sh $HOME/.local/bin/y2
  ```

4. Check that it runs.

  `y2 --help`

## Usage

See `y2 --help` for the latest help.

```sh
y2 [options] <media_url>
```

### Examples

1. Download a video and save it in `filestore`.
  ```sh
  y2 https://youtu.be/pVI_smLgTY0
  ```

2. Download a video like above with recommended added options (might only work with `yt-dlp`):
  ```sh
  y2 0 https://youtu.be/pVI_smLgTY0
  ```

  The `0` above at the time of writing is replaced with:
  `-f bestvideo[height<=1080]+bestaudio/best[height<=1080] --embed-chapters --sponsorblock-mark all --embed-metadata --embed-thumbnail --add-metadata --embed-subs --sub-lang en`

3. Download a video with height no bigger than 500px (this is comparable to quality settings in YouTube video); adding some flags from `yt-dlp` as well:
  ```sh
  y2 500 --dateafter today-2weeks https://www.youtube.com/watch?v=xsDnEj2Hx4Q
  ```

4. Get video. This will work if it's in the filename.
  ```sh
  y2 -g pVI_smLgTY0
  ```

### Options

- `-h` or `--help` or empty: Get help.
- `-g`: Get downloaded video(s) using `grep` and `fzf`. Tested to work on YouTube videos.
- `0`: Apply extra flags to the filefetch (`yt-dlp`; might work with `youtube-dl`).
- `<int> != 0`: Set a maximum video height size.
- `--max <int>`: Same as above.

Every other flag that is not recognized will be passed to `filefetch`.

## Configuration

You can customize the following settings in the start of the script:

- `filefetch`: Set to `yt-dlp` (default) or `youtube-dl`.
- `fileview`: Set to `mpv` (default) or other media players.
- `filestore`: Default storage location for downloaded videos (`$HOME/y2`).
- `filecache`: Default cache location (`$HOME/.cache/y2`).

> [!WARNING]  
> This may be moved to `$HOME/.config` in the future.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the UNLICENSE License. See the [UNLICENSE](UNLICENSE) file for details.

