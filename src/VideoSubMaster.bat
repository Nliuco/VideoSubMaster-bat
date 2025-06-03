:: ========================================================
:: VideoSubMaster - 视频字幕处理大师 v1.0
:: 功能：批量/手动处理视频字幕（软字幕封装/硬字幕烧录）
:: 作者：[Pianone]
:: 日期：2025-06-02 02:39 am
:: ========================================================

@echo off
:: 强制关闭所有回显
echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: 创建输出目录（如果不存在）
if not exist "output" (
    mkdir "output" >nul 2>&1
)

:: 主菜单函数
:main_menu
cls
echo ===================== 视频字幕处理大师 v1.0 =====================
echo.
echo.
echo     🚀🚀🚀            请选择操作模式：           🚀🚀🚀    
echo.
echo     🕹 🕹 🕹    1. 自动处理模式[批量处理所有视频]   🕹 🕹 🕹 
echo     ✏ ✏ ✏    2. 手动处理模式[逐个处理视频]       ✏ ✏ ✏ 
echo     ⛩ ⛩ ⛩    0. 退出程序                         ⛩ ⛩ ⛩ 
echo.
echo =================================================================
echo.

set /p "menu_choice=请输入选项数字 [0-2]："

if "%menu_choice%"=="1" goto auto_process_menu
if "%menu_choice%"=="2" goto manual_process
if "%menu_choice%"=="0" exit /b

echo.
echo ❌ 无效输入，请重新输入！
timeout /t 2 > nul
goto main_menu

:: 自动处理模式菜单
:auto_process_menu
cls
echo ================================ 自动处理模式 ===============================================================
echo.
echo     🚀🚀🚀                  请选择批量处理方式：                    🚀🚀🚀    
echo.
echo     🐳🐳🐳    1. 全部封装为软字幕                                   🐳🐳🐳     
echo     🐌🐌🐌    2. 全部封装为硬字幕                                   🐌🐌🐌    
echo     🐙🐙🐙    3. 根据字幕类型智能处理 [srt--软字幕, ass--硬字幕]    🐙🐙🐙   
echo     🦴🦴🦴    4. 返回主菜单                                         🦴🦴🦴        
echo.
echo     tips: 🤔 硬字幕:  即为内嵌烧录字幕, 对视频每一帧进行处理, 耗时往往很长, 由于需实时解码视频流并重新编码
echo                       消耗大量CPU/GPU算力, 但可以保留ass字幕样式，不过字幕会永久写入视频画面，不可移除 
echo           😉 软字幕:  即为内封字幕, 实际上是添加 .srt字幕轨道, 几乎不占用计算资源, 若播放媒体支持, 字幕[可开/关]
echo                       仅封装不重编码, 速度极快[秒级完成]
echo.
echo ==============================================================================================================
echo.

set /p "auto_choice=请输入选项数字 [1-4]："

if "%auto_choice%"=="1" set "batch_mode=soft" & goto batch_process
if "%auto_choice%"=="2" set "batch_mode=hard" & goto batch_process
if "%auto_choice%"=="3" set "batch_mode=smart" & goto batch_process
if "%auto_choice%"=="4" goto main_menu

echo.
echo ❌ 无效输入，请重新输入！
timeout /t 2 > nul
goto auto_process_menu

:: 批量处理所有视频
:batch_process
cls
echo 📦 批量处理模式已启用
echo.

:: 获取时间戳
for /f %%a in ('powershell -Command "Get-Date -Format yyyyMMdd_HHmmss" 2^>nul') do set "timestamp=%%a"

:: 修复点：安全遍历文件[处理特殊字符]
for /f "delims=" %%v in ('dir /b *.mkv *.mp4 *.avi 2^>nul') do (
    call :process_video "%%v" "!batch_mode!"
)

echo 🏁 所有文件处理完成。
echo.
pause
goto main_menu

:: 手动处理模式
:manual_process
cls
echo 📋 手动处理模式已启用
echo.
echo     tips: 🤔 硬字幕:  即为内嵌烧录字幕, 对视频每一帧进行处理, 耗时往往很长, 由于需实时解码视频流并重新编码
echo                       消耗大量CPU/GPU算力, 但可以保留ass字幕样式，不过字幕会永久写入视频画面，不可移除 
echo           😉 软字幕:  即为内封字幕, 实际上是添加 .srt字幕轨道, 几乎不占用计算资源, 若播放媒体支持, 字幕[可开/关]
echo                       仅封装不重编码, 速度极快[秒级完成]
echo.

:: 获取时间戳
for /f %%a in ('powershell -Command "Get-Date -Format yyyyMMdd_HHmmss" 2^>nul') do set "timestamp=%%a"

:: 修复点：安全遍历文件[处理特殊字符]
for /f "delims=" %%v in ('dir /b *.mkv *.mp4 *.avi 2^>nul') do (
    call :process_video "%%v" "manual"
)

echo 🏁 所有文件处理完成。
echo.
pause
goto main_menu

:: 视频处理子程序[以下部分保持不变]
:process_video
set "video=%~1"
set "mode=%~2"
set "basename=%~n1"
set "subtitle="
set "subext="

:: 修复点：清理文件名中的特殊字符
set "clean_name=!basename!"
set "clean_name=!clean_name:[=!"
set "clean_name=!clean_name:]=!"
set "clean_name=!clean_name:(=!"
set "clean_name=!clean_name:)=!"
set "basename=!clean_name!"

