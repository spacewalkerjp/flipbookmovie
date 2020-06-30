# Project making flip-book movie | プロジェクト パラパラ動画作成
* Make flip-book movie (4K) from many photos(JPEG).
* たくさんの写真(JPEG)から4Kのパラパラ動画を作ります。

# Objective, background | 目的・背景
I take many pictures(photos) of my family every day by my mirror less cameras.
I select some good rating photos of them and develop (retouch) them.
One day, I thought I wanted to re-use the not selected photos for the daily `flip-book` movie.
In this project, I'm going to explain the procedures and some scripts to make the movie.

普段からミラーレスカメラを用いて多量の家族写真を撮っています。
もちろんその中から良いものを選び、現像したりリタッチしたりして記念の写真として残しているわけですが、
ある日、選ばれなかった没写真も何かに再利用できないかと考えました。
没写真といっても多少視線が来ていないとか、少しボケている・ぶれているなどの写真で、その時の情景の一コマには十分価値のある写真と考えました。
そこで、その日単位の撮った全ての写真を使ってパラパラ動画（今回は4K動画）として残せば、その１枚１枚では没になった写真の利活用に繋がるのかなと考えました。
このプロジェクトでは、簡単に多量のJPEGから4K動画を作成する手順・スクリプトを紹介します。

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
  * 0) JPEG写真は、アスペクト比が異なり、更に横写真、縦写真といろいろ混在する。今回4K(3840x2160)動画を作成する際に3840x2160となるように黒背景を追加してリサイズする。ここで悩ましいのが「縦写真」の場合（例として、4160 x 6240 : Fujifilm X-T4の例）、そのJPEG写真の中に`Orientation`という縦写真である（またどちらが下になるか）という回転情報が含まれており、ImageMagick等でリサイズ・黒背景拡張はそこで誤動作が発生する（何を考えないと2160 x 3840の縦長の画像にリサイズされてしまう）。このスクリプトではこの`Orientation`を検出し、その補正（回転）を行った上でImageMagickでリサイズ・黒背景拡張をし3840x2160画像を作成する。
　* 1) Exiftoolを使ってJPEG Photoに含まれる`Orientation`を調べる。Orientationは1~8の数字であり、普通の横写真なら1。縦位置はどちらが下かにより6か8という数字となる。Orientation = 6の時はカメラを反時計回りに回して撮った縦位置構図。Orientation = 8の時はカメラを時計回りに回して撮った縦位置構図。
  * 2) Orientationが6か8の場合には、Exiftoolを使ってOrientationを強制的に1に設定する。ここを1にセットしておかないと後段のImageMagickがリサイズ方向を間違える。この次点で6, 8だったJPEG画像は90度（-90度）回転した画像となる。
  * 3) ImageMagickを使って3840x2160のリサイズ・黒背景拡張画像を`out`フォルダに順次変換する。
    * 3a) Orientation = 6, 8であった画像は90度（または-90度）回転させる(-rotate 90 オプションを追加）
    * 3b) それ以外は、3840x2160に長辺基準でリサイズ(-resizeオプション）し、その画像を中心に3840x2160になるように黒背景で拡張(-extentオプション)し、`out`フォルダに出力する。JPEGの変換品質は最高の100に設定
 * Ref) スクリプト中のfunction fStartProcessは、PowerShell内で、外部プロセスコマンドを立ち上げ、標準出力等を変数に格納する関数であり、exiftool, ImageMagick実行に利用している。
 
 ## License

Script released under the [MIT License][License].

## Disclaimer
 
 [Blog-Badge]: https://img.shields.io/badge/Blog-spacewalker.jp-blue
 [Videos-Badge]: https://img.shields.io/badge/Youtube-spacewalker.jp-red
 [Blog]: https://www.youtube.com/c/spacewalkerjp/
 [Videos]: https://www.youtube.com/c/spacewalkerjp/
