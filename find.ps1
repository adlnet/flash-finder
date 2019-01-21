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
	[string]$out = ".\output.csv",

	# We might only be interested in flash content found in certain folders
	[string]$parentfilter = ".+"
)

# We're dealing with zip files, so we'll need to unzip and dispose of them
Add-Type -assembly "System.IO.Compression.FileSystem"

# The "folders" var is an object containing the path of all subdirs in the top directory
Write-Output "`nGetting all folders for pattern $($path) ..."

$folders = gci $path -Recurse -Attributes d | Sort-Object -Property name -Descending

# Go into each course folder
$Result = ForEach($folder in $folders) {

	# Make sure we only search in the designated folders
	if ($folder.Name -notmatch $parentfilter) {
		continue
	}
	if ($folder.Name -Match "CD_ROM") {
		continue
	}
	
	$zipPaths = gci $folder *.zip

	# Skip if we didn't find anything
	if ($zipPaths.count -eq 0) {
		continue
	}

	# Find which iteration of course material this is.  This will assume the 
	# original directory structure and may not be even be applicable for your
	# situation, but we wanted to provide it regardless
	#
	$iterPath = $folder
	$iteration = $null
	
    while ($null -ne $iterPath) {
        if ("Courseware" -eq $iterPath.Name) {
            $iteration = $iterPath.parent
            break
        }
        $iterPath = $iterPath.parent
	}
	if ($null -eq $iteration) {
		$iteration = "Unknown"
	}

	Write-Host "`n$($folder.FullName)"
	
	# Open each zip
	ForEach($zipPath in $zipPaths) {
	
		# Check if this is an assessment
		if( $zipPath.Name.ToLower().Contains("assessment") `
			-or $zipPath.Name.ToLower().Contains("pretest") `
			-or $zipPath.Name.ToLower().Contains("posttest") `
			-or $zipPath.Name.ToLower().Contains("postest") `
			-or $zipPath.Name.ToLower().Contains("exam") `
			-or $zipPath.Name.ToLower().Contains("test") `
			-or $zipPath.Name.ToLower().Contains("assess_") `
			-or $zipPath.Name.ToLower().Contains("pre_") `
			-or $zipPath.Name.ToLower().Contains("post_") ) 
		{
			$contentType = "Assessment"
		} else {
			$contentType = "Lesson"
		}
		
		# Make sure this is a valid archive
		try {
			$zip = [IO.Compression.ZipFile]::OpenRead($zipPath.FullName)
		} catch {
			Write-Host "  -[failed]: $($zipPath.Name)"
			continue
		}
		$flash = $false

		# Make sure we find a manifest indicating that this is a Flash project
		ForEach($thing in $zip.Entries) {
			if ($thing.Name -eq "imsmanifest.xml") {
				$flash = $true
				break
			}
		}
		if ($flash -eq $false) {
			Write-Host "  -[ignore]: $($zipPath.Name)"
			continue
		}

		# count number of .swf files and detect authoring tools
		$swfCount = 0
		$tool = "Other"
		$fileList = $zip.Entries

		foreach($file in $fileList) {
		
			if($file.FullName -match "\.swf$") {
				$swfCount++
			}
			
			# Detect authoring tool through unique files
			switch -regex ($file.FullName) {
				"captivate.css" { $tool = "Captivate"; break }
				"CPM.js" { $tool = "Captivate"; break }
				"SCORM_API_DIF.js" { $tool = "ECDC"; break }
				"isplayer.js" { $tool = "iSpring"; break }
				"trivantis.css" { $tool = "Lectora"; break }
				"story_content" { $tool = "Storyline"; break }
				"quizmaker" { $tool = "Presenter"; break }
				"saba_scorm.js" { $tool = "Saba"; break }
			}
			
			if($swfCount -gt 0) {
				$flashPercent = ($swfCount / $fileList.Count).ToString("P")
			} else {
				$flashPercent = "0 %"
			}		
		}
		
		$zip.Dispose()
		
		# * Per-PIF CSV: CourseName, CourseIteration, Authoring Tool, Total Files, Total Flash, Percentage Flash
		[pscustomobject]@{
			CourseName = $folder.Name.Replace(",", "")
			CourseIteration = $iteration
			PackageName = $zipPath.Name.Replace(",", "")
			AuthoringTool = $tool
			ContentType = $contentType
			TotalFiles = $fileList.Count
			TotalFlash = $swfCount
			FlashPercent = $flashPercent
			CreationTime = $zipPath.CreationTime
			LastWrite = $zipPath.LastWriteTime
		}
		Write-Host "  -[adding]: $($zipPath.Name)"
	}
}

#Export everything
Write-Host "`nExporting results to $(Resolve-Path $out)`n"
$Result | Export-Csv $out
