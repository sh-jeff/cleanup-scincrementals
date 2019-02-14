<#
.SYNOPSIS
    Delete consolidated image files from Imagemanager's Incrementals folder
.DESCRIPTION
    Systems that receive Storagecraft images, either through FTP or
    Shadowstream can collect a large amount of consolidated images. This script
    will clean them up with a configurable amount of time.

    Default retention time is 60 days.
.PARAMETER Path
    Location of the backup store. It will search for a folder named 
    "Incrementals" in this folder.
.PARAMETER RetentionDays
    Number of days from current date to keep. Everything before this will be
    removed.
.PARAMETER DryRun
    Only report what will be removed. Defaults to "True"
.PARAMETER Silent
    Supress Output. Defaults to "False"
.EXAMPLE
    .\Cleanup-SCIncrementals -BackupPath "D:\Backups\SERVER" -RetentionDays 30
    Report on all images that are older than 30 days.

    .\Cleanup-SCIncrementals -BackupPath "D:\Backups\Server" -DryRun $false
    Report and delete all images that are older than 60 days.
#>
#requires -Version 5.1

Param(
    [Parameter(ValueFromPipeline)]
    [string[]]$BackupPath = ".\",
    [string]$RetentionDays = "60",
    [bool]$DryRun = $true,
    [switch]$Silent = $false
)

Function CollectFiles {
    # Get our .SPI files. ---TODO: Also clean up related files
    $Files = (
        Get-ChildItem $BackupPath\Incrementals -Filter "*.SPI" | 
        Sort-Object -Property LastWriteTime
    )

    # Check if there are files to clean up
    # Get the oldest file in the folder
    $OldestFile = ( $Files | Select-Object -First 1 )
    if (
        # We don't need to do anything if the oldest file is not at
        # least $RetentionDays old
        $OldestFile.LastWriteTime -gt (Get-Date).AddDays(-$RetentionDays)
    ) {
        Return "No files to clean up"
    }
    # Get the LastWriteTime of the newest file.
    $NewestFile = ( $Files | Select-Object -Last 1 )

    # Check if each file is more than $RetentionDays older than
    # the newest file
    $cleanuplist = @()
    foreach ( $file in $Files ) {
        if (
            ($NewestFile.LastWriteTime - $file.LastWriteTime).Days -ge $RetentionDays
        ) {
				# If the file does fall within $RetentionDays, get all of the 
				# files with the same name (without extension).
                $file_base = $file -replace "\.[^\.]+$"
                $cleanup_file = gci $BackupPath\Incrementals -Filter $file_base*
                $cleanuplist += $cleanup_file.FullName
        }
    }
    # Return the files to clean up.
    Return $cleanuplist
}

# Call our function
$incrementals = CollectFiles
if (
    $incrementals -eq "No files to clean up"
) {
    if (
        $Silent -eq $false
    ) {
        Write-Host $incrementals
        Break
    }
    else {
        Break
    }
  }


#Check if we are deleting anything.
if (
    $DryRun -eq $true
) {
    if (
        $Silent -eq $false
    ) {
        Write-Host "Listing files to clean up"
        Write-Host $incrementals
    }
}

#Finally delete them
else {
    if (
        $Silent -eq $false
    ) {
        Write-Host "Deleting files"
        Write-Host $incrementals
        Remove-Item $incrementals
    }
    else {
        Remove-Item $incrementals
    }
}