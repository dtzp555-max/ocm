@echo off
:: ================================================================
:: OpenClaw Manager v0.6.0 — Start Script (Windows)
::
:: Features:
::   * Auto-detect Node.js, show install instructions if missing
::   * Auto-detect %USERPROFILE%\.openclaw directory
::   * Auto-create manager-config.json on first run
::   * Auto-kill previous OCM process if port is in use
::   * Supports --dir / --port / --host / --help
:: ================================================================
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

set "SCRIPT_DIR=%~dp0"
set "MANAGER_JS=%SCRIPT_DIR%openclaw-manager.js"
set "CONFIG_JSON=%SCRIPT_DIR%manager-config.json"
set "MIN_NODE_MAJOR=18"

echo.
echo   ===================================
echo      OpenClaw Manager  v0.6.0
echo   -----------------------------------
echo.

:: ── Check main file ─────────────────────────────────────────
if not exist "%MANAGER_JS%" (
    echo   [X] Cannot find openclaw-manager.js
    echo       Expected: %MANAGER_JS%
    echo.
    pause
    exit /b 1
)

:: ── Check Node.js ───────────────────────────────────────────
where node >nul 2>&1
if errorlevel 1 (
    echo   [X] Node.js not found
    echo.
    echo   Install Node.js (pick one):
    echo.
    echo   1^) winget:   winget install OpenJS.NodeJS.LTS
    echo   2^) scoop:    scoop install nodejs-lts
    echo   3^) Official: https://nodejs.org/
    echo   4^) nvm-windows: https://github.com/coreybutler/nvm-windows
    echo.
    pause
    exit /b 1
)

for /f "tokens=1 delims=." %%v in ('node -e "process.stdout.write(process.versions.node)"') do (
    set "NODE_MAJOR=%%v"
)

if !NODE_MAJOR! LSS %MIN_NODE_MAJOR% (
    echo   [!] Node.js too old (need ^>= v%MIN_NODE_MAJOR%)
    echo.
    echo   Install Node.js (pick one):
    echo.
    echo   1^) winget:   winget install OpenJS.NodeJS.LTS
    echo   2^) scoop:    scoop install nodejs-lts
    echo   3^) Official: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node -e "process.stdout.write('v'+process.versions.node)"') do (
    echo   [OK] Node.js %%v
)

:: ── Parse arguments ─────────────────────────────────────────
set "DIR_ARG="
set "PORT_ARG="
set "HOST_ARG="
set "EXTRA_ARGS="

:parse_args
if "%~1"=="" goto :after_args
if /i "%~1"=="--help" goto :show_help
if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--dir" (
    set "DIR_ARG=%~2"
    shift & shift
    goto :parse_args
)
if /i "%~1"=="--port" (
    set "PORT_ARG=%~2"
    shift & shift
    goto :parse_args
)
if /i "%~1"=="--host" (
    set "HOST_ARG=%~2"
    shift & shift
    goto :parse_args
)
set "EXTRA_ARGS=!EXTRA_ARGS! %~1"
shift
goto :parse_args

:show_help
echo Usage: start.bat [options]
echo.
echo Options:
echo   --dir  ^<path^>   OpenClaw config directory (default: %%USERPROFILE%%\.openclaw)
echo   --port ^<port^>   Listen port (default: 3333)
echo   --host ^<addr^>   Bind address (default: 0.0.0.0)
echo   --help          Show this help
echo.
exit /b 0

:after_args

:: ── Detect OpenClaw config directory ────────────────────────
set "OPENCLAW_DIR="
if defined DIR_ARG (
    set "OPENCLAW_DIR=!DIR_ARG!"
) else if exist "%CONFIG_JSON%" (
    for /f "tokens=*" %%d in ('node -e "try{const c=JSON.parse(require('fs').readFileSync('%CONFIG_JSON%','utf8'));const d=c.openclawDir||c.dir||'';process.stdout.write(d.replace(/^~/,require('os').homedir()))}catch{}"') do (
        set "OPENCLAW_DIR=%%d"
    )
)
if not defined OPENCLAW_DIR set "OPENCLAW_DIR=%USERPROFILE%\.openclaw"

if exist "!OPENCLAW_DIR!" (
    echo   [OK] Config dir: !OPENCLAW_DIR!
) else (
    echo   [!] Config dir not found: !OPENCLAW_DIR!
    echo       First time? Run: openclaw onboard
)

:: ── First run: auto-create manager-config.json ──────────────
if not exist "%CONFIG_JSON%" (
    echo   [-^>] First run, creating manager-config.json
    node -e "require('fs').writeFileSync('%CONFIG_JSON%',JSON.stringify({dir:'~/.openclaw'},null,2))"
)

:: ── Port handling: kill old process if occupied ─────────────
set "PORT=3333"
if defined PORT_ARG set "PORT=!PORT_ARG!"

:: Find PID using the port and kill it
for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr /r ":!PORT! .*LISTENING"') do (
    echo   [!] Port !PORT! in use (PID %%p), stopping old process...
    taskkill /PID %%p /F >nul 2>&1
    timeout /t 1 /nobreak >nul 2>&1
    echo   [OK] Old process stopped
)

:: ── Build launch command ────────────────────────────────────
set "CMD_ARGS="
if defined DIR_ARG  set "CMD_ARGS=!CMD_ARGS! --dir "!DIR_ARG!""
if defined PORT_ARG set "CMD_ARGS=!CMD_ARGS! --port !PORT_ARG!"
if defined HOST_ARG set "CMD_ARGS=!CMD_ARGS! --host !HOST_ARG!"
if defined EXTRA_ARGS set "CMD_ARGS=!CMD_ARGS! !EXTRA_ARGS!"

echo.
echo   [^>] Starting -^> http://localhost:!PORT!
echo       Ctrl+C to stop
echo.

:: ── Launch ──────────────────────────────────────────────────
node "%MANAGER_JS%"!CMD_ARGS!

if errorlevel 1 (
    echo.
    echo   [X] Failed to start. Check errors above.
    pause
)
endlocal
