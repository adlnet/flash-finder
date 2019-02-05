## Flash Finder Scripts
Set of scripts intended to help determine the severity of Flash Deprecation on a training corpus.  Additional scripts will be added over time.  

These are **PowerShell** scripts for locating Flash-based content on a local machine.  

### Getting Started
As these scripts reference each other, you should either **clone this repository** or **download it as a zip file**.

To run them, you will need a PowerShell terminal active.  To do this, either:
- <kbd>Ctrl</kbd>+<kbd>R</kbd> and type `powershell`, or
- <kbd>Shift</kbd>+<kbd>Right-Click</kbd> and select `Open PowerShell window here`

### What's in the box?
The current scripts will tackle two problems:
- How much of my SCORM content depends on Flash
- How many (and what kind of) SWF files do I have sitting on my machine

### Example
We'll start with an example before diving into too many details.  Suppose you:
- have zipped SCORM modules on a Windows machine,
- want to know how many of these modules depend on Flash, and
- want to check for everything in some folder at `E:\SCORM`

### Getting Everything
To check for SWF content embedded in zipped SCORM modules and SWF files sitting in a file system, the `find.ps1` script will run two scripts outlined below: `find-in-scorm.ps1` and `find-swf.ps1`.  These 

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
