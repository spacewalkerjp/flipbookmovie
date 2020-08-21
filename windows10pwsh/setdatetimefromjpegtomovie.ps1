# set input reference JPEG file
$inputJPEGFile = ".\Base000000.jpg"

# set target movie file
$targetMovieFile = ".\flipbook_r3_30fps_nvh265.mp4"


# set temp json file name
$tmpFileJson = ".\tmpPW.json"

# get create data from the top jpeg file by using ExifTool into temp JSON file
.\exiftool.exe -CreateDate -json $inputJPEGFile > $tmpFileJson

# set the got CreateDate to movie file
$json = ConvertFrom-Json -InputObject (Get-Content $tmpFileJson -Raw)
$cDate = $json.CreateDate
Write-Host $cDate
.\exiftool.exe -alldates="$cDate" $targetMovieFile

# rename movie filename from 
.\exiftool.exe '-FileName < ${datetimeoriginal}_%f.%e' -d %Y%m%d-%H%M%S $targetMovieFile

