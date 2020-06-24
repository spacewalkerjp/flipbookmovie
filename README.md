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
* スクリプト言語：PowerShell 7.0
* EXIF編集：exiftool.exe
* 画像変換（リサイズ・拡張等）：ImageMagick
* 動画作成：ffmpeg
