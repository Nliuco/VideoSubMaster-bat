@echo off
:: 强制关闭所有回显
echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: 主菜单函数
:MAIN_MENU
cls
echo ===================== 视频字幕处理工具 =====================
echo.
echo   请选择操作模式：
echo.
echo     1. 自动处理模式[批量处理所有视频]
echo     2. 手动处理模式[逐个处理视频]
echo     0. 退出程序
echo.
echo ========================================================
echo.

set /p "menu_choice=请输入选项数字 [0-2]："

if "%menu_choice%"=="1" goto AUTO_PROCESS_MENU
if "%menu_choice%"=="2" goto MANUAL_PROCESS
if "%menu_choice%"=="0" exit /b

echo.
echo ❌ 无效输入，请重新输入！
timeout /t 2 > nul
goto MAIN_MENU

:: 自动处理模式菜单
:AUTO_PROCESS_MENU
cls
echo ===================== 自动处理模式 =====================
echo.
echo   请选择批量处理方式：
echo.
echo     1. 全部封装为软字幕
echo     2. 全部封装为硬字幕
echo     3. 根据字幕类型智能处理 (srt->软字幕, ass->硬字幕)
echo     4. 返回主菜单
echo.
echo =====================================================
echo.

set /p "auto_choice=请输入选项数字 [1-4]："

if "%auto_choice%"=="1" set "batch_mode=soft" & goto BATCH_PROCESS
if "%auto_choice%"=="2" set "batch_mode=hard" & goto BATCH_PROCESS
if "%auto_choice%"=="3" set "batch_mode=smart" & goto BATCH_PROCESS
if "%auto_choice%"=="4" goto MAIN_MENU

echo.
echo ❌ 无效输入，请重新输入！
timeout /t 2 > nul
goto AUTO_PROCESS_MENU

:: 批量处理所有视频
:BATCH_PROCESS
cls
echo 📦 批量处理模式已启用
echo.

:: 获取时间戳
for /f %%a in ('powershell -Command "Get-Date -Format yyyyMMdd_HHmmss" 2^>nul') do set "timestamp=%%a"

:: 主处理循环
for %%v in (*.mkv *.mp4 *.avi) do (
    call :PROCESS_VIDEO "%%v" "!batch_mode!"
)

echo 🏁 所有文件处理完成。
echo.
pause
goto MAIN_MENU

:: 手动处理模式
:MANUAL_PROCESS
cls
echo 📋 手动处理模式已启用
echo.

:: 获取时间戳
for /f %%a in ('powershell -Command "Get-Date -Format yyyyMMdd_HHmmss" 2^>nul') do set "timestamp=%%a"

:: 主处理循环
for %%v in (*.mkv *.mp4 *.avi) do (
    call :PROCESS_VIDEO "%%v" "manual"
)

echo 🏁 所有文件处理完成。
echo.
pause
goto MAIN_MENU

:: 视频处理子程序
:: 参数1: 视频文件路径
:: 参数2: 处理模式 (soft, hard, smart, manual)
:PROCESS_VIDEO
set "video=%~1"
set "mode=%~2"
set "basename=%~n1"
set "subtitle="
set "subext="

:: 查找字幕
if exist "!basename!.ass" (
    set "subtitle=!basename!.ass"
    set "subext=ass"
) else if exist "!basename!.srt" (
    set "subtitle=!basename!.srt"
    set "subext=srt"
) else (
    echo ⚠ 跳过：未找到字幕 → %~1
    echo.
    goto :EOF
)

echo.
echo 🔎 处理视频：%~nx1
echo 📝 字幕文件：!subtitle!
echo 📄 字幕格式：.!subext!
echo.

:: 根据模式处理视频
if "!mode!"=="manual" goto MANUAL_MODE
if "!mode!"=="soft" goto SOFT_SUB_BATCH
if "!mode!"=="hard" goto HARD_SUB_BATCH
if "!mode!"=="smart" goto SMART_MODE

:: 手动模式 - 用户选择处理方式
:MANUAL_MODE
set "choice="
:CHOOSE_FORMAT
echo 请选择字幕封装方式: 
echo   1. 封装为软字幕 [仅支持 .srt]
echo   2. 烧录为硬字幕 [支持 .srt 和 .ass]
echo   C. 取消处理该视频
echo.
set /p "choice=你的选择[1/2/C，按Enter确认] :"

