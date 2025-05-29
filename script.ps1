$7zipPath = "C:\Program Files\7-Zip\7z.exe"
$archivePath = "E:\PS Games\PS2"
$itemsArray = Get-ChildItem -Path "$archivePath\*" -Include *.7z, *.rar, *.zip  | Select-Object -ExpandProperty FullName

$7zArray = @()

foreach ($item in $itemsArray) {
    $7zArray += & "$7zipPath" l "$item"
}

Write-Output "Number of archives found:  $($itemsArray.count)"

$pattern = '\.\.\.\.A\s+(\d+)\s+'
$sizeMatches = $7zArray | Where-Object { $_ -match $pattern }

$uncompSizesArr = @()

foreach ($item in $sizeMatches) {
    if ($item -match $pattern) {
        $uncompSizesArr += [long]$matches[1]
    }
}

$totalUncompSize = ($uncompSizesArr | Measure-Object -Sum).Sum
Write-Output "Total uncompressed size: $([math]::Round(($totalUncompSize / 1GB), 2)) GB"