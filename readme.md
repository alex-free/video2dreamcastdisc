# [alex-free.github.io](https://alex-free.github.io)

# Video2DreamcastDisc

By Alex Free

Video2DreamcastDisc is a complete [suite of programs](#bundled) that can convert **any video file** for playback on a Sega Dreamcast console using the [Sofdec](https://segaretro.org/Sofdec) video format.

Convert any existing media file to a self-booting auto-playing Sega Dreamcast .CDI file that can be burned to a CD-R for use on Mil-CD exploitable consoles. Or use it as a replacement for the [Sega Dreamcast Movie Creator](http://www.dc-swat.ru/download/pc/SFD_Tool_Pack_v1.0_by_SWAT.exe) in a workflow for creating Sofdec FMVs in Sega Dreamcast development.

## Table Of Contents

*   [Downloads](#downloads)
*   [Usage](#usage)
*   [Video Specifications](#svideo-specifications)
*   [License](#License)


## Links

*   [Homepage](https://alex-free.github.io/video2dreamcastdisc)
*   [GitHub](https://github.com/alex-free/video2dreamcastdisc)

## Downloads

### v1.1.1 - 3/25/2022

[Video2DreamcastDisc v1.1.1](https://github.com/alex-free/video2dreamcastdisc/releases/download/v1.1.1/video2dreamcastdisc-1.1.1-win32.zip) _For Windows 7 32-bit/64-bit or newer_

Using git:

    git clone https://github.com/alex-free/video2dreamcastdisc

View [all releases](https://github.com/alex-free/video2dreamcastdisc/releases/).

Changelog:

### Version 1.1.1 (3/25/2022)

*   Added option 4 to split long videos into multiple shorter segments for further conversion by Video2DreamcastDisc.
*   Change both `WARNER.PVR` and `SOFTDEC.PVR` to my own custom white colored PVR file to remove the "We Proudly Present" banner played at the end of videos by SFDPlayer.
*   Changed output files from being named "video", they are now named the same as the original source file with a different extension.

### Version 1.1 (2/18/2022)

*   Updated SFD\_Player using the ECHELON self-boot method.
*   The `vid2dcd.bat` script now creates a `video.cdi` file using CDI4DC which is self-bootable.
*   Moved tools into the `bin` directory.
*   Added automatic burning ability of video.cdi.
*   Added option to just make a Sofdec .sfd file and nothing else.

## Usage

Video2DreamcastDisc provides the `vid2dcd.bat` script in each release, which performs all operations. This script accepts only one argument. You can either:

*   Drag n' drop a video file into the `vid2dcd.bat` file to start converting the dropped file (recommended method).
*   Open `cmd.exe`, and execute `vid2dcd.bat` with an argument like `vid2dcd.bat myhuge.mkv`.

When executing the `vid2dcd.bat` with a media file as argument as explained in the above 2 methods, you will be prompted in the `cmd.exe` window to enter an option:

*   Option 1 will create a `video.cdi` file in the Video2DreamcastDisc directory and burn that file automatically to a blank CD-R in your computer's optical drive, all in one go.
*   Option 2 will create a `video.cdi` file in the Video2DreamcastDisc directory that can be burned to a CD-R for Sega Dreamcast playback..
*   Option 3 will create a `video.sfd` file in the Video2DreamcastDisc directory.
*   Option 4 allows you to split an existing video file into multiple segments that are each limited to a maximum amount of minutes per segment that you provide. This means you can take a very long video file and split it into i.e. 25 minute segments so that each part of the video can be it's own video file which individually fis on it's own CD-R. A movie could be split like this to be converted by Video2DreamcastDisc afterwards for playback via multiple CD-Rs.

If you have selected option 1, 2, or 3, the next thing you will be prompted for is your desired video bitrate. This does not effect the audio in your final video played on the Sega Dreamcast. The maximum video bitrate you can enter that will actually play on the Sega Dreamcast is `3600`. I encountered some stuttering only in the first minute of playback in videos at this bitrate. Anyways I recommend `3300` to guarantee no stuttering on any CD-R. This looks great, and doesn't take up quite as much space as using `3600`. You can only over burn so much to a CD-R, so if you find that using your desired bitrate generates to big of a `.cdi` for you to burn on your CD-R media you should use a lower value. I do not recommend anything lower then `2000`, but the choice is yours for the size/length of playback trade off.

![example 1](images/vid2dcd-1.png) 

![example 2](images/vid2dcd-2.png) 

![example 3](images/vid2dcd-3.png) 

![example 4](images/vid2dcd-4.png) 

![example 5](images/vid2dcd-5.png)

### Video Specifications

*   Resolution: 352x240 (maximum supported by SFD\_Player)
*   Video bitrate: user selectable, up to 3600 kilobits per second
*   Audio bitrate: 396 kilobits per second (maximum supported by SFD\_Player)
*   Audio: Stero ADX
*   Video: MPEG-1
*   Format: Sofdec Video

### Version 1.0 (2/13/2022)

*   First release.

# License

* Video2DreamcastDisc itself is released under the 3-BSD license, please see the file `licenses/v2dcd.txt` in each release. My small tool 'legaladx' is also released under the same license, found in the file `licenses/legaladx.txt`.
*   [FFmpeg](https://www.ffmpeg.org/) - this does the initial conversion from the source file into WAV audio and MPEG-1 video. FFmpeg is licensed under the GNU GPL v3. See the file `licenses/ffmpeg.txt` in each Video2DreamcastDisc release for more info. The FFmpeg included in Video2DreamcastDisc is the "essentials" static build from [https://www.gyan.dev/ffmpeg/builds](https://www.gyan.dev/ffmpeg/builds/).
*   [Adxencd](http://www.dc-swat.ru/download/pc/ADX_Tool_Pack_v1.0_by_SWAT.exe) - released by [dcswat.ru](http://www.dc-swat.ru). This converts the WAV file previously converted from the source file with FFmpeg to an ADX audio file.
*   LegalADX - this program was written by me in C to do one thing, convert the audio ADX file to a new one that work with Sfdmuxapp. This is open source under the 3-BSD license and source code is provided in the Video2DreamcastDisc releases. See the file `licenses/legaladx.txt` for more info.
*   [Sfdmuxapp](https://forum.xentax.com/viewtopic.php?t=3084) - created by [Zench](https://forum.xentax.com/memberlist.php?mode=viewprofile&u=4697&sid=d224e63302049b15631fe92cb3527c94), released on July 15th 2008. This is a command line program that interfaces with the `Sfdmux.dll` from the [Sega Dreamcast Movie Creator](http://www.dc-swat.ru/download/pc/SFD_Tool_Pack_v1.0_by_SWAT.exe).
*   [SFD\_Player](http://www.dc-swat.ru/download/dc/SFD_Player.7z) - released all the way back in 2000, this Sega Dreamcast program automatically plays the `movie/BUMPER.SFD` file on the disc it is burned to. I have updated the original release using the ECHELON method for self-boot so that it does not require the Utopia Boot Disc!
*   [MKISOFS](http://cdrtools.sourceforge.net/private/cdrecord.html) - part of the cdrtools suite of software, which is licensed under the GNU GPL and CDDL licenses. See the files `licenses/mkisofs-gpl3.txt` and `licenses/mkisofs-cddl.txt` in each Video2DreamcastDisc release directory for more info.
*   [Cdrecord](http://cdrtools.sourceforge.net/private/cdrecord.html) - part of the cdrtools suite of software, which is licensed under the GNU GPL and CDDL licenses. See the files `licenses/cdrecord-gpl3.txt` and `licenses/cdrecord-cddl.txt` in each Video2DreamcastDisc release directory for more info. [CDIRip](https://sourceforge.net/projects/cdimagetools/files/CDIRip/) - created by by DeXT/Lawrence Williams, which is licensed under GNU GPL v2 license. See the files `licenses/cdirip.txt` in each Video2DreamcastDisc release directory for more info.*   [CDI4DC](https://github.com/sizious/img4dc) - created by [Sizious](https://github.com/sizious/). CDI4DC is licensed under the GNU GPL v3, see the file `licenses/cdi4dc.txt` for more info.