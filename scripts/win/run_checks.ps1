$matlab = "C:\Program Files\MATLAB\R2024b\bin\matlab.exe"
if (-not (Test-Path $matlab)) {
  Write-Error "Edit scripts\win\run_checks.ps1 and set the MATLAB path."
  exit 1
}
Set-Location (Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent)
& $matlab -batch "addpath('tools'); check_style; check_contracts; check_api_drift"
exit $LASTEXITCODE
