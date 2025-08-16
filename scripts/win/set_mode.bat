@echo off
setlocal
if "%~1"=="" (
  echo Usage: set_mode.bat clean-room^|build^|optimisation
  exit /b 1
)
set "MODE=%~1"
if /I "%MODE%"=="clean-room" goto ok
if /I "%MODE%"=="build" goto ok
if /I "%MODE%"=="optimisation" goto ok
echo Invalid mode: %MODE%
exit /b 1
:ok
set "JSON={""mode"":""%MODE%""}"
> "%~dp0..\..\contexts\mode.json" echo %JSON%
echo Updated contexts\mode.json to mode=%MODE%
echo (Optional) committing change...
git add "%~dp0..\..\contexts\mode.json" >NUL 2>&1
git commit -m "chore(mode): switch to %MODE%" >NUL 2>&1
exit /b 0
