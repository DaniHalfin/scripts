<#  Written by:     daniha
    Last update:    3/26/19
#>

Param(
    # The full path where the script will run
    [Parameter(Mandatory = $true, Position = 0 , HelpMessage = "Enter the full path under which the script should run.")]
    [Alias("Path")]
    #[ValidatePattern("^[a-zA-Z]:\\[\\\S|*\S]?.*$")]
    [String]
    $sFilePathParam,
    # Name of the metadata attribute to change \ add
    [Parameter(Mandatory = $true, Position = 1 , HelpMessage = "Enter the name of the metadata attribute you'd like to add or change the value of.")]
    [Alias("Attribute", "att")]
    [String]
    $sMDAttributeParam,
    # Name of the new value assigned to the metadata attribute
    [Parameter(Mandatory = $true, Position = 2 , HelpMessage = "Enter the new value you'd like to assign to the metadata attribute you've specified.")]
    [Alias("Value", "NewValue")]
    [String]
    $sMDNewValueParam,
    # Name of the new value assigned to the metadata attribute
    [Parameter(Mandatory = $false, Position = 3 , HelpMessage = "Enter the old value you'd like to replace for the metadata attribute you've specified.")]
    [Alias("OldValue")]
    [String]
    $sMDOldValueParam
)

# Recurse through file tree location provided above to find all markdown files
$lRepoFiles = Get-ChildItem -Path $sFilePathParam -File -Filter "*.md" -Recurse

<#
.SYNOPSIS
Parse metadata tags out of file.

.DESCRIPTION
Finds metadata tags based on the formatting we use in markdown and separates into tag name and value.

.PARAMETER filename
Full file path including name and file extension.

.EXAMPLE
Get-Metadata "c:\repo\index.md"
#>
function Get-Metadata ($filename)
{
    $htFileMetadata = [ordered]@{}
    
    $sFileContents = Get-Content -Path $filename
    $nNumOfSeparators = 0

    for ($nLine =0; $nNumOfSeparators -lt 2; $nLine++)
    {
        $sCurrLine = $sFileContents[$nLine]
        if (($sCurrLine -notmatch "-") -and ($nNumOfSeparators -eq 0))
        {
            $htFileMetadata = @{}
            break
        } elseif ($sCurrLine -notmatch "---") {
            $arrParsedLine = $sCurrLine -split "\s*:\s*"
            $htFileMetadata.Add($arrParsedLine[0], $arrParsedLine[1])
        } else { $nNumOfSeparators++ }
    }
    return $htFileMetadata
}

function Check-GitInstalled
{
    try
    {
        git | Out-Null
        return $true
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        return $false
    }
}

foreach ($file in $lRepoFiles)
{
    # Parse file metadata
    $htExtractedMD = Get-Metadata ($file.FullName)

    if ($sMDOldValueParam)
    {
        if ($htExtractedMD[$sMDAttributeParam] -match $sMDOldValueParam)
        {
            $sOrigin = $sMDAttributeParam + ": " + $htExtractedMD[$sMDAttributeParam]
            $sUpdate = [string]$sMDAttributeParam + ": " + $sMDNewValueParam
            (Get-Content $file.FullName) -replace $sOrigin , $sUpdate | Set-Content $file.FullName
        }
    } else 
    {
        if ($htExtractedMD[$sMDAttributeParam]) 
        {
            $sOrigin = $sMDAttributeParam + ": " + $htExtractedMD[$sMDAttributeParam]
            $sUpdate = $sMDAttributeParam + ": " + $sMDNewValueParam
            (Get-Content $file.FullName) -replace $sOrigin , $sUpdate | Set-Content $file.FullName
        } else 
        {
            $oLastAttribute = $htExtractedMD.GetEnumerator() | Select-Object -Last 1
            $sOrigin = $oLastAttribute.name + ": " + $oLastAttribute.value
            $sUpdate = $sOrigin + "`n" + $sMDAttributeParam + ": " + $sMDNewValueParam
        
            (Get-Content $file.FullName) -replace $sOrigin , $sUpdate | Set-Content $file.FullName
        }
    }
}