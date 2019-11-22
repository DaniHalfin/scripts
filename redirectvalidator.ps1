<#  Written by:     daniha
    Last update:    10/2/2019
#>

## REGEX patterns
$sLinkInFilePattern     = "\[.*\]\(.*\)"
$sURLPattern            = "http.*"
$sInternalPathPattern   = "\/([A-Z]|[a-z])+\/.*"
$sFileNamePattern       = "([A-Z]|[a-z])+\.([A-Z]|[a-z])+.*"
$sAnchorPattern         = "(?<![\w\d])#([A-Z]|[a-z])+.*"

## Env vars
$sDocsetPath            = 'C:\CPubGit\windows-docs-pr\windows\'
$sBaseURL               = 'https://docs.microsoft.com/en-us/windows/'


$arrFileTree = Get-ChildItem -Path $sDocsetPath -Recurse -File -Exclude "*.json"
foreach ($oFile in $arrFileTree)
{
   Select-String -Path $oFile.FullName -Pattern
}
