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

	# Where to save our results
	[string]$outscorm = ".\scorm-breakdown.csv",
	[string]$outswf = ".\swf-locations.csv",

	# We might only be interested in flash content found in certain folders
	#
	# Note that this is 
	[string]$filter = ""
)

# Add the wildcard if necessary
if ($false -eq $path.Contains("*")) {
	$path = $path + "*"
}

# *******************************************************************************
# 	Plain SWF Files
#
#	This block will find SWF files sitting anywhere in the target directory.
# *******************************************************************************
$swf = $PSScriptRoot + "\find-swf.ps1"
&$swf -path $path -out $outswf -filter $filter

# *******************************************************************************
# 	SCORM SWF Files
#
#	This block will search for zip files in each child directory of our path,
#	checking to see if any of those seem to be SCORM modules.  Once that seems
#	to be the case, it will 
# *******************************************************************************
$scorm = $PSScriptRoot + "\find-in-scorm.ps1"
&$scorm -path $path -out $outscorm -filter $filter