:: 查找字幕
if exist "!basename!.ass" (
    set "subtitle=!basename!.ass"
    set "subext=ass"
) else if exist "!basename!.srt" (
    set "subtitle=!basename!.srt"
    set "subext=srt"
) else (
    echo ✈  跳过：未找到字幕 → %~1
    echo.
    goto :EOF
)

echo.
echo 🔎 处理视频：%~nx1
echo 📝 字幕文件：!subtitle!
echo 📄 字幕格式：.!subext!
echo.

:: 根据模式处理视频
if "!mode!"=="manual" goto manual_mode
if "!mode!"=="soft" goto soft_sub_batch
if "!mode!"=="hard" goto hard_sub_batch
if "!mode!"=="smart" goto smart_mode

:: 手动模式 - 用户选择处理方式
:manual_mode
set "choice="
:choose_format
echo 请选择字幕封装方式: 
echo.
echo   🥝 1. 封装为软字幕 [仅支持 .srt]
echo   🍆 2. 烧录为硬字幕 [支持 .srt 和 .ass]
echo   🧨 C. 取消处理该视频
echo.
set /p "choice=你的选择[1/2/C，按Enter确认] :"

if /i "!choice!"=="1" goto :soft_sub
if /i "!choice!"=="2" goto :hard_sub
if /i "!choice!"=="C" goto :CANCEL_CURRENT
echo.
echo ❌ 无效输入，请重新选择。
goto choose_format

:: 批量软字幕处理
:soft_sub_batch
echo 🚀 自动处理：全部封装为软字幕
echo.
if /i "!subext!"=="srt" (
    goto :soft_sub
) else (
    echo 🔥 字幕是 .ass 格式，自动转换为 .srt
    goto :convert_ass_to_srt
)
goto :process_end

:: 批量硬字幕处理
:hard_sub_batch
echo 🚀 自动处理：全部烧录为硬字幕
echo.
goto :hard_sub

:: 智能模式处理
:smart_mode 
echo 🚀 自动处理：智能模式 [srt--软字幕, ass--硬字幕]
echo.
if /i "!subext!"=="srt" (
    goto :soft_sub
) else (
    goto :hard_sub
)
goto :process_end

:: 软字幕处理 
:soft_sub
if /i "!subext!"=="srt" (
    :: 修改点：输出到output文件夹
    set "output=output\!basename!_soft_!timestamp!.mp4"
    echo 🔧 正在封装软字幕[可能需要几分钟]...
    :: ffmpeg -i "!video!" -i "!subtitle!" -c copy -c:s mov_text "!output!" > nul 2>&1
    ffmpeg -i "!video!" -i "!subtitle!" -c copy -c:s mov_text "!output!"
    echo.
    echo ✅ 输出文件：!output!
    goto :process_end
)
set "confirm="
:confirm_convert
echo.
echo   🔥 你选择了软字幕，但字幕是 .ass 格式
echo      是否将 .ass 转换为 .srt 并继续？[Y/N]
echo.
set /p "confirm=确认[Y/N，按Enter确认]："
if /i "!confirm!"=="Y" (
    goto :convert_ass_to_srt
) 
if /i "!confirm!"=="N" goto :choose_format
echo.
echo ❌ 无效输入，请输入 Y 或 N。
goto confirm_convert

:: 转换ASS到SRT
:convert_ass_to_srt
set "srtfile=!basename!_converted_!timestamp!.srt"
echo 🔧 正在转换字幕格式[可能需要几分钟]...
:: ffmpeg -i "!subtitle!" "!srtfile!" > nul 2>&1
ffmpeg -i "!subtitle!" "!srtfile!"
    :: 修改点：输出到output文件夹
    set "output=output\!basename!_soft_!timestamp!.mp4"
echo.
echo 🔁 已转换为 .srt：!srtfile!
echo 🔧 正在封装软字幕[可能需要几分钟]...
:: ffmpeg -i "!video!" -i "!srtfile!" -c copy -c:s mov_text "!output!" > nul 2>&1
:: ffmpeg -i "!video!" -i "!srtfile!" -c copy -c:s mov_text "!output!"
ffmpeg -i "!video!" -i "!srtfile!" -c:v copy -c:a copy -c:s mov_text "!output!"
echo.
echo ✅ 输出文件：!output!
goto :process_end

:: 硬字幕处理
:hard_sub
if /i "!subext!"=="ass" (
    set "filter=ass='!subtitle!'"
) else (
    set "filter=subtitles='!subtitle!'"
)
    :: 修改点：输出到output文件夹
    set "output=output\!basename!_hard_!timestamp!.mp4"
echo 🔧 正在烧录硬字幕[可能需要较长时间，请耐心等待]...
:: ffmpeg -i "!video!" -vf "!filter!" -c:a copy "!output!" > nul 2>&1
ffmpeg -i "!video!" -vf "!filter!" -c:a copy "!output!"
echo.
echo ✅ 输出文件：!output!
goto :process_end

:: 取消当前视频处理
:CANCEL_CURRENT
echo 提示: 已取消该视频处理。
goto :process_end

:: 处理结束
:process_end
echo.
echo ================================处理完成================================
echo.
goto :EOF