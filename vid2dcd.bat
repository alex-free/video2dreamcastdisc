@echo off
cd /d %~dp0\bin
set argC=0
for %%x in (%*) do Set /A argC+=1

echo Video2DreamcastDisc v1.1.1 By Alex Free (3/25/2022)
echo.

IF NOT "%argC%" == "1" (
	echo Incorrect number of arguments given to %0%, aborted
	echo.
	pause
	exit
)

IF NOT EXIST "%~f1" (
	echo Can't open the file "%~f1" for conversion, aborted..
	echo.
	pause
	exit
) ELSE (
	echo Input File: "%~f1"
	echo.
)

:select_option
echo What do you want to do with "%~f1"?
echo.
echo =====================================
echo 1 - Make .cdi file and burn to CD-R
echo 2 - Make .cdi file
echo 3 - Make .sfd file
echo 4 - Split video into smaller segments
echo =====================================
echo.

set /p output="Enter an option number:"
IF %output% == 4 (
	echo Output: Multiple "%~x1" files
) ELSE IF %output% == 3 (
	echo Output: "%~n1.sfd"
) ELSE IF %output% == 2 (
	echo Output: "%~n1.cdi"
) ELSE IF %output% == 1 (
	echo Output: "%~n1.cdi"
) ELSE (
	echo Error: Invalid option %output%, try again:
	GOTO select_option
)

echo.
del audio.wav 2> nul
del audio.adx 2> nul
del video.m1v 2> nul
del audio.sfa 2> nul
del video.iso 2> nul
del ..\"%~n1".cdi 2> nul
del ..\video.sfd 2> nul
del sfd_player\movie\BUMPER.SFD 2> nul

IF %output% == 4 (
	setlocal enabledelayedexpansion
	rmdir /S /Q ..\\"%~n1"-splits 2> nul
	set /p split="Set split interval in minutes:"
	mkdir ..\\"%~n1"-splits
	ffmpeg -i "%~f1" -codec copy -f segment -segment_time 00:!split!:00 -reset_timestamps 1 ..\\"%~n1"-splits\\"%~n1"%%03d"%~x1"
	echo.
	echo The file "%~f1" has been split into !split! minute segments, which can be converted by Video2DreamcastDisc individually for multiple discs. These !split! minute segments are located at "%~dp0%~n1-splits"
	pause
	exit 0
)

echo =======================
echo Max Video Bitrate: 3300
echo Min Video Bitrate: 1000
echo =======================
echo NOTE: Technically the max video bitrate is 3600, but anything above 3300 may cause stuttering in the first minute of playback, however this goes away.
echo.
echo Lower = more video playback time per CD-R but less quality
echo Higher = less video playback time per CD-R but higher quality
set /p bitrate="Enter your desired video track bitrate value in kilobits per second:"
echo.

ffmpeg -i "%~f1" -vcodec mpeg1video -b:v %bitrate%k -maxrate %bitrate%k -minrate %bitrate%k -bufsize %bitrate%k -muxrate %bitrate%k -s 352x240 -an video.m1v
ffmpeg -i "%~f1" audio.wav
adxencd audio.wav audio.adx
legaladx audio.adx audio.sfa
sfdmux -V=video.m1v -A=audio.sfa -S=BUMPER.SFD

IF %output% == 3 (
	move BUMPER.SFD ..\"%~n1".sfd
	ffprobe ..\\"%~n1".sfd
	echo.
	echo  A video.sfd file has been created in "%~dp0" from the input file "%~f1".
) ELSE IF %output% == 2 (
	move BUMPER.SFD sfd_player\movie\BUMPER.SFD
	mkisofs -V SFDVIDEO -G IP.BIN -joliet -rock -l -o video.iso sfd_player
	cdi4dc video.iso ..\\"%~n1".cdi -d
	echo.
	echo  A "%~n1.cdi" file has been created in "%~dp0" from the input file "%~f1". Burn this "%~n1.cdi" file to a CD-R, and it will self-boot and auto-play "%~f1" on a Sega Dreamcast!
) ELSE IF %output% == 1 (
	move BUMPER.SFD sfd_player\movie\BUMPER.SFD
	mkisofs -V SFDVIDEO -G IP.BIN -joliet -rock -l -o video.iso sfd_player
	cdi4dc video.iso ..\\"%~n1".cdi -d
	cdirip ..\\"%~n1".cdi -iso
	cdrecord -overburn -speed=8 -v -tao -multi -xa s01t01.iso
	cdrecord -eject -overburn -speed=8 -v -tao -xa s02t02.iso
	del s01t01.iso
	del s02t02.iso
	echo.
	echo  A "%~n1.cdi" file has been created in "%~dp0" from the input file "%~f1", and should have been successfully burned to a CD-R in your computer's optical drive. If the burn did not complete, see if the "%~n1.cdi" file is to big to fit on your CD-R. Note that overburning is supported by Video2DreamcastDisc so you should be able to write more to the CD-R than it's official capacity, but by how much depends on your CD-R media and optical drive. You can split up the video into smaller segments with option number 4 if your video needs to be split into multiple discs.
	echo.
	echo After a successful burn, this CD-R will self-boot then auto-play "%~f1" on the Sega Dreamcast!
)

del audio.wav 2> nul
del audio.adx 2> nul
del video.m1v 2> nul
del audio.sfa 2> nul
del video.iso 2> nul
del sfd_player\movie\BUMPER.SFD 2> nul
echo.
pause