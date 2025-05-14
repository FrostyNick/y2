#!/usr/bin/env bash

## settings

filefetch="yt-dlp"
fileview="mpv"

# WARNING: If you update below values, you will need to copy files to the new location for all the videos to be in the same place.
filestore="$HOME/y2"
filecache="$HOME/.cache/y2"

## end of settings

if [ "$1" = "--cwd" ]; then
  echy "WARNING: --cwd is experimental and not stable. Enter to continue."
  read; filestore="$(pwd)"
  shift
else
  [ -d "$filestore" ] || mkdir -p "$filestore"
fi

[ -d "$filecache" ] || mkdir -p "$filecache"
cd "$filecache"

args=("")
basename=""
msg=""

echy() {
  echo "[y2]: $@"
}

exyt() {
  echy "Exiting due to error."
  # "return" after this fn is needed
}

view() {
  echy "running: $fileview \"$basename\" from $(pwd)"
  $fileview "$basename"
  env ls -lhFG1 --color=auto "$basename"
  read -p "[y2]: Keep this file? This change is permanent. 3=convert to mp3 and remove original (requires ffmpeg). y/3/n: " msg
  msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
  if [ "$msg" = "n" ] || [ "$msg" = "no" ]; then
    rm "$basename" && echy "Removed."
  else
    echy "Kept video."
    if [ "$msg" = "3" ]; then # it would be better to try to use original audio from filefetch. this is lazy solution.
      echy "Converting to mp3 in new terminal."

      ffmpeg -loglevel warning -v error -stats -i "$basename" "$basename".mp3 || echy Failed to convert. && rm "$basename"
      # ($TERMINAL -e ffmpeg -loglevel warning -v error -stats -i "$basename" "$basename".mp3) || (echo "backup bc sht code"; ffmpeg -loglevel warning -v error -stats -i "$basename" "$basename".mp3) || echy Failed to convert. && rm "$basename"
    fi
  fi
}

cDup() { # check dup
  # id=$(echo $1 | sed 's/.*\=//' | sed 's/.*\///' | sed 's/\?.*//') 
  basename="$(env ls -1 "$filestore" | grep "$(echo "$1" | sed 's/.*\=//' | sed 's/.*\///' | sed 's/\?.*//')")"
  if [ "$2" = "-x" ] || [ "$2" = "--extract-audio" ]; then
    basename=$(echo "$basename" | grep 'opus\|mp3' 2> /dev/null || echo "$basename") # prioritize audio when using common audio flags
  fi
  basename=$(echo "$basename" | tail -1)

  # echy $basename
  if [ ! -z "$basename" ]; then
    read -p "[y2]: Found duplicate '$basename'. Play? (y/n) Otherwise download again." msg
    msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    if [ "$msg" = "" ]; then
      msg="yNull"
    fi
  fi
}

main() {
  if [ "${#args[@]}" = "0" ]; then
    cmd="$filefetch $@"
  else
    echy "${args[@]}"
    cmd="$filefetch ${args[@]} $@"
  fi
  # below sets basename + msg variables
  cDup "${@: -1}" "$1"
  if ! [ "$msg" = "" ]; then # empty = no dup file found
    if ! [ "$msg" = "n" -o "$msg" = "no" ]; then
      echy "Skipped download."
      cd "$filestore";view;return
    fi
  fi
  echy "running: $cmd"
  # return # dryrun
  $cmd
  basename="$(basename *)"
  if [ "$basename" = "*" ]; then
    echy "File not found. Possible reasons: Due to $filefetch error / invalid syntax. Not updated $filefetch. Bug with y2; consider making an issue if you've tried everything else."
    exyt;return
  fi
  mv "$basename" "$filestore" && cd "$filestore" && echy "Saved in: "$(pwd)"" && view
}

if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
  echo "Automate downloading, storing, checking for duplicates (not related to archive.txt if you know about that), getting and watching videos (mpv [recommended], cvlc, vlc, and some other players work) with a single command."
  echo
  # echo "Use this as first argument:"
  # echo -e "  --cwd      \t Broken: Use current working directory instead of $filestore.\n"
  echo "Choose one of the following options:"
  echo -e "  -g         \t Get downloaded video(s) with grep and fzf (this doesn't check partial videos in cache). Works with YT videos."
  echo -e "  0 <int?>   \t Apply useful extra flags to $filefetch (made for yt-dlp). Optional 2nd argument: Max video height size."
  echo -e "  <int> != 0 \t Max video height size"
  echo -e "  --max <int>\t Same as above"
  echo
  echo "Every other flag after will be passed to $filefetch."
  echo -e "Example:   \t y2 0 480 https://youtu.be/pVI_smLgTY0"
  echo -e "Example #2:\t y2 -x https://www.youtube.com/watch?v=xsDnEj2Hx4Q"
  echo
  echo "Above downloads audio of the youtube link when filefetch value is set to yt-dlp / youtube-dl."
  echo "For $filefetch help, use the $filefetch command instead (probably with --help)."
  echo
  echo "filefetch is set to $filefetch (default: yt-dlp)"
  echo "fileview  is set to $fileview (default: mpv)"
  echo "filestore is set to $filestore (default: \$HOME/y2)"
  echo "filecache is set to $filecache (default: \$HOME/.cache/y2)"
  echo

elif [ "$1" = "0" ]; then
  if [[ $2 =~ ^[0-9]+$ ]]; then
    echy "0 $2 adds these flags to $filefetch:"
    args=("-f" "bestvideo[height<=$2]+bestaudio/best[height<=$2]" "--embed-chapters" "--sponsorblock-mark" "all" "--embed-metadata" "--embed-thumbnail" "--add-metadata" "--embed-subs" "--sub-lang" "en")
    shift
  else
    echy "0 adds these flags to $filefetch:"
    args=("-f" "bestvideo[height<=1080]+bestaudio/best[height<=1080]" "--embed-chapters" "--sponsorblock-mark" "all" "--embed-metadata" "--embed-thumbnail" "--add-metadata" "--embed-subs" "--sub-lang" "en")
  fi
  # args=("-f" "bestvideo[height<=1080]+bestaudio/best[height<=1080]" "--embed-chapters" "--sponsorblock-mark" "all" "--embed-metadata" "--embed-thumbnail" "--add-metadata" "--embed-subs" "--sub-lang" "en" "--sponsorblock-remove" "sponsor")
  # Above remove sponsored parts of video.
  # "--sponsorblock-remove" "all,-intro,-outro,-selfpromo,-preview,-interaction,-poi_highlight" # might not work

  shift
  main "$@"
elif [[ $1 =~ ^[0-9]+$ ]]; then
  echy "an integer argument (excluding 0) adds these flags to $filefetch: "
  args=("-f" "bestvideo[height<=$1]+bestaudio/best[height<=$1]")
  shift
  main "$@"
elif [ "$1" = "-g" ]; then
  basename=$(env ls -1 "$filestore" | grep -i $(echo $2 | sed 's/.*\=//' | sed 's/.*\///' | sed 's/\?.*//') | fzf -1) && (cd "$filestore";view) || echy "No result found."
elif [ "$1" = "--max" ]; then
  echy "--max adds these flags to $filefetch: "
  args=("-f" "bestvideo[height<=$2]+bestaudio/best[height<=$2]")
  shift;shift
  main "$@"
else
  main "$@"
fi
