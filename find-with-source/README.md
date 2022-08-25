# Flash Source File Query v1.0
A Windows PowerShell script that analyzes the contents of a specified directory and lists how many Flash source files (FLA, FLV, AS, SWC and SWT) it finds. The script is intended primarily for use with courseware source files to help the user determine if the source files actually include Flash source files that can be used to re-develop content.

📥 [Download PowerShell script](https://github.com/adlnet/flash-finder/tree/master/find-with-source)

## Instructions
The instructions below explain how to open the script, use it correctly, and read the output.

### Gathering Source Files
Before running the script, it is highly recommended that you gather all the source files in one location. For the most accurate results, create one directory per course and run the script on each course directory.

### Opening the Script
1. Place the `flash_source_query.ps1` file on your computer
2. Open the **Command Prompt** or **Windows PowerShell**
3. Navigate to the location of the script.
4. Run the script using the appropriate command:

* For **Command Prompt**, run: `powershell .\flash_source_query`. 

* For **PowerShell**, run: `.\flash_source_query`.

*Note:* Advanced users can specify the full path to the script to skip step 3 above.

### Using the Script
When running the script, it will ask you to specify a directory to search in. Enter the full path to the directory you want to search. Example: `C:\courseware\Flash`

After you enter a valid path, the script will then ask you if you want it to list all non-Flash files in the output. Enter either `Y` or `N` to indicate your choice. Source file sets can have many different file types in them, and if you are only interested in identifying source files specific to Flash, you can save time by indicating no. No is the default choice.

The script will then run. This may take a while depending on how many files it has to look through, and the speed of your computer.

### Reading the Output
When the script is finished running, it will save a text file with a timestamp in the filename to the same directory as the script. Example: `flash_source_201907301013.txt`

The text file will display statistics on the files found, and list the relative path for every Flash source file identified, e.g. `layout.fla`. If a file was found inside a ZIP archive, the ZIP archive name will be listed in square brackets, e.g. `[course.zip] main.fla`.

Generally speaking, if the query identifies a large number of Flash source files, the source file set is likely to contain the files needed to redevelop content.

*Note:* This script does not specifically look for multimedia source files (audio, non-Flash video, imagery) that would also be required to redevelop content.

#### Sample Output
```
Results for C:\courseware\Flash
Generated on 07/30/2019 10:36:54
-------------------------------
TOTAL FILES: 156
FLA files: 8 (5.13%)
FLV files: 1 (0.64%)
AS files: 0 (0.00%)
SWC files: 0 (0.00%)
SWT files: 0 (0.00%)
Other files: 147 (94.23%)

-------------------------------
FLA files (8 of 156)
-------------------------------
1. [course.zip] acms_01.fla
2. [course.zip] acms_01_HTML5 Canvas.fla
3. flash_test\acms_01.fla
4. flash_test\acms_01_HTML5 Canvas.fla
5. [flash_test\course.zip] acms_01.fla
6. [flash_test\course.zip] acms_01_HTML5 Canvas.fla
7. [flash_test\src\flash_test.zip] acms_01.fla
8. [flash_test\src\flash_test.zip] acms_01_HTML5 Canvas.fla

-------------------------------
FLV files (1 of 156)
-------------------------------
1. [flash_test\src\flash_test.zip] src\acms_01.flv

-------------------------------
AS files (0 of 156)
-------------------------------
None

-------------------------------
SWC files (0 of 156)
-------------------------------
None

-------------------------------
SWT files (0 of 156)
-------------------------------
None

-------------------------------
Other files (147 of 156)
-------------------------------
1. acms_01\bin\SymDepend.cache
2. acms_01\bin\zjbhwiy3qc.swf
3. acms_01\LIBRARY\acms_01.wav
...
```
