@echo off
setlocal enabledelayedexpansion

echo 📦 安全模式：批量视频字幕封装开始...
echo.

:: 时间戳函数（确保唯一输出）
for /f %%a in ('powershell -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "timestamp=%%a"

:: 遍历视频文件
for %%v in (*.mkv *.mp4 *.avi) do (
    set "video=%%v"
    set "basename=%%~nv"
    set "subtitle="
    set "subext="

    :: 查找同名字幕
    if exist "%%~nv.ass" (
        set "subtitle=%%~nv.ass"
        set "subext=ass"
    ) else if exist "%%~nv.srt" (
        set "subtitle=%%~nv.srt"
        set "subext=srt"
    ) else (
        echo ⚠ 跳过：未找到字幕 → %%v
        echo.
        continue
    )

    echo 🔎 处理视频：%%v
    echo 📝 字幕文件：!subtitle!
    echo 📄 字幕格式：.!subext!

    :CHOOSE_FORMAT
    echo 请选择字幕封装方式：
    echo   1. 封装为软字幕（仅支持 .srt）
    echo   2. 烧录为硬字幕（支持 .srt 和 .ass）
    echo   C. 取消处理该视频
    set /p "choice=你的选择（1/2/C）："

    if /i "!choice!"=="1" (
        if /i "!subext!"=="srt" (
            set "output=!basename!_soft_!timestamp!.mp4"
            echo 🔧 封装软字幕中：!video! + !subtitle!
            ffmpeg -i "!video!" -i "!subtitle!" -c copy -c:s mov_text "!output!"
            echo ✅ 输出文件：!output!"
        ) else (
            echo ⚠️ 你选择了软字幕，但字幕是 .ass 格式
            :CONFIRM_CONVERT
            echo    是否将 .ass 转换为 .srt 并继续？（Y/N）
            set /p "confirm=确认转换（Y/N）："
            if /i "!confirm!"=="Y" (
                set "srtfile=!basename!_converted_!timestamp!.srt"
                ffmpeg -i "!subtitle!" "!srtfile!"
                set "output=!basename!_soft_!timestamp!.mp4"
                echo 🔁 已转换为 .srt：!srtfile!
                ffmpeg -i "!video!" -i "!srtfile!" -c copy -c:s mov_text "!output!"
                echo ✅ 输出文件：!output!"
            ) else if /i "!confirm!"=="N" (
                echo ⏭️ 已取消该视频处理。
                echo.
                goto :EOF
            ) else (
                echo ❌ 无效输入，请输入 Y 或 N。
                goto CONFIRM_CONVERT
            )
        )
    ) else if /i "!choice!"=="2" (
        if /i "!subext!"=="ass" (
            set "filter=ass='!subtitle!'"
        ) else (
            set "filter=subtitles='!subtitle!'"
        )
        set "output=!basename!_burned_!timestamp!.mp4"
        echo 🔧 开始烧录字幕：!video! + !subtitle!
        ffmpeg -i "!video!" -vf "!filter!" -c:a copy "!output!"
        echo ✅ 输出文件：!output!"
    ) else if /i "!choice!"=="C" (
        echo ⏭️ 已取消该视频处理。
        echo.
        goto :CONTINUE_LOOP
    ) else (
        echo ❌ 无效输入，请重新选择。
        goto CHOOSE_FORMAT
    )

    :CONTINUE_LOOP
    echo ----------------------------------------------------
    echo.
)

echo 🏁 所有文件处理完成。
pause
