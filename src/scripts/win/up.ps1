# Requires -Version 3.0
$ErrorActionPreference = "Stop"

$LATEST_LINK = "https://raw.githubusercontent.com/gxjakkap/csuite/main/scriptversions.json"
$REPO_BASE = "https://raw.githubusercontent.com/gxjakkap/csuite/main"
$LOCAL_JSON_PATH = ".csuite\local_scriptversions.json"

Write-Host "Checking for updates..."

try {
    $remoteData = Invoke-RestMethod -Uri $LATEST_LINK
} catch {
    Write-Host "Error: Failed to fetch remote version information."
    exit 1
}

if (-not (Test-Path -Path $LOCAL_JSON_PATH)) {
    Write-Host "No local scriptversions.json found. Please remove .csuite folder and run 'npx create-csuite' to download it."
    exit 1
}

$localDataStr = Get-Content -Raw -Path $LOCAL_JSON_PATH
$localData = $localDataStr | ConvertFrom-Json

$platform = "win"
if ($localData.PSObject.Properties.Match('platform').Count -gt 0) {
    if ($localData.platform) {
        $platform = $localData.platform
    }
}

$staleScripts = @()

foreach ($remoteCatProp in $remoteData.PSObject.Properties) {
    $remoteCat = $remoteCatProp.Name
    if (($remoteCat -eq 'linux' -or $remoteCat -eq 'win') -and $remoteCat -ne $platform) {
        continue
    }

    $localCat = if ($remoteCat -eq $platform) { "scripts" } else { $remoteCat }
    
    $remoteItems = $remoteCatProp.Value
    if (-not ($remoteItems -is [System.Management.Automation.PSCustomObject])) {
        continue
    }

    $localItems = $null
    if ($localData.PSObject.Properties.Match($localCat).Count -gt 0) {
        $localItems = $localData.$localCat
    }

    foreach ($keyProp in $remoteItems.PSObject.Properties) {
        $key = $keyProp.Name
        $remoteVer = $keyProp.Value
        
        $localVer = 0
        if ($localItems -ne $null -and $localItems.PSObject.Properties.Match($key).Count -gt 0) {
            $localVer = $localItems.$key
        }

        if ($remoteVer -gt $localVer) {
            $staleScripts += [PSCustomObject]@{
                LocalCat = $localCat
                Item = $key
                RemoteCat = $remoteCat
                RemoteVer = $remoteVer
            }
        }
    }
}

if ($staleScripts.Count -eq 0) {
    Write-Host "All scripts are up to date."
    exit 0
}

Write-Host "Updates found! Pulling latest versions..."

foreach ($stale in $staleScripts) {
    $localCategory = $stale.LocalCat
    $item = $stale.Item
    $remoteCategory = $stale.RemoteCat
    $remoteVer = $stale.RemoteVer

    Write-Host "-> Updating $localCategory: $item"

    $success = $false

    if ($localCategory -eq "scripts") {
        $downloadUrl = "$REPO_BASE/src/scripts/$remoteCategory/$item.ps1"
        $dest = ".\$item.ps1"
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $dest
            $success = $true
        } catch { }
    } elseif ($localCategory -eq "py") {
        $downloadUrl = "$REPO_BASE/src/py/$item.py"
        $destDir = ".csuite\test"
        if (-not (Test-Path -Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
        $dest = "$destDir\$item.py"
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $dest
            $success = $true
        } catch { }
    } elseif ($localCategory -eq "template") {
        $ext = ""
        if ($item -in @("c", "cpp", "java")) {
            $ext = ".$item"
        } elseif ($item -eq "test") {
            $ext = ".json"
        }
        $downloadUrl = "$REPO_BASE/src/template/$item$ext"
        $destDir = ".csuite\template"
        if (-not (Test-Path -Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
        $dest = "$destDir\$item$ext"
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $dest
            $success = $true
        } catch { }
    }

    if ($success) {
        if ($localData.PSObject.Properties.Match($localCategory).Count -eq 0) {
            $localData | Add-Member -MemberType NoteProperty -Name $localCategory -Value ([PSCustomObject]@{})
        }
        
        $catObj = $localData.$localCategory
        if ($catObj.PSObject.Properties.Match($item).Count -eq 0) {
            $catObj | Add-Member -MemberType NoteProperty -Name $item -Value $remoteVer
        } else {
            $catObj.$item = $remoteVer
        }

        $localData | ConvertTo-Json -Depth 10 | Set-Content -Path $LOCAL_JSON_PATH
        Write-Host "Successfully updated $item!"
    } else {
        Write-Host "Failed to properly download $item."
    }
}

Write-Host "Update process finished!"
