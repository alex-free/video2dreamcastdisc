#!/bin/bash

set -e

echo "Video2DreamcastDisc v1.1.4 By Alex Free (8/13/2023)"

if [ $# -ne 1 ]; then
    echo "Incorrect number of arguments given to $0, aborted"
    exit 1
fi

output_name=$(basename "$1")

if ! command -v wine &> /dev/null; then
  echo "Error: Wine must be installed to use Video2DreamcastDisc"
  exit 1
fi

if [ ! -f "$1" ]; then
    echo "Cant open the file "$1" for conversion, aborted."
    exit 1
fi

cd "$(dirname "$0")"

if [ ! -f "config/video-bitrate.txt" ]; then
    mkdir -p config
    echo "Video bitrate config not found, setting to default 2800 kilobits per second"
    echo 2800 > config/video-bitrate.txt
fi

if [ ! -f "config/burn-speed.txt" ]; then
    mkdir -p config
    echo "Burn speed config not found, setting to default speed of 1x"
    echo 1 > config/burn-speed.txt
fi

speed=$(cat config/burn-speed.txt)
echo -e "\nBurn speed: "$speed"x"
bitrate=$(cat config/video-bitrate.txt)
echo -e "Video Bitrate: "$bitrate" kilobits per second"

echo -e "\nWhat do you want to do with \""$1"\"?\n"
echo =====================================
echo 1 - Make .cdi file and burn to CD-R
echo 2 - Make .cdi file
echo 3 - Make .sfd file
echo 4 - Split video into smaller segments
echo 5 - Change burn speed
echo 6 - Change video bitrate
echo -e "=====================================\n"
PS3="Enter an option number: "

select opt in make-cdi-and-burn make-cdi make-sfd split change-burn-speed change-video-bitrate quit; do

  case $opt in
    make-cdi-and-burn)
      output=1
      break
      ;;
    make-cdi)
      output=2
      break
      ;;
    make-sfd)
      output=3
      break
      ;;
    split)
      output=4
      break
      ;;
    change-burn-speed)
      output=5
      break
      ;;
    change-video-bitrate)
      output=6
      break
      ;;
    quit)
      exit 0
      ;;
    *) 
      echo "Invalid option $REPLY, try again"
      ;;
  esac
done

echo
rm -rf "$output_name".cdi bin/video.iso bin/audio.sfa bin/video.m1v bin/audio.adx bin/audio.wav bin/sfd_player/movie/BUMPER.SFD

if [ "$output" = 6 ]; then
  	echo Enter a number in the recommended range of 1000-2800. Lower values = more video playback time per CD-R but less quality. Higher values = less video playback time per CD-R but higher quality. Any value above 2800 may result in stuttering depening on the CD media.
    read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate

    while [[ ! "$bitrate" =~ ^[0-9]+$ ]]; do
      echo "${bitrate} is not a number, try again"
      read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate
    done

#
#   while [ "$bitrate" -gt 2800 -o "$bitrate" -lt 1000 ]; do
#     echo "${bitrate} is not in the valid range, try again"
#     read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate
#     while [[ ! "$bitrate" =~ ^[0-9]+$ ]]; do
#       echo "${bitrate} is not a number, try again"
#       read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate
#       done
#   done

    echo "$bitrate" > config/video-bitrate.txt
    exit 0
fi

if [ "$output" = 5 ]; then
  	echo "Enter a number for the speed to burn your CD-R. If your burner does not support the speed you provide the closest available speed will be used instead."
	  read -p "Set burn speed:" speed

    while [[ ! "$speed" =~ ^[0-9]+$ ]]; do
       echo "${speed} is not a number, try again"
	    read -p "Set burn speed:" speed
    done

    echo "$speed" > config/burn-speed.txt
    exit 0
fi

