$sRedirectFilePath      = 'C:\repos\windows-docs-pr\'
$sPathForFiles          = 'C:\repos\windows-docs-pr\windows\security\threat-protection\microsoft-defender-antivirus'
$sRedirectURLPrefix     = 'https://docs.microsoft.com/windows/security/threat-protection/microsoft-defender-antivirus/'

$sNameChanged1          = 'microsoft-defender'
$sNamePrevious1         = 'windows-defender'

$sNameChanged2          = 'md'
$sNamePrevious2         = 'wd'


# Injest redirect json

$oRedirectFile  = Get-Content ($sRedirectFilePath + ".openpublishing.redirection.json") | ConvertFrom-Json

$arrFileTree    = Get-ChildItem -Path $sPathForFiles -Recurse -File -Include ('*.md','*.yml')
foreach ($oFile in $arrFileTree)
{
    $sOldName = $oFile.FullName -replace $sNameChanged1 , $sNamePrevious1

    if ($oFile.Name -match $sNameChanged2)
    {
        $sOldName = $sOldName -replace $sNameChanged2 , $sNamePrevious2

        # fix just for md to wd
        $sOldName = $sOldName -replace [regex]::Escape('.wd') , '.md'
    }

    $sOldName = $sOldName -replace [regex]::Escape($sRedirectFilePath) , ''
    $sOldName = $sOldName -replace [regex]::Escape('\') , [regex]::Escape('/')

    if (-Not ($oRedirectFile.redirections.source_path -contains $sOldName))
    {
        Write-Host $sOldName "wasn't redirected" -ForegroundColor "Red"

        $sRedirectURL = $sRedirectURLPrefix + $oFile.Name.Substring(0,$oFile.Name.Length-3)

        $oRedirectData = [ordered]@{
    
            source_path = $sOldName
            redirect_url = $sRedirectURL
            redirect_document_id = $true
        
        }

        $oRedirectFile.redirections += $oRedirectData
    }
}

$oOutputJson = $oRedirectFile | ConvertTo-Json

$oOutputJson | Out-File -FilePath ($sRedirectFilePath + ".openpublishing.redirection.json") -Force