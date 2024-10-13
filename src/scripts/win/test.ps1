$name=$args[0]
$src = $args[1]

if (!$name -or !$src){
    throw "Invalid Parameter!"
}


$compileCommand = "./cm `"$name`" $src"    
Invoke-Expression -Command $compileCommand -ErrorAction Stop

$testCommand = "py .csuite/test/tester.py `"bin/$($name)_$($src)`""    
Invoke-Expression -Command $testCommand