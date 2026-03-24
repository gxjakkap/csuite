$name=$args[0]
$src = $args[1]
$ext = $args[2]

$dir = "./$src"

if (!$name){
    throw "Invalid Parameter!"
}

if ($null -eq $ext){
    $ext = "c"
}

if (-not (Test-Path -Path "./.csuite/bin")){
    $null = New-Item -Path "./.csuite/bin" -ItemType "directory"
}


if (($ext -eq "c")){
    if (Test-Path -Path "$dir/$name.c" -PathType Leaf){
        $compileCommand = "gcc `"$($dir)\$($name).c`" -o `".\.csuite\bin\$($name)_$($src).exe`""
        Write-Host "Compiling with command: $compileCommand"
        
        Invoke-Expression -Command $compileCommand -ErrorAction Stop

        if ($LASTEXITCODE -ne 0) {
            throw "Error compiling $name. Check the source code for errors."
        }
        else {
            Write-Host "$name.$ext compiled successfully! binary at .csuite/bin/$($name)_$($src)"
        }
    }
    else {
        Write-Host "File does not exist!"
    }
}

elseif (($ext -eq "cc") -or ($ext -eq "cpp")){
    if (Test-Path -Path "$dir/$name.cc" -PathType Leaf){
        $compileCommand = "g++ `"$dir\$name.cc`" -o `".\.csuite\bin\$($name)_$($src).exe`""
        Write-Host "Compiling with command: $compileCommand"
        
        Invoke-Expression -Command $compileCommand -ErrorAction Stop

        if ($LASTEXITCODE -ne 0) {
            throw "Error compiling $name. Check the source code for errors."
        }
        else {
            Write-Host "$name.$ext compiled successfully! binary at .csuite/bin/$($name)_$($src)"
        }
    }
    else {
        Write-Host "File does not exist!"
    }
}

else {
    Write-Host "Compile command does not exist for $ext!"
    throw "Error"
}