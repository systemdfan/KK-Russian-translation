param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,

    #[Parameter(Mandatory=$true)]
    [string]$HMappingIniPath,

    [hashtable]$HMapping = $null
)

function Parse-HMappingIni {
    param(
        [string]$IniPath
    )

    Write-Host "Loading mapping from ini: $IniPath" -ForegroundColor Cyan

    $mapping = @{}
    $lines = Get-Content -Path $IniPath -Raw -Encoding UTF8 -ErrorAction Stop |
             ForEach-Object { $_ -split "(`r`n|`n|`r)" }

    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed -eq "" -or $trimmed.StartsWith("#") -or $trimmed.StartsWith(";")) { continue }

        if ($trimmed -match '^([0-9]{2})=(.+)$') {
            $key = $matches[1]
            $value = $matches[2]
            $mapping[$key] = $value
        }
    }

    return $mapping
}

$hMap = @{}
if (!([string]::IsNullOrWhiteSpace($HMappingIniPath))) {
    $hMap = Parse-HMappingIni -IniPath $HMappingIniPath
    Write-Host "Mapping loaded and contains: $($hMap.Keys.Count)" -ForegroundColor Green
}


# Deleting UNIX EOL symbols in files
function Repair-FileEOL {
    param(
        [string]$Content
    )
    
    Write-Host "Fixing EOL in file..." -ForegroundColor Yellow
    
    # Deleting LFs without CRs
    $repairedContent = $Content -replace '(?<!\r)\n', ''
    
    return $repairedContent
}

function Parse-CommunicationFile {
    param(
        [string]$Content,
        [string]$FileName,
        [hashtable]$HMapping = $null
    )

    Write-Host "Parsing communication file: $FileName" -ForegroundColor Green

    $lines = $Content -split "(`r`n|`n|`r)"
    $result = @()

    $startFound = $false
    $readingNumbers = $false
    $columnIndex = 15  # 0-based: 10 -> 11th column

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        # Extracting cells beetween <>
        $matches = [regex]::Matches($line, '(?<=<).*?(?=>)')
        if ($matches.Count -eq 0) { continue }

        $cells = $matches | ForEach-Object { $_.Value }

        # Wainting for cell = "00"
        if (-not $startFound) {
            if ($cells[1] -eq "00") {
                $startFound = $true
                $readingNumbers = $true
            } else {
                continue
            }
        }

        if ($cells.Count -le $columnIndex) { continue }
        
        $checkCell = $cells[13]
        $targetCell = $cells[$columnIndex]

        if([string]::IsNullOrWhiteSpace($targetCell)){
            continue
            } else {
            if ($readingNumbers) {
                if ($checkCell -match '^sound*') {
                    $fileNum = ($FileName -replace '^.*?(\d{2}).*$', '$1') # extracting heroine number from filename 
                    $prefix = "[H]"
                    if ($HMapping.ContainsKey($fileNum)) {
                        $prefix = $HMapping[$fileNum]
                    }
                    $result += "$prefix`:$targetCell"
                } else {
                    $result += "[K]:$targetCell"
                }
            } else {
                $result += "[K]:$targetCell"
            }
        }
    }

    if (-not $startFound) {
        Write-Host "First female string #00 not found!" -ForegroundColor Yellow
    }

    return ($result -join "`r`n")
}

# Determining file type and parsing
function Parse-File {
    param(
        [string]$FilePath,
        [string]$FileName
    )
    
    Write-Host "Processing file: $FileName" -ForegroundColor Cyan
    
    # Reading file
    try {
        $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
        if (-not $content) {
            Write-Warning "File $FileName is empty or script is unnable to read it"
            return ""
        }
        
        # Fixing EOL symbols
        $repairedContent = Repair-FileEOL -Content $content
        
        # Determining type of file and parsing
        switch -Regex ($FileName) {
            '^communication_*' {
                return Parse-CommunicationFile -Content $repairedContent -FileName $FileName -HMapping $hMap
            }
            default {
                Write-Warning "Unknown file type: $FileName. Skipping."
                return ""
            }
        }
    }
    catch {
        Write-Error "Fail while processing $FileName`: $_"
        return ""
    }
}

# Recursive directory processing
function Process-Directory {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )
    
    # Creating directory if it does not exist
    if (-not (Test-Path -Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        Write-Host "Created directory: $DestinationPath" -ForegroundColor Blue
    }
    
    # Processing all elements in dir
    Get-ChildItem -Path $SourcePath | ForEach-Object {
        $sourceItemPath = $_.FullName
        $destinationItemPath = Join-Path -Path $DestinationPath -ChildPath ($_.Name).Replace("MonoBehaviour", "txt")
        
        if ($_.PSIsContainer) {
            # If it is dir processing recursevely
            Write-Host "Processing subdirectory: $($_.Name)" -ForegroundColor Magenta
            Process-Directory -SourcePath $sourceItemPath -DestinationPath $destinationItemPath
        } else {
            # If file parsing it
            $parsedContent = Parse-File -FilePath $sourceItemPath -FileName $_.Name
            
            if ($parsedContent -ne "") {
                try {
                    # Saving parsed file
                    Set-Content -Path $destinationItemPath -Value $parsedContent -Encoding UTF8 -NoNewline
                    Write-Host "Saved file: $destinationItemPath" -ForegroundColor Green
                }
                catch {
                    Write-Error "Fail saving file: $destinationItemPath`: $_"
                }
            }
        }
    }
}

# Main script logic
Write-Host "=== KK communication file parsing script ===" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "Input direcotry: $InputPath" -ForegroundColor White
Write-Host "Output directory: $OutputPath" -ForegroundColor White

# Checking existance of input dir
if (-not (Test-Path -Path $InputPath -PathType Container)) {
    Write-Error "Input directory not found: $InputPath"
    exit 1
}

# Getting absolute paths
$absoluteInputPath = Resolve-Path -Path $InputPath
$absoluteOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)

Write-Host "Input directory absolute path: $absoluteInputPath" -ForegroundColor Gray
Write-Host "Output directory absolute path: $absoluteOutputPath" -ForegroundColor Gray

# Starting processing
try {
    Process-Directory -SourcePath $absoluteInputPath -DestinationPath $absoluteOutputPath
    Write-Host "=== Processing completed ===" -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "=== Skipped files ===" -ForegroundColor White -BackgroundColor Yellow
}
catch {
    Write-Error "Critical error while processing: $_"
    exit 1
}