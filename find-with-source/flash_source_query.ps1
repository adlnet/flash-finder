################################################################################
# FLASH SOURCE FILE QUERY v1.0
# - - - - - - - - -
# The script analyzes the contents of a specified directory, including any ZIP 
# archives, and lists how many Flash source files (FLA, FLV, AS, SWC and SWT) 
# it finds to help users easily determine if a set of courseware source files 
# contain Flash source files that can be used to re-develop content.
#
# The script is primarily intended for use on distributed learning courseware 
# source files.
#
# For more info visit: https://github.com/TADLP/flash-source-query
################################################################################

# Include Windows filesystem .NET core
Add-Type -assembly "System.IO.Compression.Filesystem"

# Variables
$flaCount = 0;
$flvCount = 0;
$asCount = 0;
$swcCount = 0;
$swtCount = 0;
$otherCount = 0;
$totalCount = 0;

$flaFiles = @();
$flvFiles = @();
$asFiles = @();
$swcFiles = @();
$swtFiles = @();
$otherFiles = @();

$showOtherFiles = $false;


Write-Host "`nFlash Source File Query started. Press CTRL + C at any time to exit."

$searchDir = Read-Host -Prompt "[INPUT] Enter the path to directory to search (default current directory)"

# Check to see if the user entered anything. If not, use the current directory.
if ($searchDir.Length -eq 0) { 
	$searchDir = Get-Location 
} else {
	# If the user entered a path with a trailing backslash, remove it.
	if($searchDir.SubString($searchDir.length-1) -eq "\") {
		$searchDir = $searchDir.SubString(0,$searchDir.length-1);
	}
}

# Check to see if the specified path exists. If it doesn't, prompt the user for input once more.
if (Test-Path $searchDir) {
	Write-Host "`nDirectory found: $searchDir ..."
	# If the path does exist, prompt the user to choose if the output should list all non-Flash files.
	$showOther = Read-Host -Prompt "[INPUT] List non-Flash files in output? This may increase the script's run-time (Y/N; default N)"

	switch ($showOther) {
		Y { $showOtherFiles = $true; break; }
		N { continue }
		Default { continue }
	}

	# Gather a list of all files in the specified path.
	$fileList = Get-ChildItem $searchDir -r;
} else {
	Write-Host "`nThe specified directory doesn't exist. Please try again."

	$searchDir = Read-Host -Prompt "[INPUT] Enter the path to directory to search"

	# If the user entered a path with a trailing backslash, remove it.
	if ($searchDir.SubString($searchDir.length-1) -eq "\") {
		$searchDir = $searchDir.SubString(0,$searchDir.length-1);
	}
}
# Function: countFile
# Params: file = a file object, zip (optional) = a zip file object
# The function takes a specified file object and analyzes its extension to see if
# the file is a Flash source file. If a zip object is given with the file, the file
# gets listed as belonging to the zip file in the output.
function countFile($file, $zip) {
	$fileExt = [System.IO.Path]::GetExtension($file);

	# Look for Flash source files: FLA, FLV, AS, SWC and SWT. Any other file is "other".
	# Remove the search directory path to give relative paths, and replace forward
	# slashes with backward ones (with zip files) for uniformity.
	switch ($fileExt) {
		"" {
			break;
		}

		".fla" { 
			$Script:flaCount++;
			if ($zip) {
				$Script:flaFiles += "[" + $zip.FullName.Replace($searchDir.ToString() + "\", "") + "] " + $file.FullName.Replace("/","\");
			} Else {
				$Script:flaFiles += $file.FullName.Replace($searchDir.ToString() + "\", "")
			}
			break;
		}

		".flv" { 
			$Script:flvCount++;
			if ($zip) {
				$Script:flvFiles += "[" + $zip.FullName.Replace($searchDir.ToString() + "\", "") + "] " + $file.FullName.Replace("/","\");
			} Else {
				$Script:flvFiles += $file.FullName.Replace($searchDir.ToString() + "\", "")
			}
			break;
		}

		".as"  { 
			$Script:asCount++;
			if ($zip) {
				$Script:asFiles += "[" + $zip.FullName.Replace($searchDir.ToString() + "\", "") + "] " + $file.FullName.Replace("/","\");
			} Else {
				$Script:asFiles += $file.FullName.Replace($searchDir.ToString() + "\", "")
			}
			break;
		}

		".swc" { 
			$Script:swcCount++;
			if ($zip) {
				$Script:swcFiles += "[" + $zip.FullName.Replace($searchDir.ToString() + "\", "") + "] " + $file.FullName.Replace("/","\");
			} Else {
				$Script:swcFiles += $file.FullName.Replace($searchDir.ToString() + "\", "")
			}
			break;
		}

		".swt" { 
			$Script:swtCount++;
			if ($zip) {
				$Script:swtFiles += "[" + $zip.FullName.Replace($searchDir.ToString() + "\", "") + "] " + $file.FullName.Replace("/","\");
			} Else {
				$Script:swtFiles += $file.FullName.Replace($searchDir.ToString() + "\", "")
			}
			break;
		}

		Default { 
			$Script:otherCount++;
			if ($zip) {
				$Script:otherFiles += "[" + $zip.FullName.Replace($searchDir.ToString() + "\", "") + "] " + $file.FullName.Replace("/","\");
			} Else {
				$Script:otherFiles += $file.FullName.Replace($searchDir.ToString() + "\", "")
			}
		}
	}
}

Write-Host "`nAnalyzing contents of $searchDir ..."

# For each file found in the specified search directory, send it to the countFile function. If the file is
# a zip archive, look at all the file entries for it and send them to the countFile function with the zip.
ForEach ($file in $fileList) {
	if($file.Name -match "\.zip$") {
		Write-Host "Analyzing ZIP file contents:" $file.FullName.Replace($searchDir.ToString() + "\", "") "...";
		$myZip = [IO.Compression.ZipFile]::OpenRead($file.FullName);
		
		ForEach ($zipFile in $myZip.Entries) {
			if($zipFile.Name.length -gt 4) {
				countFile $zipFile $file;
			}
		}

		$myZip.Dispose();
	} Else {
		if($file.Name.length -gt 4) {
			countFile $file;
		}
	}
}

# Construct the output that will be written to text file.
Write-Host "`nGenerating log file ..."
$totalCount = $flaCount + $flvCount + $asCount +$swcCount + $swtCount + $otherCount;
$theDate = Get-Date
$spacer = "-------------------------------";

$dataToWrite = "";

# Output header
$dataToWrite += "Results for $searchDir
Generated on $theDate
$spacer
TOTAL FILES: $totalCount`n"

if ($totalCount -gt 0) {
	$dataToWrite += "FLA files: $flaCount ($(($flaCount / $totalCount).tostring("P")))
FLV files: $flvCount ($(($flvCount / $totalCount).tostring("P")))
AS files: $asCount ($(($asCount / $totalCount).tostring("P")))
SWC files: $swcCount ($(($swcCount / $totalCount).tostring("P")))
SWT files: $swtCount ($(($swtCount / $totalCount).tostring("P")))
Other files: $otherCount ($(($otherCount / $totalCount).tostring("P")))`n"
} else {
	$dataToWrite += "No files found."
}

# List of FLA files
$dataToWrite +=  "`n$spacer
FLA files ($flaCount of $totalCount)
$spacer`n";

if ($flaCount -gt 0) 
{
	$i = 0;
	ForEach ($entry in $flaFiles) {
		$i++
		$dataToWrite +=  "$i. $entry`n"
	}
} Else {
	$dataToWrite +=  "None`n"
}

# List of FLV files
$dataToWrite += "`n$spacer
FLV files ($flvCount of $totalCount)
$spacer`n";

if ($flvCount -gt 0) 
{
	$i = 0;
	ForEach ($entry in $flvFiles) {
		$i++
		$dataToWrite += "$i. $entry`n"
	}
} Else {
	$dataToWrite += "None`n"
}

# List of AS files
$dataToWrite += "`n$spacer
AS files ($asCount of $totalCount)
$spacer`n";

if ($asCount -gt 0) 
{
	$i = 0;
	ForEach ($entry in $asFiles) {
		$i++
		$dataToWrite += "$i. $entry`n"
	}
} Else {
	$dataToWrite += "None`n"
}

