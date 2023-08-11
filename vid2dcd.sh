#!/bin/bash

set -e

echo "Video2DreamcastDisc v1.1.2 By Alex Free (8/10/2023)"

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
else
    echo "Input File: "$1""
fi

cd "$(dirname "$0")"/bin

echo "What do you want to do with "$1"?"
echo
echo =====================================
echo 1 - Make .cdi file and burn to CD-R
echo 2 - Make .cdi file
echo 3 - Make .sfd file
echo 4 - Split video into smaller segments
echo =====================================
echo
PS3="Enter an option number: "

select opt in make-cdi-and-burn make-cdi make-sfd split quit; do

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
    quit)
      exit 0
      ;;
    *) 
      echo "Invalid option $REPLY, try again"
      ;;
  esac
done

echo
rm -rf ../"$output_name".cdi video.iso audio.sfa video.m1v audio.adx audio.wav sfd_player/movie/BUMPER.SFD

if [ "$output" = 4 ]; then
    rm -rf ../"${output_name%.*}"-splits
    mkdir ../"${output_name%.*}"-splits
	  read -p "Set split interval in minutes:" split

    while [[ ! "$split" =~ ^[0-9]+$ ]]; do
       echo "${split} is not a number, try again"
       read -p "Set split interval in minutes:" split
    done

    ffmpeg-64-static/ffmpeg -i "$1" -codec copy -f segment -segment_time 00:"$split":00 -reset_timestamps 1 ../"${output_name%.*}"-splits/"${output_name%.*}%03d.${output_name##*.}"
    exit 0
fi

echo Enter a number in the range of 1000-3200. Lower values = more video playback time per CD-R but less quality. Higher values = less video playback time per CD-R but higher quality
read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate
echo

while [[ ! "$bitrate" =~ ^[0-9]+$ ]]; do
   echo "${bitrate} is not a number, try again"
   read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate
done

while [ "$bitrate" -gt 3200 -o "$bitrate" -lt 1000 ]; do
   echo "${bitrate} is not in the valid range, try again"
   read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate
   while [[ ! "$bitrate" =~ ^[0-9]+$ ]]; do
    echo "${bitrate} is not a number, try again"
    read -p "Enter your desired video track bitrate value in kilobits per second:" bitrate
   done
done

ffmpeg-64-static/ffmpeg -i "$1" -vcodec mpeg1video -b:v "$bitrate"k -maxrate "$bitrate"k -minrate "$bitrate"k -bufsize "$bitrate"k -muxrate "$bitrate"k -s 352x240 -an video.m1v
ffmpeg-64-static/ffmpeg -i "$1" audio.wav
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
	echo 
  echo =====================================
  echo "You need root privilages to burn the CD-R, please enter your account password if prompted"
  echo =====================================
  echo
  sudo ./cdrecord -overburn -speed=1 -v -tao -multi -xa tdata01.iso
	sudo ./cdrecord -eject -overburn -speed=1 -v -tao -xa tdata02.iso
	rm tdata01.iso
	rm tdata02.iso
  full_cdi_output=$(realpath ../"${output_name%.*}".cdi)
	echo
	echo  "A CDI file has been created at "\"$full_cdi_output\"" from the input file "\"$1"\", and should have been successfully burned to a CD-R by your computer's optical drive." 
  echo
  echo "If the burn did not complete, see if the "\"$full_cdi_output\"" file is too big to fit on your CD-R. Note that overburning is supported by Video2DreamcastDisc so you should be able to write more to the CD-R than it's official capacity, but by how much depends on your CD-R media and optical drive. You can split up the video into smaller segments with option number 4 if your video needs to be split into multiple discs."
	echo
	echo "After a successful burn, this CD-R will self-boot then auto-play "$1" on the Sega Dreamcast!"
fi

rm -rf bin/audio.wav bin/audio.adx bin/video.m1v audio.sfa video.iso sfd_player/movie/BUMPER.SFD