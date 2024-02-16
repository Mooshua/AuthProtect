$base = Get-Location

Write-Host "::::    ==========================="
Write-Host "::::    BUILDING INDIVIDUAL PLUGINS"
Write-Host "::::    ==========================="

Set-Location $base
Set-Location src
& ./build.ps1

Write-Host "::::    ========================="
Write-Host "::::    PACKAGING AUTHPROC ASSETS"
Write-Host "::::    ========================="

Set-Location $base

if (Test-Path -PathType Container package)
{
    Write-Host "* Clearing old package"
    Remove-Item -Path package -Recurse
}

Write-Host "* Creating package directory"
New-Item -Path package -Type Directory

Write-Host "* Creating directories"
New-Item -Path package/addons -Type Directory
New-Item -Path package/addons/sourcemod -Type Directory

Copy-Item -Recurse -Path src/plugins -Destination package/addons/sourcemod
Copy-Item -Recurse -Path src/cfg -Destination package/

Write-Host "::::    =========================="
Write-Host "::::    COMPRESSING PACKAGE TO ZIP"
Write-Host "::::    =========================="

Compress-Archive -Force -Path package/* -DestinationPath authprotect.zip
Write-Host "* Done!"