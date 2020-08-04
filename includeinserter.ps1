$sTargetLocation = "C:\repos\windows-docs-pr\windows\security\threat-protection"
$sInclude = "[!include[Prerelease information](../../includes/prerelease.md)]"

$lTargetFiles = Get-ChildItem -Path $sTargetLocation -File -Filter "*.md" -Recurse

# Traverse all files under folder
foreach ($oFile in $lTargetFiles) {
    $sFileContents = Get-Content -Path $oFile.FullName

    # Find first heading line
    foreach ($sLine in $sFileContents) {
        if ($sLine -match "^# ")
        {
            $sLineToUpdate = $sLine
            break
        }
        
    }
    
    # Add include message
    $sUpdate = $sLineToUpdate + "`n`n" + $sInclude
    (Get-Content $oFile.FullName) -replace $sLineToUpdate , $sUpdate | Set-Content $oFile.FullName
    
}
