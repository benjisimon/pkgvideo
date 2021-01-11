##
## Script to package up videos using ffmpeg
##
param($Source, $Config)

Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$Bin = "$PSScriptRoot\bin"

. "lib\file.ps1"
. "lib\video.ps1"

Require-File -File "$Bin\ffprobe.exe" -Message "ffmpeg not installed."
Require-File -File "$Bin\ffmpeg.exe" -Message "ffmpeg not installed."

if(-not $Source -Or (-not $(Test-Path $Source))) {
  $Source = Prompt-File -Title  "Choose Video" -Filter 'MP4 (*.mp4)|*.mp4|QuickTime (*.mov)|*.mov|AVI (*.avi)|*.avi'
}

if(-not $Config -Or (-not $(Test-Path $Config))) {
  $Config = Prompt-File -Title  "Choose Settings File" -Filter 'INI File (*.ini)|*.ini|Text File (*.txt)|*.txt'
}

Require-File -File $Config -Message  'No Configuration file provided. Giving Up.'
Require-File -File $Source -Message  'No Video Source file provided. Giving Up.'

$settings = @{}
$settings = Parse-IniFile -File $PSScriptRoot\defaults.ini -Init $settings
$settings = Parse-IniFile -File $Config -Init $settings


echo $Source
echo $(Get-OutputFile $Source)
exit


$width = Find-Dimen -File $Source -What width
$height = Find-Dimen -File $Source -What height

echo "$width x $height"

