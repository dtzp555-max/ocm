@echo off
:: ================================================================
:: OpenClaw Manager v0.5.1 — Windows 启动脚本
::
:: 特性：
::   * 自动检测 Node.js，未安装时给出安装指引（winget/scoop/官网）
::   * 自动检测 %USERPROFILE%\.openclaw 目录
::   * 首次运行自动创建 manager-config.json
::   * 自动检测端口占用并建议替代端口
::   * 支持 --dir / --port / --help 参数
:: ================================================================
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

set "SCRIPT_DIR=%~dp0"
set "MANAGER_JS=%SCRIPT_DIR%openclaw-manager.js"
set "CONFIG_JSON=%SCRIPT_DIR%manager-config.json"
set "MIN_NODE_MAJOR=18"

echo.
echo   ===================================
echo      OpenClaw Manager  v0.5.1
echo   -----------------------------------
echo.

:: ── 检查主文件 ────────────────────────────────────────────────
if not exist "%MANAGER_JS%" (
    echo   [X] 找不到 openclaw-manager.js
    echo       期望路径: %MANAGER_JS%
    echo.
    pause
    exit /b 1
)

:: ── 检查 Node.js ─────────────────────────────────────────────
where node >nul 2>&1
if errorlevel 1 (
    echo   [X] 未找到 Node.js
    echo.
    echo   安装方式（选一种即可）：
    echo.
    echo   1^) winget:   winget install OpenJS.NodeJS.LTS
    echo   2^) scoop:    scoop install nodejs-lts
    echo   3^) 官网下载: https://nodejs.org/
    echo   4^) nvm-windows: https://github.com/coreybutler/nvm-windows
    echo.
    pause
    exit /b 1
)

:: 获取主版本号并检查
for /f "tokens=1 delims=." %%v in ('node -e "process.stdout.write(process.versions.node)"') do (
    set "NODE_MAJOR=%%v"
)

if !NODE_MAJOR! LSS %MIN_NODE_MAJOR% (
    echo   [!] Node.js 版本过低（需要 ^>= v%MIN_NODE_MAJOR%）
    echo.
    echo   安装方式（选一种即可）：
    echo.
    echo   1^) winget:   winget install OpenJS.NodeJS.LTS
    echo   2^) scoop:    scoop install nodejs-lts
    echo   3^) 官网下载: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node -e "process.stdout.write('v'+process.versions.node)"') do (
    echo   [OK] Node.js %%v
)

:: ── 解析参数 ─────────────────────────────────────────────────
set "DIR_ARG="
set "PORT_ARG="
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
set "EXTRA_ARGS=!EXTRA_ARGS! %~1"
shift
goto :parse_args

:show_help
echo 用法: start.bat [选项]
echo.
echo 选项:
echo   --dir  ^<路径^>   OpenClaw 配置目录（默认 %%USERPROFILE%%\.openclaw）
echo   --port ^<端口^>   监听端口（默认 3333）
echo   --help          显示帮助
echo.
exit /b 0

:after_args

:: ── 检测 OpenClaw 配置目录 ───────────────────────────────────
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
    echo   [OK] 配置目录: !OPENCLAW_DIR!
) else (
    echo   [!] 配置目录不存在: !OPENCLAW_DIR!
    echo       首次使用？请先运行 openclaw onboard 初始化。
)

:: ── 首次运行：自动创建 manager-config.json ────────────────────
if not exist "%CONFIG_JSON%" (
    echo   [-^>] 首次运行，创建 manager-config.json
    node -e "require('fs').writeFileSync('%CONFIG_JSON%',JSON.stringify({dir:'~/.openclaw'},null,2))"
)

:: ── 检查端口可用性 ───────────────────────────────────────────
set "PORT=3333"
if defined PORT_ARG set "PORT=!PORT_ARG!"

netstat -an 2>nul | findstr /r ":%PORT% .*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo   [!] 端口 !PORT! 已被占用
    for %%p in (3334 3335 3336 8080 8888) do (
        netstat -an 2>nul | findstr /r ":%%p .*LISTENING" >nul 2>&1
        if errorlevel 1 (
            echo       尝试备用端口 %%p...
            set "PORT=%%p"
            set "PORT_ARG=%%p"
            goto :port_ok
        )
    )
)
:port_ok

:: ── 构建启动命令 ─────────────────────────────────────────────
set "CMD_ARGS="
if defined DIR_ARG  set "CMD_ARGS=!CMD_ARGS! --dir "!DIR_ARG!""
if defined PORT_ARG set "CMD_ARGS=!CMD_ARGS! --port !PORT_ARG!"
if defined EXTRA_ARGS set "CMD_ARGS=!CMD_ARGS! !EXTRA_ARGS!"

echo.
echo   [^>] 启动中 -^> http://localhost:!PORT!
echo       Ctrl+C 停止
echo.

:: ── 启动 ─────────────────────────────────────────────────────
node "%MANAGER_JS%"!CMD_ARGS!

if errorlevel 1 (
    echo.
    echo   [X] 启动失败，请检查上方错误信息。
    pause
)
endlocal
