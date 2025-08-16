@echo off
setlocal
set "MATLAB=C:\Program Files\MATLAB\R2024b\bin\matlab.exe"
if not exist "%MATLAB%" (
  echo Edit scripts\win\gate_ready_for_build.bat and set the MATLAB path.
  exit /b 1
)
pushd %~dp0\..\..
"%MATLAB%" -batch "addpath('tools'); gate_ready_for_build"
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
