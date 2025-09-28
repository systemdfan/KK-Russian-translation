param(
    [Parameter(Mandatory=$true)]
    [string]$startFolder
)
$hashes = @{}

Get-ChildItem -Path $startFolder -Recurse -File | ForEach-Object {
    $hash = Get-FileHash -Path $_.FullName -Algorithm MD5
    if ($hashes.ContainsKey($hash.Hash)) {
        $hashes[$hash.Hash] += $_.FullName
    } else {
        $hashes[$hash.Hash] = @($_.FullName)
    }
}

$hashes.GetEnumerator() | Where-Object {$_.Value.Count -gt 1} | ForEach-Object {
    Write-Host "Found duplicates by hash $($_.Name):"
    $_.Value | ForEach-Object { Write-Host "- $_" }
    Write-Host ""
}