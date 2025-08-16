$matlab = "C:\Program Files\MATLAB\R2024b\bin\matlab.exe"
if (-not (Test-Path $matlab)) { Write-Error "Set MATLAB path"; exit 1 }
Set-Location (Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent)
& $matlab -batch "addpath('tools'); snapshot_api"
exit $LASTEXITCODE
