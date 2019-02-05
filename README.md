# Flash Finder Scripts
Set of scripts intended to help determine the severity of Flash Deprecation on a training corpus.  Additional scripts will be added over time.  

## Find SCORM Content: `find.ps1`
This is a **PowerShell** script for locating Flash-based SCORM content on a local machine.  

To run this script, you will need a PowerShell terminal active.  To do this, either:
- <kbd>Ctrl</kbd>+<kbd>R</kbd> and type `powershell`, or
- <kbd>Shift</kbd>+<kbd>Right-Click</kbd> and select `Open PowerShell window here`

### How to use
Before going into detail, a typical usage would be:
```
PowerShell -File find.ps1 -Path "\some\scorm\path"
```
Note: If PowerShell complains about your "Execution Policy", then you can bypass that with an argument:
```
PowerShell -File find.ps1 -Path "\some\scorm\path" -ExecutionPolicy Bypass
```
Note that the `-Path` argument is optional -- this will default to your execution path if omitted (`.\*`).

### What's going on?
This script will search a given directory, printing the locations of SCORM content in all sub-folders and writing the results to a CSV file.  Those columns will be inferred and not always available:
- Course Name
- Course Iteration
- Package Name
- Authoring Tool
- Content Type
- Count of ALL Files
- Count of SWF Files
- SWF File Percentage
- Creation Time
- Last Updated
- Full Path