# List of SWC files
$dataToWrite += "`n$spacer
SWC files ($swcCount of $totalCount)
$spacer`n";

if ($swcCount -gt 0) 
{
	$i = 0;
	ForEach ($entry in $swcFiles) {
		$i++
		$dataToWrite += "$i. $entry`n"
	}
} Else {
	$dataToWrite += "None`n"
}

# List of SWT files
$dataToWrite += "`n$spacer
SWT files ($swtCount of $totalCount)
$spacer`n";

if ($swtCount -gt 0) 
{
	$i = 0;
	ForEach ($entry in $swtFiles) {
		$i++
		$dataToWrite += "$i. $entry`n"
	}
} else {
	$dataToWrite += "None`n"
}

# List of Other files
$dataToWrite += "`n$spacer
Other files ($otherCount of $totalCount)
$spacer`n";

# If the user chose to list all other files, list them.
# Otherwise, display the not listed message.
if ($showOtherFiles) {
	if ($otherCount -gt 0) 
	{
		$i = 0;
		ForEach ($entry in $otherFiles) {
			$i++
			$dataToWrite += "$i. $entry`n"
		}
	} else {
		$dataToWrite += "None`n"
	}
} else {
	$dataToWrite += "Non-Flash files not listed."
}

# Generate a timestamp for the output text file and save it to the same
# directory as the script (e.g. flash_source_201907300946.txt).
$outputTimestamp = Get-Date -format "yyyMMddHHmm"
$outputFilename = "flash_source_$outputTimestamp.txt"
$dataToWrite | Out-File -FilePath $outputFilename -Encoding ASCII

Write-Host "`nQuery complete." ($flaCount + $flvCount + $asCount +$swcCount + $swtCount) "Flash source files found. Results saved to: $outputFilename"