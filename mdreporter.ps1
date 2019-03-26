<#  Written by:     daniha
    Last update:    2/25/19
#>

# Define file location vars
# Needs to be edited based on where you run the script and where you want to save files to
$sRepoLocation = "C:\CPubGit\it-client"
$sCSVLocation = "C:\temp\mdreport-itclient.csv"

# Recurse through file tree location provided above to find all markdown files
$lRepoFiles = Get-ChildItem -Path $sRepoLocation -File -Filter "*.md" -Recurse

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

# Init export table array
$arrExportTable = @()

# Loop through all markdown files found in folder structure
foreach ($file in $lRepoFiles)
{
    # Parse file metadata
    $htExtractedMD = Get-Metadata ($file.FullName)

    # Add data to export table if any metadata is found in the file
    if ($htExtractedMD.count -notlike 0)
    {
        $oExportRow = New-Object psobject

        $oExportRow | Add-Member -Type NoteProperty -Name "File Name" -Value ($file.FullName).SubString(10)
        Add-TagToRow $htExtractedMD $oExportRow "title"
        Add-TagToRow $htExtractedMD $oExportRow "author"
        Add-TagToRow $htExtractedMD $oExportRow "ms.author"
        Add-TagToRow $htExtractedMD $oExportRow "manager"
        Add-TagToRow $htExtractedMD $oExportRow "audience"
        Add-TagToRow $htExtractedMD $oExportRow "ms.topic"
        Add-TagToRow $htExtractedMD $oExportRow "ms.prod"
        Add-TagToRow $htExtractedMD $oExportRow "ms.service"
        Add-TagToRow $htExtractedMD $oExportRow "ms.collection"
        Add-TagToRow $htExtractedMD $oExportRow "ms.localizationpriority"
        Add-TagToRow $htExtractedMD $oExportRow "localization_priority"

        $arrExportTable += $oExportRow
    }
}

# Export data to CSV based on location provided
$arrExportTable | Export-Csv $sCSVLocation -NoTypeInformation