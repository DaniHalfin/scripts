<#  Written by:     daniha
    Last update:    10/2/2019
#>

## REGEX patterns
$sLinkInFilePattern        = "(\[.*\]\(.*\))"
$sValueInBracketsPattern   = "\(([^\[]*)\)"

### Matching patterns
$sDocsURLPattern           = "https://docs\.microsoft\.com.*"
$sURLPattern               = "http.*"
$sInternalPathPattern      = "\/([A-Z]|[a-z])+\/.*"
$sFileNamePattern          = "([A-Z]|[a-z])+\.([A-Z]|[a-z])+.*"
$sAnchorPattern            = "(?<![\w\d])#([A-Z]|[a-z])+.*"

## Env vars
$sDocsetPath               = 'C:\CPubGit\windows-docs-pr\windows\'
$sBaseURL                  = 'https://docs.microsoft.com/en-us/windows/'
$sDocsPrefix               = 'https://docs.microsoft.com/'
$sDocsPrefixWithLocale     = 'https://docs.microsoft.com/en-us/'

$arrFileTree = Get-ChildItem -Path $sDocsetPath -Recurse -File -Include ('*.md','*.yml')
foreach ($oFile in $arrFileTree)
{
   foreach ($match in (Select-String -Path $oFile.FullName -Pattern $sLinkInFilePattern))
   {
      $sMatchLink = ($match.Matches.value -split $sValueInBracketsPattern)[1]
      switch -Regex ($sMatchLink)
      {
         $sDocsURLPattern
         {
            $sAbsoluteURL  = [System.Net.HttpWebRequest]::Create($sMatchLink).GetResponse().ResponseUri.AbsoluteUri

            $sAbsoluteURL  = $sAbsoluteURL -replace $sDocsPrefixWithLocale
            $sAbsoluteURL  = $sAbsoluteURL -replace $sDocsPrefix

            $sMatchLink    = $sMatchLink -replace $sDocsPrefixWithLocale
            $sMatchLink    = $sMatchLink -replace $sDocsPrefix

            if ($sMatchLink -ne $sAbsoluteURL)
            {
               $match.Filename
            }
         }
      }
   }
}
