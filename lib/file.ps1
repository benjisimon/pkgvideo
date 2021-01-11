##
## File utilities
##

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

function Require-File {
  param($File, $Message);

  if(-not $File -Or (-not $(Test-Path $File))) {
    [System.Windows.MessageBox]::Show($Message)
    exit
  }
}
