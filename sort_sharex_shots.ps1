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

# Get a list of files in the directory
$files = Get-ChildItem -Path $directoryPath

# Initialize an empty array to store unique names
$uniqueNames = @()

# Initialize variables to count directories and files copied
$directoryCount = 0
$fileCount = 0

# Iterate through each file
foreach ($file in $files) {
    # Extract the name of the file
    $fileName = $file.Name
    
    # Extract the part of the name before the first underscore
    $nameBeforeUnderscore = $fileName -split '_'
    $firstName = $nameBeforeUnderscore[0]

    # Check if the name is not already in the uniqueNames array, then add it
    if ($firstName -notin $uniqueNames) {
        $uniqueNames += $firstName
        
        # Create a directory for the unique name within the specified directory
        $newDirectoryPath = Join-Path -Path $directoryPath -ChildPath $firstName
        New-Item -ItemType Directory -Path $newDirectoryPath -ErrorAction SilentlyContinue
        
        # Increment the count of directories copied
        $directoryCount++
    }
    
    # Copy the file to the appropriate directory within the specified directory
    $destinationDirectory = Join-Path -Path $directoryPath -ChildPath $firstName
    Move-Item -Path $file.FullName -Destination $destinationDirectory
    
    # Increment the count of files moved
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
Write-Output "Total files moved: $fileCount"
