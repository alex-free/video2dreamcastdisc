@echo off
cd /d %~dp0
set argC=0
for %%x in (%*) do Set /A argC+=1

echo Video2DreamcastDisc v1.0 By Alex Free
echo.

IF NOT "%argC%" == "1" (
	echo Incorrect number of arguments given to %0%, aborted
	pause
	exit
)

IF NOT EXIST "%~f1" (
	echo Can't open the file "%~f1" for conversion, aborted..
	pause
	exit
)

set /p bitrate="Enter your desired video track bitrate value in k/s, i.e you can enter 3600 here. Lower then 1100 is not recommended, 3600 is the max. Lower bitrates take up less space and allow for longer videos : 
echo.

ffmpeg -i "%~f1" -vcodec mpeg1video -b:v %bitrate%k -maxrate %bitrate%k -minrate %bitrate%k -bufsize %bitrate%k -s 352x240 -an video.m1v
ffmpeg -i "%~f1" audio.wav
adxencd audio.wav audio.adx -lmsec 396k
legaladx audio.adx audio.sfa
sfdmux -V=video.m1v -A=audio.sfa -S=BUMPER.SFD
del audio.wav
del audio.adx
del video.m1v
del audio.sfa
move BUMPER.SFD sfd_player\movie\BUMPER.SFD
mkisofs -V SFDVIDEO -o video.iso sfd_player
del sfd_player\movie\BUMPER.SFD
echo.
echo  A video.iso file has been created in  "%~dp0" from the input file "%~f1". Burn this video to a CD-R and boot it with the Utopia Boot Disc to play the Sega Dreamcast version of "%~f1"!
pause
) ELSE (
	ECHO.ERROR: Vid2DC requires 1 argument!
)
