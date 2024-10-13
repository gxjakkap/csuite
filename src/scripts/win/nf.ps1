$fileName = $args[0]
$dest = $args[1]
$ext = $args[2]

$templatedir = ".csuite/template"

if ($null -eq $ext){
    $ext = "c"
}

if ($null -eq $dest){
    Write-Host "Missing Argument!"
    exit
}

try {
    if ($ext -eq "c"){
        if (Test-Path -Path "./$dest/$fileName.c" -PathType Leaf){
            Write-Host "./$dest/$fileName.c already existed!"
        }
        else {
            Copy-Item "./$templatedir/c.c" -Destination "./$dest/$fileName.c" -ErrorAction Stop
            Write-Host "./$dest/$fileName.c created successfully!"
        }
    }
    elseif (($ext -eq "py") -or ($ext -eq "python")){
        if (Test-Path -Path "./$dest/$fileName.py" -PathType Leaf){
            Write-Host "./$dest/$fileName.py already existed!"
        }
        else {
            New-Item -Path "./$dest/$fileName.py" -ItemType file -ErrorAction Stop
            Write-Host "./$dest/$fileName.py created successfully!"
        }
    }
    elseif (($ext -eq "test") -or ($ext -eq "test.json")){
        if (Test-Path -Path "./$dest/$fileName.test.json" -PathType Leaf){
            Write-Host "./$dest/$fileName.test.json already existed!"
        }
        else {
            Copy-Item "./$templatedir/test.json" -Destination "./$dest/$fileName.test.json" -ErrorAction Stop
            Write-Host "./$dest/$fileName.test.json created successfully!"
        }
    }
    else {
        if (Test-Path -Path "./$dest/$fileName.$ext" -PathType Leaf){
            Write-Host "./$dest/$fileName.$ext already existed!"
        }
        else {
            New-Item -Path "./$dest/$fileName.$ext" -ItemType file -ErrorAction Stop
            Write-Host "./$dest/$fileName.$ext created successfully!"
        }
    }
}
catch {
    Write-Host "Error while creating $_"
}