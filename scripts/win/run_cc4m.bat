@echo off
setlocal
set "MATLAB=C:\Program Files\MATLAB\R2024b\bin\matlab.exe"
if not exist "%MATLAB%" (
  echo Edit scripts\win\run_cc4m.bat and set the MATLAB path.
  exit /b 1
)
pushd %~dp0\..\..
"%MATLAB%" -batch "addpath('tools'); check_cc4m"
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
