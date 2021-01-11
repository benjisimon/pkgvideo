##
## Video utilities
##

Function Find-Dimen {
  param($file,$what);

  Invoke-Expression "$Bin\ffprobe -show_streams $Source" 2> $null | Select-String -Pattern "^$what=" | ForEach-Object {
    $_ -replace "$what=", ""
  }
}

Function Get-OutputFile($File) {
  return $(Get-Item $File).DirectoryName + "\" + $(Get-Item $File).Basename + "-Packaged.mp4"
}
