Write-Host "========================="
Write-Host "BUILDING DOCKER CONTAINER"
Write-Host "========================="

docker build --file Dockerfile . -t authproc-smx:latest

Write-Host "==========================="
Write-Host "RUNNING SOURCEPAWN COMPILER"
Write-Host "==========================="

if (Test-Path -PathType Container plugins)
{
    Write-Host "* Clearing old plugins"
    Remove-Item -Path plugins -Recurse
}

Write-Host "* Creating output directory"
New-Item -Path plugins -Type Directory

$compile_list = Get-ChildItem -Path ./scripting -File | Foreach-Object {$_.BaseName}

foreach ($plugin in $compile_list)
{
    Write-Host "* Compiling $plugin"
    docker run --name="authproc-smx-session" authproc-smx:latest "--show-includes" "${plugin}.sp"
    Write-Host "* Compiled! Copying $plugin"
    docker cp authproc-smx-session:scripting/${plugin}.smx plugins/
    Write-Host "* Closing Temporary Session"
    docker rm authproc-smx-session
    Write-Host "* Finished compiling $plugin"
}

