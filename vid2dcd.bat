@echo off
cd /d %~dp0\bin
set argC=0
for %%x in (%*) do Set /A argC+=1
setlocal enabledelayedexpansion

echo Video2DreamcastDisc v1.1.4 By Alex Free (8/13/2023)
echo.

IF NOT "%argC%" == "1" (
	echo Incorrect number of arguments given to %0%, aborted
	echo.
	pause
	exit 1
)

IF NOT EXIST "%~f1" (
	echo Can't open the file "%~f1" for conversion, aborted..
	echo.
	pause
	exit 1
)

IF NOT EXIST "..\config\video-bitrate.txt" (
    mkdir config
    echo Video bitrate config not found, setting to default 2800 kilobits per second
	echo 2800> ..\config\video-bitrate.txt
)

IF NOT EXIST "..\config\burn-speed.txt" (
    mkdir config
    echo Burn speed config not found, setting to default speed of 1x
	echo 1> ..\config\burn-speed.txt
)

set /p speed= < ..\config\burn-speed.txt
echo Burn Speed: %speed%x
set /p bitrate= < ..\config\video-bitrate.txt
echo Video Bitrate: %bitrate% kilobits per second

:select_option
echo.
echo What do you want to do with "%~f1"?
echo.
echo =====================================
echo 1 - Make .cdi file and burn to CD-R
echo 2 - Make .cdi file
echo 3 - Make .sfd file
echo 4 - Split video into smaller segments
echo 5 - Set burn speed
echo 6 - Set video bitrate
echo =====================================
echo.

set /p output="Enter an option number:"
IF %output% == 6 (
	echo Modify Video Bitrate Config
) ELSE IF %output% == 5 (
	echo Modify Burn Speed Config
) ELSE IF %output% == 4 (
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
del sfd_player\movie\BUMPER.SFD 2> nul


IF %output% == 6 (
	echo Enter a number in the recommended range of 1000-2800. Lower values = more video playback time per CD-R but less quality. Higher values = less video playback time per CD-R but higher quality. Any value above 2800 may result in stuttering depening on the CD media.
	set /p bitrate="Enter your desired video track bitrate value in kilobits per second:"
	>..\config\video-bitrate.txt echo !bitrate!
	exit 0
)

IF %output% == 5 (
	echo Enter a number for the speed to burn your CD-R. If your burner does not support the speed you provide the closest available speed will be used instead.
	set /p speed="Set burn speed:"
	>..\config\burn-speed.txt echo !speed!
	exit 0
)

IF %output% == 4 (
	rmdir /S /Q ..\\"%~n1"-splits 2> nul
	set /p split="Set split interval in minutes:"
	mkdir ..\\"%~n1"-splits
		
	IF NOT "%~x1" == ".mkv" (
		IF NOT "%~x1" == ".MKV" (
			ffmpeg -i "%~f1" -codec copy -f segment -segment_time 00:!split!:00 -reset_timestamps 1 ..\\"%~n1"-splits\\"%~n1"-%%03d"%~x1"
			echo.
			echo The file "%~f1" has been split into !split! minute segments, which can be converted by Video2DreamcastDisc individually for multiple discs. These !split! minute segments are located at "%~dp0%~n1-splits"
			pause
			exit 0
		)
	)

	mkvmerge --split duration:00:!split!:00.000 "%~f1" -o "%~n1"-splits/"%~n1"-split."%~x1"
	echo.
	echo The file "%~f1" has been split into !split! minute segments, which can be converted by Video2DreamcastDisc individually for multiple discs. These !split! minute segments are located at "%~dp0%~n1-splits"
	pause
	exit 0
)

ffmpeg -i "%~f1" -vcodec mpeg1video -b:v !bitrate!k -maxrate !bitrate!k -minrate !bitrate!k -bufsize !bitrate!k -muxrate !bitrate!k -s 352x240 -an video.m1v
ffmpeg -i "%~f1" -ac 2 audio.wav
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
	cdrecord -overburn -speed=!speed! -v -tao -multi -xa s01t01.iso
	cdrecord -eject -overburn -speed=!speed! -v -tao -xa s02t02.iso
	del s01t01.iso
	del s02t02.iso
	echo.
	echo  A "%~n1.cdi" file has been created in "%~dp0" from the input file "%~f1", and should have been successfully burned to a CD-R by your computer's optical drive. 
	echo.
	echo If the burn did not complete, see if the "%~n1.cdi" file is too big to fit on your CD-R. Note that overburning is supported by Video2DreamcastDisc so you should be able to write more to the CD-R than it's official capacity, but by how much depends on your CD-R media and optical drive. You can split up the video into smaller segments with option number 4 if your video needs to be split into multiple discs.
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