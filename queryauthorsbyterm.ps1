$sTermToSearch = 'whitelist'
$sBaseURI = 'https://docs.microsoft.com/api/Search?locale=en-us&$top=25&facet=category&%24filter=category+eq+%27Documentation%27&search=' + $sTermToSearch

$apiResponse = Invoke-RestMethod -Uri $sBaseURI

$arrLinks = @()

for ($nSkip = 0; $nSkip -le $apiResponse.count; $nskip += 25)
{
    $sSkipURI = $sBaseURI + '&$skip=' + $nSkip
    $apiResponse = Invoke-RestMethod -Uri $sSkipURI
    $arrLinks += $apiResponse.results.url
}

$arrAuthorList = @()

foreach ($sLink in $arrLinks)
{
    $wrDocsLink = Invoke-WebRequest -Uri $sLink

    $oExportRow = New-Object psobject
    $oExportRow | Add-Member -Type NoteProperty -Name "URL" -Value ($sLink)
    $oExportRow | Add-Member -Type NoteProperty -Name "author" -Value ($wrDocsLink.ParsedHtml.getElementById('ms.author').content)

    $arrAuthorList += $oExportRow
}

$sCSVLocation = "C:\temp\authorlist.csv"

$arrAuthorList | Export-Csv $sCSVLocation -NoTypeInformation