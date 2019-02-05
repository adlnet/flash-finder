# *******************************************************************************
# 	Flash Query
#
#	This is a PowerShell script intended to locate zipped SCORM content packaged 
#	with a traditional imsmanifest.xml file.
#
#	This script can accept a few arguments.  By default, the script will check 
#	the execution path and then every sub-folder recursively.  The results will
#	be printed to a CSV file in the execution directory.
# *******************************************************************************
param (
	# The "path" var is the directory in which to search all subdirs, each respresenting a course.
    [string]$path = ".\*",

	# The "outputfile" var is the full path to the CSV file to which the script will write its results.
	[string]$out = ".\swf-locations.csv",
	
	# Regex filter, check the README or find.ps1 for more information
	[string]$filter = ".*"
)

$describe = $PSScriptRoot+"\describe-swf.ps1"
$PlainSWF = New-Object System.Collections.Generic.List[System.Object]

# Add the wildcard if necessary
if ($false -eq $path.Contains("*")) {
	$path = $path + "*"
}

Write-Host "`nChecking for SWF files ...`n"

# Filter for every SWF file in the given path, including sub-folders
$allFolders = New-Object System.Collections.Generic.List[System.Object]
$subFolders = Get-ChildItem $path  -Recurse -Attributes d | Sort-Object -Property name -Descending

# Check if they only specified one folder
if (Test-Path $path -PathType Container) {
	$current = Get-Item $path
	$allFolders.Add($current);
}
ForEach ($sub in $subFolders) {
	$allFolders.add($sub)
}

# Iterate over each SWF file to see if it follows our parent filter
ForEach($folder in $allFolders) {

	# Make sure we only search in the designated folders
	if ($folder.FullName -notmatch $filter) {
		continue
	}
	if ($folder.Name -match "CD_ROM") {
		continue
	}

	$swfs = Get-ChildItem $folder.FullName -Filter *.swf

	ForEach($swf in $swfs) {

		# Check version and compression from our helper script
		$version, $compression = &$describe -path $swf.FullName

		if ("0" -eq $version) {
			continue
		}

		$PlainSWF.Add([pscustomobject]@{
			SWF = $swf.Name.Replace(",", "")
			FlashVersion = $version
			CompressionStatus = $compression
			CreationTime = $swf.CreationTime
			LastWrite = $swf.LastWriteTime
			FullPath = $swf.FullName
		});
		Write-Host "[adding]: $($swf.FullName)"
	}
}

#Export everything
Write-Host "`nExporting $($PlainSWF.Length) results to $($out)`n"
$PlainSWF | Export-Csv $out