if [ "$output" = 4 ]; then
    rm -rf "${output_name%.*}"-splits
    mkdir "${output_name%.*}"-splits
	  read -p "Set split interval in minutes:" split

    while [[ ! "$split" =~ ^[0-9]+$ ]]; do
       echo "${split} is not a number, try again"
       read -p "Set split interval in minutes:" split
    done

  if [ "${output_name##*.}" != "mkv" ] && ["${output_name##*.}" != "MKV" ]; then
    bin/ffmpeg-64-static/ffmpeg -i "$1" -codec copy -f segment -segment_time 00:"$split":00 -reset_timestamps 1 "${output_name%.*}"-splits/"${output_name%.*}-%03d.${output_name##*.}"
    exit 0
  fi

# handle mkv with mkvmerge since ffmpeg doesn't work for mkv splitting
  bin/mkvmerge --split duration:00:"$split":00.000 "$1" -o "${output_name%.*}"-splits/"${output_name%.*}-split.${output_name##*.}"
  exit 0
fi

bin/ffmpeg-64-static/ffmpeg -i "$1" -vcodec mpeg1video -b:v "$bitrate"k -maxrate "$bitrate"k -minrate "$bitrate"k -bufsize "$bitrate"k -muxrate "$bitrate"k -s 352x240 -an -qscale 0 bin/video.m1v
bin/ffmpeg-64-static/ffmpeg -i "$1" -ac 2 bin/audio.wav

# now we don't need $1
cd bin
wine adxencd audio.wav audio.adx
./legaladx audio.adx audio.sfa
wine sfdmux -V=video.m1v -A=audio.sfa -S=BUMPER.SFD

if [ "$output" = 3 ]; then
  mv BUMPER.SFD ../"${output_name%.*}".sfd
  full_sfd_output=$(realpath ../"${output_name%.*}".sfd)
  ffmpeg-64-static/ffprobe ../"${output_name%.*}".sfd
  echo
  echo "A SFD file has been created at "\"$full_sfd_output\"" from the input file "\"$1"\"."
elif [ "$output" = 2 ]; then
	mv BUMPER.SFD sfd_player/movie/BUMPER.SFD
  ./mkisofs -V SFDVIDEO -G IP.BIN -joliet -rock -l -o video.iso sfd_player
  wine 	cdi4dc video.iso ../"${output_name%.*}".cdi -d
  full_cdi_output=$(realpath ../"${output_name%.*}".cdi)
  echo
  echo "A CDI file has been created at "\"$full_cdi_output\"" from the input file "\"$1"\". Burn this "\"$full_cdi_output\"" file to a CD-R, and it will self-boot and auto-play "$1" on a Sega Dreamcast!"
elif [ "$output" = 1 ]; then
	mv BUMPER.SFD sfd_player/movie/BUMPER.SFD
  ./mkisofs -V SFDVIDEO -G IP.BIN -joliet -rock -l -o video.iso sfd_player
  wine cdi4dc video.iso ../"${output_name%.*}".cdi -d
  ./cdirip ../"${output_name%.*}".cdi -iso
  echo -e "\n====================================="
  echo "You need root privilages to burn the CD-R, please enter your account password if prompted"
  echo -e "=====================================\n"
  sudo ./cdrecord -overburn -speed="$speed" -v -tao -multi -xa tdata01.iso
	sudo ./cdrecord -eject -overburn -speed="$speed" -v -tao -xa tdata02.iso
	rm tdata01.iso
	rm tdata02.iso
  full_cdi_output=$(realpath ../"${output_name%.*}".cdi)
	echo
	echo -e "A CDI file has been created at "\"$full_cdi_output\"" from the input file "\"$1"\", and should have been successfully burned to a CD-R by your computer's optical drive.\n" 
  echo "If the burn did not complete, see if the "\"$full_cdi_output\"" file is too big to fit on your CD-R. Note that overburning is supported by Video2DreamcastDisc so you should be able to write more to the CD-R than it's official capacity, but by how much depends on your CD-R media and optical drive. You can split up the video into smaller segments with option number 4 if your video needs to be split into multiple discs."
	echo -e "\nAfter a successful burn, this CD-R will self-boot then auto-play "\"$1"\" on the Sega Dreamcast!"
fi

rm -rf bin/audio.wav bin/audio.adx bin/video.m1v audio.sfa video.iso sfd_player/movie/BUMPER.SFD
