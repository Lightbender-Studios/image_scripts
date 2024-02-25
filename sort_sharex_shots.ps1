<#

.SYNOPSIS
    This script organizes files into directories based on the unique names extracted from the file names.
    This script was created to sort ShareX screenshots into directories based on the unique names of the
    files.

.DESCRIPTION
    This script scans a directory for files and organizes them into separate directories based on the unique
    names extracted from the file names. Each directory is named after a unique name extracted from the 
    beginning of the file names before the first underscore.  For example, if the directory contains files
    named "John_Doe_001.png", "John_Doe_002.png", "Jane_Doe_001.png", and "Jane_Doe_002.png", the script
    will create two directories named "John" and "Jane" and move the files into the appropriate directories.

    The script takes an optional parameter to specify the path of the directory containing the files to be
    organized. If the parameter is not provided, the current directory is used. The script outputs the unique
    names and the number of files moved to each directory, as well as the total number of directories created
    and the total number of files moved.

.PARAMETER directoryPath
    Specifies the path of the directory containing the files to be organized. If not provided, the current
    directory is used.

.NOTES
    Author: Kevin Vidomski
    Date: 25-02-2023
    Version: 1.0
    
.EXAMPLE
    .\OrganizeFiles.ps1 -directoryPath "C:\Path\To\Your\Directory"
    Organizes the files in the specified directory into separate directories based on unique names.

#>

param(
    [string]$directoryPath = (Get-Location)
)

# Get a list of image files in the directory
$imageFiles = Get-ChildItem -Path $directoryPath -File | Where-Object { $_.Extension -match '\.jpg$|\.jpeg$|\.png$|\.gif$|\.bmp$' }

# Initialize variables to count directories and files moved
$directoryCount = 0
$fileCount = 0

# Iterate through each image file
foreach ($imageFile in $imageFiles) {
    # Extract the name of the file
    $fileName = $imageFile.Name
    
    # Extract the part of the name before the last underscore
    $nameBeforeLastUnderscore = $fileName -replace '^(.*)_.*\.(jpg|jpeg|png|gif|bmp)$', '$1'

    # Create a directory for the extracted name within the specified directory
    $newDirectoryPath = Join-Path -Path $directoryPath -ChildPath $nameBeforeLastUnderscore
    if (-not (Test-Path -Path $newDirectoryPath)) {
        New-Item -ItemType Directory -Path $newDirectoryPath -ErrorAction SilentlyContinue
        $directoryCount++
    }
    
    # Construct the new file name
    $newFileName = $nameBeforeLastUnderscore + $imageFile.Extension
    
    # Move the image file to the appropriate directory with the new name
    $destinationFilePath = Join-Path -Path $newDirectoryPath -ChildPath $newFileName
    Move-Item -Path $imageFile.FullName -Destination $destinationFilePath -Force
    $fileCount++
}

# Output the unique names and stats
foreach ($name in $uniqueNames) {
    $directory = Join-Path -Path $directoryPath -ChildPath $name
    $fileCountInDirectory = (Get-ChildItem -Path $directory -File).Count
    Write-Output "$name $fileCountInDirectory"
}

# Output total stats
Write-Output "Total directories created: $directoryCount"
Write-Output "Total image files moved: $fileCount"
