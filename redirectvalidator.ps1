<#  Written by:     daniha
    Last update:    10/2/2019
#>

$sRepoPath = 'C:\CPubGit\windows-docs-pr\'
$sFilePath = $sRepoPath + '.openpublishing.redirection.json'

function Find-Redirects ($sFileNamePattern, $sPath)
{
   $arrFileTree = Get-ChildItem -Path $sPath -Recurse -Exclude "*.json"
   foreach ($oFile in $arrFileTree)
   {
         #switch -File $oFile
         

         
   }
}

$jsonRedirects = Get-Content $sFilePath | ConvertFrom-Json

$arrFileTree = Get-ChildItem -Path $sRepoPath -Recurse -File -Exclude "*.json"
foreach ($oFile in $arrFileTree)
{
   foreach ($oRedirect in $jsonRedirects.redirections.source_path)
   {
      $sRedirectClean = $oRedirect -replace "/","\"
      $oFile.DirectoryName + " matches " + @($sRedirectClean)
      $oFile.DirectoryName + "(?<content>.*)" -match @($sRedirectClean)
   }
}
