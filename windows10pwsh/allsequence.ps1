New-Item out -ItemType Directory
.\RenameJPEGFile2SequenceName.ps1
.\ResizeExtentJPEGTo4KJPEG.ps1 (get-item .\*.jpg) 
.\ffmpeg.exe -r 3 -i .\out\Base%06d.jpg -vcodec hevc_nvenc -cq 50 -preset slow -qmin 1 -qmax 15 -pix_fmt yuv420p -r 30 .\out\flipbook_r3_30fps_nvh265.mp4
.\setdatetimefromjpegtomovie.ps1
.\deletefiles.ps1