if /i "!choice!"=="1" goto :SOFT_SUB
if /i "!choice!"=="2" goto :HARD_SUB
if /i "!choice!"=="C" goto :CANCEL_CURRENT
echo.
echo ❌ 无效输入，请重新选择。
goto CHOOSE_FORMAT

:: 批量软字幕处理
:SOFT_SUB_BATCH
echo 🚀 自动处理：全部封装为软字幕
echo.
if /i "!subext!"=="srt" (
    goto :SOFT_SUB
) else (
    echo 🔥 字幕是 .ass 格式，自动转换为 .srt
    goto :CONVERT_ASS_TO_SRT
)
goto :PROCESS_END

:: 批量硬字幕处理
:HARD_SUB_BATCH
echo 🚀 自动处理：全部烧录为硬字幕
echo.
goto :HARD_SUB

:: 智能模式处理
:SMART_MODE 
echo 🚀 自动处理：智能模式 (srt->软字幕, ass->硬字幕)
echo.
if /i "!subext!"=="srt" (
    goto :SOFT_SUB
) else (
    goto :HARD_SUB
)
goto :PROCESS_END

:: 软字幕处理
:SOFT_SUB
if /i "!subext!"=="srt" (
    set "output=!basename!_soft_!timestamp!.mp4"
    echo 🔧 正在封装软字幕（可能需要几分钟）...
    :: ffmpeg -i "!video!" -i "!subtitle!" -c copy -c:s mov_text "!output!" > nul 2>&1
    ffmpeg -i "!video!" -i "!subtitle!" -c copy -c:s mov_text "!output!"
    echo.
    echo ✅ 输出文件：!output!
    goto :PROCESS_END
)
echo   🔥 你选择了软字幕，但字幕是 .ass 格式
set "confirm="
:CONFIRM_CONVERT
echo      是否将 .ass 转换为 .srt 并继续？[Y/N]
echo.
set /p "confirm=确认（Y/N，按Enter确认）："
if /i "!confirm!"=="Y" (
    goto :CONVERT_ASS_TO_SRT
) 
if /i "!confirm!"=="N" goto :CHOOSE_FORMAT
echo.
echo ❌ 无效输入，请输入 Y 或 N。
goto CONFIRM_CONVERT

:: 转换ASS到SRT
:CONVERT_ASS_TO_SRT
set "srtfile=!basename!_converted_!timestamp!.srt"
echo 🔧 正在转换字幕格式（可能需要几分钟）...
:: ffmpeg -i "!subtitle!" "!srtfile!" > nul 2>&1
ffmpeg -i "!subtitle!" "!srtfile!"
set "output=!basename!_soft_!timestamp!.mp4"
echo.
echo 🔁 已转换为 .srt：!srtfile!
echo 🔧 正在封装软字幕（可能需要几分钟）...
:: ffmpeg -i "!video!" -i "!srtfile!" -c copy -c:s mov_text "!output!" > nul 2>&1
:: ffmpeg -i "!video!" -i "!srtfile!" -c copy -c:s mov_text "!output!"
ffmpeg -i "!video!" -i "!srtfile!" -c:v copy -c:a copy -c:s mov_text "!output!"
echo.
echo ✅ 输出文件：!output!
goto :PROCESS_END

:: 硬字幕处理
:HARD_SUB
if /i "!subext!"=="ass" (
    set "filter=ass='!subtitle!'"
) else (
    set "filter=subtitles='!subtitle!'"
)
set "output=!basename!_burned_!timestamp!.mp4"
echo 🔧 正在烧录硬字幕（可能需要较长时间，请耐心等待）...
:: ffmpeg -i "!video!" -vf "!filter!" -c:a copy "!output!" > nul 2>&1
ffmpeg -i "!video!" -vf "!filter!" -c:a copy "!output!"
echo.
echo ✅ 输出文件：!output!
goto :PROCESS_END

:: 取消当前视频处理
:CANCEL_CURRENT
echo 提示: 已取消该视频处理。
goto :PROCESS_END

:: 处理结束
:PROCESS_END
echo.
echo ================================处理完成================================
echo.
goto :EOF