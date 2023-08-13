# Changelog

## Version 1.1.3 (8/13/2023)

*   [Windows x86](https://github.com/alex-free/video2dreamcastdisc/releases/download/v1.1.3/video2dreamcastdisc-1.1.3-windows-x86.zip) _For Windows 10 32-bit/64-bit or newer_.

*   [Linux x86\_64](https://github.com/alex-free/video2dreamcastdisc/releases/download/v1.1.3/video2dreamcastdisc-1.1.3-linux-x86_64.zip) _For x86_64 Linux Distributions_ . 

Changes:

*   Fixed `adxencd.exe` crash when using media files with more then 2 audio tracks. Audio will always be stereo (mono input will be 'converted' to stereo, really dual mono)
*   Improved video quality to max by setting `-qscale 0`.
*   Fixed MKV files not being split properly by option 4 by adding MKVMerge. This makes the Windows version require Windows 10 or later however so that MKVMerge works.
*   Fixed a relative path as argument 1 not working on Linux.
*   Removed video bitrate range limit, allowing end users to experiment.
*   Changed recommended video bitrate range to 1000-2800 kilobits per second.

## Version 1.1.2 (8/10/2023)

*   [Windows x86](https://github.com/alex-free/video2dreamcastdisc/releases/download/v1.1.2/video2dreamcastdisc-1.1.2-windows-x86.zip) _For Windows 7 32-bit/64-bit or newer_.

*   [Linux x86\_64](https://github.com/alex-free/video2dreamcastdisc/releases/download/v1.1.2/video2dreamcastdisc-1.1.2-linux-x86_64.zip) _For x86_64 Linux Distros_ . 

Changes:

*   Added portable Linux build.
*   Refactored code and new build system.
*   Updated FFmpeg to 2023-08-07-git-d295b6b693 `ffmpeg-git-full`, pre-built static binaries from [https://www.gyan.dev/ffmpeg/builds](https://www.gyan.dev/ffmpeg/builds/).
*   New docs.

## Version 1.1.1 (3/25/2022)

*   Added option 4 to split long videos into multiple shorter segments for further conversion by Video2DreamcastDisc.
*   Change both `WARNER.PVR` and `SOFTDEC.PVR` to my own custom white colored PVR file to remove the "We Proudly Present" banner played at the end of videos by SFDPlayer.
*   Changed output files from being named "video", they are now named the same as the original source file with a different extension.

## Version 1.1 (2/18/2022)

*   Updated SFD\_Player using the ECHELON self-boot method.
*   The `vid2dcd.bat` script now creates a `video.cdi` file using CDI4DC which is self-bootable.
*   Moved tools into the `bin` directory.
*   Added automatic burning ability of video.cdi.
*   Added option to just make a Sofdec .sfd file and nothing else.

## Version 1.0 (2/13/2022)

*   First release.