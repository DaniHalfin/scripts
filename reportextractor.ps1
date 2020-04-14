<#  Written by:     daniha
    Last update:    2/25/19
#>

# Define file location vars and branches to compare
# Needs to be edited based on where you run the script and where you want to save files to
# as well as the names of the 2 branches you're comparing
$sRepoLocation = "C:\repos\microsoft-365-docs-pr\"
$sCSVLocation = "C:\temp\changereport.csv"
$sDefaultBranch = "master"
$sDiffBranch = "seo-review-v1"

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
    $arrFileMetadata = @{}
    
    $sFileContents = Get-Content -Path $filename
    $nNumOfSeparators = 0

    for ($nLine =0; $nNumOfSeparators -lt 2; $nLine++)
    {
        $sCurrLine = $sFileContents[$nLine]
        if (($sCurrLine -notmatch "-") -and ($nNumOfSeparators -eq 0))
        {
            $arrFileMetadata = @{}
            break
        } elseif ($sCurrLine -notmatch "---") {
            $arrParsedLine = $sCurrLine -split "\s*:\s*"
            $arrFileMetadata.Add($arrParsedLine[0], $arrParsedLine[1])
        } else { $nNumOfSeparators++ }
    }
    return $arrFileMetadata
}

<#
.SYNOPSIS
Finds data in hashtable and adds it to row object.

.DESCRIPTION
Provided with the parsed file metadata hashtable, this function will find the provided tag name and insert it's value to the results table.

.PARAMETER resultobj
Parsed file metadata hashtable.

.PARAMETER rowobj
Row object to add data into.

.PARAMETER tagname
Tag name to lookup.

.EXAMPLE
Add-TagToRow $htExtractedMD $oExportRow "title"
#>
function Add-TagToRow ($resultobj, $rowobj, $tagname)
{
    $rowobj | Add-Member -Type NoteProperty -Name $tagname -value $resultobj[$tagname]
    return $rowobj
}

# Get list of files
Set-Location $sRepoLocation

$sDiffCommand = "git diff --name-only "  + $sDefaultBranch + ".." + $sDiffBranch

$lDiffFiles = Invoke-Expression $sDiffCommand


# Init export table array
$arrExportTable = @()

# Loop through all markdown files in list
foreach ($line in $lDiffFiles)
{
    # Parse file metadata
    $htExtractedMD = Get-Metadata (($sRepoLocation + $line) -replace "/","\")

    # Add data to export table if any metadata is found in the file
    if ($htExtractedMD.count -notlike 0)
    {
        $oExportRow = New-Object psobject

        $oExportRow | Add-Member -Type NoteProperty -Name "File Name" -Value ($line)
        Add-TagToRow $htExtractedMD $oExportRow "ms.author"

        $arrExportTable += $oExportRow
    }
}

# Export data to CSV based on location provided
$arrExportTable | Export-Csv $sCSVLocation -NoTypeInformation