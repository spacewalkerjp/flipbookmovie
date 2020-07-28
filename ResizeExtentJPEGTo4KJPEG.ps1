# function : execute external process and get the stdout
function fStartProcess([string]$sProcess,[string]$sArgs,[ref]$pOutPut, [ref]$pStdOut)
{
	$oProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
	$oProcessInfo.FileName = $sProcess
	$oProcessInfo.RedirectStandardError = $true
	$oProcessInfo.RedirectStandardOutput = $true
	$oProcessInfo.UseShellExecute = $false
	$oProcessInfo.Arguments = $sArgs
	$oProcess = New-Object System.Diagnostics.Process
	$oProcess.StartInfo = $oProcessInfo
	$oProcess.Start() | Out-Null
	$oProcess.WaitForExit() | Out-Null
	$sSTDOUT = $oProcess.StandardOutput.ReadToEnd()
	$sSTDERR = $oProcess.StandardError.ReadToEnd()
	$pOutPut.Value="Commandline: $sProcess $sArgs`r`n"
	$pOutPut.Value+="STDOUT: " + $sSTDOUT + "`r`n"
	$pOutPut.Value+="STDERR: " + $sSTDERR + "`r`n"
	$pStdOut.Value = $sSTDOUT
	return $oProcess.ExitCode
}

# Get current path
$str_path = (Convert-Path .)
$exiftoolexe = $str_path + "\exiftool.exe"
$imagemagickexe = "magick.exe"
$outputfolder = $str_path + "\out"


# PS .\ResizeExtentJPEGTo4KJPEG.ps1 (get-item .\*.jpg)
$jpeg_filepath_array = $args[0] -split ","
 
# loop for each `JPEG files`
for($i=0; $i -lt $jpeg_filepath_array.Length; $i ++){
	# input JPEG file
	Write-Host ('Input filename[' + [string]$i + '] = ' + $jpeg_filepath_array[$i])
	$jpegfile = $jpeg_filepath_array[$i]

	# check JPEG orientation (0-1) by using `exiftool`
	$Output=""
	$pStdOut=""
	$iRet=fStartProcess $exiftoolexe "-n -T -Orientation $jpegfile" ([ref]$Output) ([ref]$pStdOut)
	#write-host "Exitcode: $iRet`r`n Output: $Output"

	# get JPEG rotation value (1-8)
	$JPEGOrientation = 1
	$JPEGOrientation = [int]$pStdOut
	Write-Output $JPEGOrientation

	if ( $JPEGOrientation -eq 6 ) {
		$Output=""
		$pStdOut=""
		$iRet=fStartProcess $exiftoolexe "-Orientation=1 -n $jpegfile" ([ref]$Output) ([ref]$pStdOut)
	  	Write-Host "Orientation : 6"
		$Output=""
		$pStdOut=""
		$iRet=fStartProcess $imagemagickexe "mogrify -quality 100 -path $outputfolder -rotate 90 -resize 3840x2160 -gravity Center -extent 3840x2160 -background black $jpegfile" ([ref]$Output) ([ref]$pStdOut)

	}
	elseif ( $JPEGOrientation -eq 8 ) {
		$Output=""
		$pStdOut=""
		$iRet=fStartProcess $exiftoolexe "-Orientation=1 -n $jpegfile" ([ref]$Output) ([ref]$pStdOut)
		write-host "Exitcode: $iRet`r`n Output: $Output"
	  	Write-Host "Orientation : 8"
		$Output=""
		$pStdOut=""
		$iRet=fStartProcess $imagemagickexe "mogrify -quality 100 -path $outputfolder -rotate -90 -resize 3840x2160 -gravity Center -extent 3840x2160 -background black $jpegfile" ([ref]$Output) ([ref]$pStdOut)
	#	write-host "Exitcode: $iRet`r`n Output: $Output"
	} 
	elseif ( $JPEGOrientation -ge 1 -and $JPEGOrientation -le 8 ) {
	  	Write-Host "Orientation : 1-8(not 6, 8)"
		$Output=""
		$pStdOut=""
		$iRet=fStartProcess $imagemagickexe "mogrify -quality 100 -path $outputfolder -resize 3840x2160 -gravity Center -extent 3840x2160 -background black $jpegfile" ([ref]$Output) ([ref]$pStdOut)
	} 
	else {
	  	Write-Host "Orientation : NOT 1-8"
	}

}

