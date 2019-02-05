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

## How to use
As the PowerShell syntax might seem a bit odd, we'll start with an example.

### Example 
Suppose you:
- have zipped SCORM modules on a Windows machine,
- want to know how many of these modules depend on Flash, and
- want to check for everything in some folder at `E:\SCORM`

You would browse to wherever you saved these scripts, open a PowerShell terminal, and type:
```
PowerShell -File find.ps1 -Path "E:\SCORM"
```

Note: If PowerShell complains about your "Execution Policy", then you can bypass that with an argument:
```
PowerShell -File find.ps1 -Path "E:\SCORM" -ExecutionPolicy Bypass
```

The window will then describe what files it's finding and eventually produce two CSV files:
- *scorm-breakdown.csv*, describing the quantity of Flash content within a SCORM module
- *swf-locations.csv*, describing any SWF files it encountered in its search

### Example with Filtering
Suppose now that you want to filter for only SCORM and SWF content contained in specific paths and that our files looked like:
```
  - E:
    - SCORM
      - Courses
        - final_t1
          -Courseware
            - course.zip
        - testing_t2
          -Courseware
            - course.zip
        - demo_t2
          -Courseware
            - course.zip
    - Others
      - Testing
        - course.zip
```
You can filter for a matching path by using the `-filter` argument.  If we only wanted to check those modules with paths resembling `final_*\Courseware`, we could use:
```
PowerShell -File find.ps1 -Path "E:\SCORM" -Filter "\\final_.*\\Courseware"
```

### Running things individually
While the `find.ps1` script runs the `find-swf.ps1` and `find-in-scorm.ps1` files by default, you can run either of those individually with the same syntax:
```
PowerShell -File find-in-scorm.ps1 -Path "E:\SCORM" -Filter "\\final_.*\\Courseware"
```

## Data Format
Each script will produce a different CSV summarizing the information it encountered during execution.

### SWF Information
As the `find-swf.ps1` script checks plain SWF files sitting in a directory, it can read the SWF headers to deduce more granular information about those files.  These CSVs include:
- SWF Name
- Flash Version
- Flash Compression Status
- Creation Time
- Last Write Time
- Full Path of the SWF File

### SCORM Information
The `find-in-scorm.ps1` script checks zip files and tries to determine whether or not they are zipped SCORM modules.  These CSVs include information about the quantity of SWF content within those modules:
- Course Name
- Course Iteration
- Package Name
- Authoring Tool
- Content Type
- Total Files
- Total SWF Files
- SWF Percentage of Total Files
- Creation Time
- Last Write Time
- Full Path of the Zip File
