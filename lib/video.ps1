##
## Video utilities
##

Function Find-Dimen {
  param($file,$what);

  Invoke-Expression "$Bin\ffprobe -show_streams $Source" 2> $null | Select-String -Pattern "^$what=" | ForEach-Object {
    $_ -replace "$what=", ""
  }
}

Function Get-OutputFile {
  param($File)
  return $(Get-Item $File).DirectoryName + "\" + $(Get-Item $File).Basename + "-Packaged.mp4"
}

Function Get-FcsPath {
  return "$PSScriptRoot\..\.fcs.last"
}

Function Get-FontDir {
  $dir = "$PSScriptRoot\..\fonts"
  $dir = $dir -Replace 'c:', ''
  $dir = $dir -Replace "\\","/"
  return $dir
}

Function Generate-FilterComplexScript {
  param($Settings);
  $File = Get-FcsPath
  $S = $Settings
  $FontDir = Get-FontDir
  @"
[1:v]scale=w=$($S.main.image_w):h=$($S.main.image_h)[logo_a] ; 
[2:v]scale=w=$($S.pre.image_w):h=$($S.pre.image_h)[logo_b] ; 
[3:v]scale=w=$($S.post.image_w):h=$($S.post.image_h)[logo_c] ; 
[0:v][logo_a] overlay=$($S.main.image_x):$($S.main.image_yd) [main] ; 
[0:a] adelay=delays=$([int]$S.pre.duration * 1000):all=1  ; 
[main]drawtext=fontfile='$FontDir/$($S.main.caption_font)': 
	       text='$($S.main.caption_text)': 
	       x=$($S.main.caption_x): y=$($S.main.caption_y): 
	       fontsize=$($S.main.caption_font_size): 
	       fontcolor=$($S.main.caption_color): 
               box=1: boxcolor=$($S.main.caption_bg_color) : line_spacing=0: 
               bordercolor=$($S.main.caption_bg_color): borderw=0: boxborderw=$($S.main.caption_padding): 
               enable='between(t,$($S.main.caption_start),$($S.main.caption_end))'[main]; 
[4:v]drawtext=fontfile='$FontDir/$($S.pre.title_font)': 
         text='$($S.pre.title_text)': 
         x='$($S.pre.title_x)': y='$($S.pre.title_y)': 
         fontsize=$($S.pre.title_font_size): 
         fontcolor=$($S.pre.title_color) [pre]; 
[pre]drawtext=fontfile='$FontDir/$($S.pre.subtitle_font)':
         text='$($S.pre.subtitle_text)': 
         x='$($S.pre.subtitle_x)': y='$($S.pre.subtitle_y)': 
         fontsize=$($S.pre.subtitle_font_size): 
         fontcolor=$($S.pre.subtitle_color) [pre]; 
[pre][logo_b] overlay=x='$($S.pre.image_x)':y='$($S.pre.image_y)' [pre] ; 
[5:v]drawtext=fontfile='$FontDir/$($S.post.title_font)': 
     text='$($S.post.title_text)':
     x='$($S.post.title_x)': y='$($S.post.title_y)': 
     fontsize=$($S.post.title_font_size): 
     fontcolor=$($S.post.title_color) [post]; 
[post][logo_c] overlay=x='$($S.post.image_x)':y='$($S.post.image_y)' [post] ; 
[pre][main][post]concat=n=3
"@.Trim() | Out-File -FilePath $File
}

Function Package-Video {
  param($Source, $Settings)
  $Bin = "$PSScriptRoot\..\bin"
  $FcsPath = Get-FcsPath
  $FilterExpr = (Get-Content $FcsPath) -join ' '
  $S = $Settings
  $OutputFile = Get-OutputFile -File $Source

  & "$Bin\ffmpeg" -y `
    -i $Source `
    -i $($S.main.logo) `
    -i $($S.main.logo) `
    -i $($S.main.logo) `
    -f lavfi -i color=color=$($S.pre.bg_color):$($S.main.video_width)x$($S.main.video_height):d=$($S.pre.duration) `
    -f lavfi -i color=color=$($S.post.bg_color):$($S.main.video_width)x$($S.main.video_height):d=$($S.post.duration) `
    -filter_complex "$FilterExpr" `
    -codec:v libx264  -preset medium `
    -vsync 2 `
    $OutputFile
}
