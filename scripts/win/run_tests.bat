@echo off
setlocal
set "MATLAB=C:\Program Files\MATLAB\R2024b\bin\matlab.exe"
if not exist "%MATLAB%" (
  echo Edit scripts\win\run_tests.bat and set the MATLAB path.
  exit /b 1
)
pushd %~dp0\..\..
"%MATLAB%" -batch "addpath('tools'); check_tests; results = runtests('tests','IncludeSubfolders',true); assertSuccess(results)"
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
