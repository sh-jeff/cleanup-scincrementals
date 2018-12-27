## Purpose
This script is designed to be run as a scheduled task. When called from the
command line, it defaults to listing all files older than 60 days.  
## Usage
To specify a different path (required for a scheduled task) use the -BackupPath
flag. -BackupPath should point to the root of the backup folder (where the 
.SPF files reside). The script expects to find .\Incrementals.  
The -RetentionDays flag specifies the number of days to *keep* from the 
newest .SPI in the folder. It does not currently do anything with the
ancillary files generated by Imagemanager.  
The -DryRun $false switch must be passed in order to actually delete files.  
-Silent is recommended for scheduled task usage.
### Examples
.\Cleanup-SCIncrementals -BackupPath "D:\Shared\Storagecraft\SERVER1"
-RetentionDays "90" -DryRun $false -Silent  
This will delete any SPI files more than 90 days old.
## Setup
WMF 5.1 must be installed. It may work with PoSH versions as low as 3.0, but
this is untested.  
1. Copy script to local disk.
2. Create a new task
   * The task name should be "SCCleanup - Servername"
3. Set trigger to run every two weeks between 0200 and 0600 Sunday or Monday
4. Create a new action. Set to "Start a program"
   * Enter `powershell.exe` as the "Program/script"
   * Enter "-ExecutionPolicy Bypass" followed by the full path to the
   script (EG C:\scripts\cleanup\cleanup-scincrementals.ps1)
   followed by '-BackupPath "D:\Backups\Server" -DryRun $false -Silent'
5. Set "Run wheter user is logged on or not"
6. Click save enter the password for the user account.
7. Repeat for each server. One task per managed folder. It is suggested to 
stagger the start time for each task.
