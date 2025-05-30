function Get-ArchiveSizeInfo {
    param (
        [string]$ArchivePath,
        [string]$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
    )

    # Get all archive files
    if (!$ArchivePath) { return Write-Warning "Archives path not specified" }
    $itemsArray = Get-ChildItem -Path "$ArchivePath\*" -Include *.7z, *.rar, *.zip | Select-Object -ExpandProperty FullName
    
    if ($itemsArray.Count -eq 0) {
        Write-Warning "No archive files found in $ArchivePath"
        return
    }

    $7zArray = @()
    
    # Get information for each archive using 7-Zip
    try {
        foreach ($item in $itemsArray) {
            $7zArray += & "$SevenZipPath" l "$item"
        }
    }
    catch {
        Write-Warning "Failed to process archive: $item"
        Write-Warning $_.Exception.Message
        return
    }

    Write-Output "Number of archives found: $($itemsArray.count)"

    # Extract uncompressed sizes from 7-Zip output
    $pattern = '\.\.\.\.A\s+(\d+)\s+'
    $sizeMatches = $7zArray | Where-Object { $_ -match $pattern }

    $uncompSizesArr = @()

    foreach ($item in $sizeMatches) {
        if ($item -match $pattern) {
            $uncompSizesArr += [long]$matches[1]
        }
    }

    # Calculate and output total size
    $totalUncompSize = ($uncompSizesArr | Measure-Object -Sum).Sum
    $sizeInGB = [math]::Round(($totalUncompSize / 1GB), 2)
    
    Write-Output "Total uncompressed size: $sizeInGB GB"
}
