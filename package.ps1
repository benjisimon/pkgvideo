##
## Script to package up videos using ffmpeg
##
param($Source, $Config)

Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

function Prompt-File {
  param($Title, $Filter)
  
  $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    Title = $Title
    Filter = $Filter
  }
  $null = $FileBrowser.ShowDialog()

  Return $FileBrowser.FileName
}

Function Parse-IniFile {
  param($file,$init)
  $ini = $init

  # Create a default section if none exist in the file. Like a java prop file.
  $section = "NO_SECTION"
  if(-Not $ini.ContainsKey($section)) {
    $ini[$section] = @{}
  }


  switch -regex -file $file {
    "^\[(.+)\]$" {
      $section = $matches[1].Trim()
      if(-Not $ini.ContainsKey($section)) {
	$ini[$section] = @{}
      }
    }
    "^\s*([^#].+?)\s*=\s*(.*)" {
      $name,$value = $matches[1..2]
      # skip comments that start with semicolon:
      if (!($name.StartsWith(";"))) {
        $ini[$section][$name] = $value.Trim()
      }
    }
  }
  $ini
}

if(-not $Source -Or (-not $(Test-Path $Source))) {
  $Source = Prompt-File -Title  "Choose Video" -Filter 'MP4 (*.mp4)|*.mp4|QuickTime (*.mov)|*.mov|AVI (*.avi)|*.avi'
}

if(-not $Config -Or (-not $(Test-Path $Config))) {
  $Config = Prompt-File -Title  "Choose Settings File" -Filter 'INI File (*.ini)|*.ini|Text File (*.txt)|*.txt'
}

if(-not $Config -Or (-not $(Test-Path $Config))) {
  [System.Windows.MessageBox]::Show('No Configuration file provided. Giving Up.')
  exit
}

if(-not $Source -Or (-not $(Test-Path $Source))) {
  [System.Windows.MessageBox]::Show('No Source Video file provided. Giving Up.')
  exit
}

$settings = @{}
$settings = Parse-IniFile -File $PSScriptRoot\defaults.ini -Init $settings
$settings = Parse-IniFile -File $Config -Init $settings

[System.Windows.MessageBox]::Show("Now I'd process $Source")
