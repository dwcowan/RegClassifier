@echo off
setlocal
REM Update this path if your MATLAB version differs
set "MATLAB=C:\Program Files\MATLAB\R2024b\bin\matlab.exe"
if not exist "%MATLAB%" (
  echo Edit scripts\win\run_checks.bat and set the MATLAB path.
  exit /b 1
)
pushd %~dp0\..\..
"%MATLAB%" -batch "addpath('tools'); check_style; check_contracts; check_api_drift"
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
