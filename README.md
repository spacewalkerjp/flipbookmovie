# Project making flip-book movie | プロジェクト パラパラ動画作成
Make flip-book movie (4K) from many photos(JPEG).
たくさんの写真(JPEG)から4Kのパラパラ動画を作ります。

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

# Environment | 想定環境
* Windows 10 (Pro)
* スクリプト言語：PowerShell 7.0 (Or 5.1)
* EXIF編集：exiftool.exe (Windows binary : ExifTool Version Number : 11.99 )
* 画像変換（リサイズ・拡張等）：ImageMagick 7.0.10-20-Q16 ( ImageMagick-7.0.10-20-Q16-x64-static.exe )
* 動画作成：ffmpeg (Windows binary : ffmpeg-20200620-29ea4e1-win64-static.zip )

# Procedure
  * PS dir *.jpg | %{$x=0} {Rename-Item $_ -NewName "Base$($x.tostring('000000')).jpg"; $x++ }
    * フォルダ（ディレクトリ内）の全JPEG画像をBase000000.jpg Base000001.jpgとシーケンシャルなファイル名に変更（リネーム）
  * PS mkdir out
    * 出力先の`out`フォルダの作成
  * PS .\ResizeExtentJPEGTo4KJPEG.ps1 (get-item .\*.jpg)
    * PowerShellスクリプトで全JPEGを、4K(3840x2160)の解像度にリサイズ、アスペクト比違い、縦撮り写真等も含めて拡張（背景色黒）する(ExiftoolとImageMagickを使用）
  * PS/CMD ffmpeg.exe -r 3 -i Base%06d.jpg -vcodec libx264 -b 50M -pix_fmt yuv420p -r 30 output_3_30.mp4
    * ffpmegで複数のJPEG画像から動画を作成：上記設定は 毎秒３枚, 出力動画30fps, 4K(3840x2160)解像度, 50Mbps Video bitrate, H264 encoding 
    
# About PowerShell script `ResizeExtentJPEGTo4KJPEG.ps1`
  * check the `Orientation` of the JPEG photo by using exiftool.exe to detect vertical photo.
  * if the photo is vertical photo (EXIF JPEG Orientation is 6 or 8), reset the `Orientation` = 1 (normal : horizontal photo).
  * resize and extent to 4K resolution (3840 x 2160) by using ImageMagick : output directory is `out` which is need to create before execution.
