<#  Written by:     daniha
    Last update:    10/11/2019
#>

# Location and exclution vars
# Paths var can be all locations you want to search in
# Excludes var is all folder names you'd like to be excluded from the output 
[string[]]$arrPaths = @('C:\CPubGit\microsoft-365-docs-pr\microsoft-365\security')
[string[]]$arrExcludes = @()

# Init output array
[string[]]$arrFilesOutput = @()

# Special enumeration that will exclude anything that matches the excludes array in it's path file name not included
$arrFolders = Get-ChildItem $arrPaths -Directory -Recurse -Exclude $arrExcludes | %{ 
    $allowed = $true
    foreach ($exclude in $arrExcludes) { 
        if ((Split-Path $_.FullName -Parent) -match $exclude) { 
            $allowed = $false
            break
        }
    }
    if ($allowed) {
        $_
    }
}

# Loop through all enumerated folders and add their md files into the output array
foreach ($folder in $arrFolders) {
   $files = Get-ChildItem ($folder.FullName + "\*") -Include *.md
   $arrFilesOutput += $files.FullName
}

# Formatting output array to have URLs
$arrFilesOutput = $arrFilesOutput -replace 'C:\\CPubGit\\microsoft-365-docs-pr\\','https://docs.microsoft.com/en-us/'
$arrFilesOutput = $arrFilesOutput -replace '\\','/'
$arrFilesOutput = $arrFilesOutput -replace '.md',''

# Export info to CSV file with the header Names
# Can customize header name or full file path
ConvertFrom-Csv $arrFilesOutput -Header Names | Export-Csv "C:\temp\M365SecurityFiles.csv" -NoTypeInformation