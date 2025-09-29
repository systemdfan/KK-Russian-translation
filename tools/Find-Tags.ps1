param(
    [Parameter(Mandatory=$true)]
    [string]$targetDirectory
)

$regex = '(^.*:)|(\[P.*?\]\s\[H.*?\])'

Get-ChildItem -Path $targetDirectory -Recurse -File | 
    Select-String -Pattern $regex -AllMatches | 
    ForEach-Object { $_.Matches.Value } | 
    Sort-Object -Unique