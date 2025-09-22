@echo off
setlocal EnableDelayedExpansion
if "%~1"=="" (
    echo Usage: %~nx0 proxy_address:port
    echo Example: %~nx0 127.0.0.1:18080
    exit /b
)
set proxy=%~1
set speedTestUtility=wget.exe
set speedTestSite=https://speedtest.selectel.ru/10MB
set tmpLog=tmpSpeed.log
if exist "%tmpLog%" del /q "%tmpLog%"
%speedTestUtility% -e https_proxy=%proxy% -O NUL %speedTestSite% > "%tmpLog%" 2>&1
for /f "delims=" %%a in ('findstr /c:"saved" "%tmpLog%"') do set line=%%a
for /f "tokens=2 delims=()" %%b in ("!line!") do set rawSpeed=%%b
set rawSpeed=!rawSpeed: =!
echo !rawSpeed!
if exist "%tmpLog%" del /q "%tmpLog%"
exit
