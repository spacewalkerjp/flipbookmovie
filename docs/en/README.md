# Project making flip-book movie
* Make flip-book movie (4K) from many photos(JPEG).

# Objective, background | 目的・背景
I take many pictures(photos) of my family every day by my mirror less cameras.
I select some good rating photos of them and develop (retouch) them.
One day, I thought I wanted to re-use the not selected photos for the daily `flip-book` movie.
In this project, I'm going to explain the procedures and some scripts to make the movie.

[![Videos][Videos-Badge]][Videos]
[![Blog][Blog-Badge]][Blog]

# Environment | 想定環境
* Windows 10 (Pro)
* スクリプト言語：PowerShell 7.0 (Or 5.1)
* EXIF編集：exiftool.exe (Windows binary : ExifTool Version Number : 11.99 )
* 画像変換（リサイズ・拡張等）：ImageMagick 7.0.10-20-Q16 ( ImageMagick-7.0.10-20-Q16-x64-static.exe )
* 動画作成：ffmpeg (Windows binary : ffmpeg-20200620-29ea4e1-win64-static.zip )
* H/W Env (Reference) : AMD Ryzen 5 3600, NVIDIA GeForce GTX 1070(*if want to use GPU for ffmpeg encoding)

# Procedure
  * PS dir *.jpg | %{$x=0} {Rename-Item $_ -NewName "Base$($x.tostring('000000')).jpg"; $x++ }
    * フォルダ（ディレクトリ内）の全JPEG画像をBase000000.jpg Base000001.jpgとシーケンシャルなファイル名に変更（リネーム）
  * PS mkdir out
    * 出力先の`out`フォルダの作成
  * PS .\ResizeExtentJPEGTo4KJPEG.ps1 (get-item .\*.jpg)
    * PowerShellスクリプトで全JPEGを、4K(3840x2160)の解像度にリサイズ、アスペクト比違い、縦撮り写真等も含めて拡張（背景色黒）する(ExiftoolとImageMagickを使用）
  * Sample1) PS ffmpeg.exe -r 3 -i Base%06d.jpg -vcodec libx264 -b 60M -pix_fmt yuv444p -r 30 flipbook_r3_30fps.mp4
    * ffpmegで複数のJPEG画像から動画を作成する例(CPU H.264)：上記設定は 毎秒３枚, 出力動画30fps, YUV444, 4K(3840x2160)解像度, 60Mbps Video bitrate, H264 encoding(CPU)
  * Sample2) PS ffmpeg.exe -r 3 -i Base%06d.jpg -vcodec h264_nvenc -cq 50 -preset slow -qmin 1 -qmax 6 -pix_fmt yuv420p -r 30 flipbook_r3_30fps_nvh264.mp4
    * ffpmegで複数のJPEG画像から動画を作成する例(NVDIA GPU H.264)：上記設定は 毎秒３枚, 出力動画30fps, YUV444, 4K(3840x2160)解像度, 60Mbps（程度 -qmin -qmaxで調整）, H264 encoding(GPU)
  * Sample3) PS ffmpeg.exe -r 3 -i Base%06d.jpg -vcodec hevc_nvenc -cq 50 -preset slow -qmin 1 -qmax 15 -pix_fmt yuv420p -r 30 flipbook_r3_30fps_nvh265.mp4
    * ffpmegで複数のJPEG画像から動画を作成する例(NVDIA GPU H.265)：上記設定は 毎秒３枚, 出力動画30fps, YUV444, 4K(3840x2160)解像度, 30Mbps（程度 -qmin -qmaxで調整）, H265 encoding(GPU)
  * (addtional:1a) exiftool -CreateDate Base000000.jpg
    * Base000000.jpg最初の画像の時刻を上記コマンドで調べる
  * (addtional:1b) exiftool -alldates="20XX-YY-ZZ AA:BB:CC" flipbook_r3_30fps.mp4
    * flipbook_r3_30fps.mp4に撮影時刻等を記録する（任意の時間を設定する）コマンドの例

    
# About PowerShell script `ResizeExtentJPEGTo4KJPEG.ps1` | スクリプト解説
  * 1) check the `Orientation` of the JPEG photo by using exiftool.exe to detect vertical photo.
  * 2) if the photo is vertical photo (EXIF JPEG Orientation is 6 or 8), reset the `Orientation` = 1 (normal : horizontal photo).
  * 3) resize and extent to 4K resolution (3840 x 2160) by using ImageMagick : output directory is `out` which is need to create before execution.
  * Ref) The function `fStartProcess` is to execute external process and catch the stdout. This function is used for executing `exiftool.exe` `magick.exe` in this powershell script.
  
 ## License

Script released under the [MIT License][License].

## Disclaimer
 
 [Blog-Badge]: https://img.shields.io/badge/Blog-spacewalker.jp-blue
 [Videos-Badge]: https://img.shields.io/badge/Youtube-spacewalker.jp-red
 [Blog]: https://www.spacewalker.jp/
 [Videos]: https://www.youtube.com/c/spacewalkerjp/
