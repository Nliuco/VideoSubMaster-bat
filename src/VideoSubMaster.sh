#!/bin/bash
# ========================================================
# VideoSubMaster - 视频字幕处理大师 v1.0
# 功能：批量/手动处理视频字幕（软字幕封装/硬字幕烧录）
# 作者：[Pianone]
# 日期：2025-06-03 14:39 pm
# ========================================================

# 设置UTF-8编码
export LANG=en_US.UTF-8

# 创建输出目录（如果不存在）
if [ ! -d "output" ]; then
    mkdir -p "output" 2>/dev/null
fi

# 清屏函数
clear_screen() {
    clear
}

# 暂停函数
pause() {
    echo
    read -p "按Enter键继续..."
}

# 获取时间戳
get_timestamp() {
    date "+%Y%m%d_%H%M%S"
}

# 字符串转小写函数
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# 处理视频函数
process_video() {
    local video="$1"
    local mode="$2"
    local basename="${video%.*}"
    local subtitle=""
    local subext=""
    
    # 清理文件名中的特殊字符
    clean_name="$basename"
    clean_name="${clean_name//[/}"
    clean_name="${clean_name//]/}"
    clean_name="${clean_name//(/}"
    clean_name="${clean_name//)/}"
    basename="$clean_name"
    
    # 查找字幕
    if [ -f "${basename}.ass" ]; then
        subtitle="${basename}.ass"
        subext="ass"
    elif [ -f "${basename}.srt" ]; then
        subtitle="${basename}.srt"
        subext="srt"
    else
        echo "✈  跳过：未找到字幕 → $video"
        echo
        return
    fi
    
    echo
    echo "🔎 处理视频：$video"
    echo "📝 字幕文件：$subtitle"
    echo "📄 字幕格式：.$subext"
    echo
    
    # 根据模式处理视频
    case "$mode" in
        "manual")
            manual_mode "$video"
            ;;
        "soft")
            soft_sub_batch
            ;;
        "hard")
            hard_sub_batch
            ;;
        "smart")
            smart_mode
            ;;
    esac
}

# 手动模式 - 用户选择处理方式
manual_mode() {
    local choice=""
    local video_name="$1"
    
    while true; do
        echo
        echo "当前处理的视频[$video_name]"
        echo "请选择字幕封装方式: "
        echo
        echo "  🥝 1. 封装为软字幕 [仅支持 .srt]"
        echo "  🍆 2. 烧录为硬字幕 [支持 .srt 和 .ass]"
        echo "  🧨 C. 取消处理该视频"
        echo
        read -p "你的选择[1/2/C，按Enter确认] :" choice
        echo
        
        # 使用新的to_lower函数替换${choice,,}
        case "$(to_lower "$choice")" in
            "1")
                soft_sub
                break
                ;;
            "2")
                hard_sub
                break
                ;;
            "c")
                cancel_current
                break
                ;;
            *)
                echo
                echo "❌ 无效输入，请重新选择。"
                echo    
                ;;
        esac
    done
}

# 批量软字幕处理
soft_sub_batch() {
    echo "🚀 自动处理：全部封装为软字幕"
    echo
    
    # 使用新的to_lower函数替换${subext,,}
    if [ "$(to_lower "$subext")" = "srt" ]; then
        soft_sub
    else
        echo "🔥 字幕是 .ass 格式，自动转换为 .srt"
        convert_ass_to_srt
    fi
}

# 批量硬字幕处理
hard_sub_batch() {
    echo "🚀 自动处理：全部烧录为硬字幕"
    echo
    hard_sub
}

# 智能模式处理
smart_mode() {
    echo "🚀 自动处理：智能模式 [srt--软字幕, ass--硬字幕]"
    echo
    
    # 使用新的to_lower函数替换${subext,,}
    if [ "$(to_lower "$subext")" = "srt" ]; then
        soft_sub
    else
        hard_sub
    fi
}

# 软字幕处理
soft_sub() {
    # 使用新的to_lower函数替换${subext,,}
    if [ "$(to_lower "$subext")" = "srt" ]; then
        # 输出到output文件夹
        timestamp=$(get_timestamp)
        output="output/${basename}_soft_${timestamp}.mp4"
        echo "🔧 正在封装软字幕[可能需要几分钟]..."
        ffmpeg -i "$video" -i "$subtitle" -c copy -c:s mov_text "$output"
        echo
        echo "✅ 输出文件：$output"
        return
    fi
    
    local confirm=""
    while true; do
        echo
        echo "  🔥 你选择了软字幕，但字幕是 .ass 格式"
        echo "     是否将 .ass 转换为 .srt 并继续？[Y/N]"
        echo
        read -p "确认[Y/N，按Enter确认]：" confirm
        
        # 使用新的to_lower函数替换${confirm,,}
        case "$(to_lower "$confirm")" in
            "y")
                convert_ass_to_srt
                break
                ;;
            "n")
                manual_mode "$video"
                break
                ;;
            *)
                echo
                echo "❌ 无效输入，请输入 Y 或 N。"
                ;;
        esac
    done
}

# 转换ASS到SRT
convert_ass_to_srt() {
    timestamp=$(get_timestamp)
    srtfile="${basename}_converted_${timestamp}.srt"
    echo "🔧 正在转换字幕格式[可能需要几分钟]..."
    ffmpeg -i "$subtitle" "$srtfile"
    
    # 输出到output文件夹
    output="output/${basename}_soft_${timestamp}.mp4"
    echo
    echo "🔁 已转换为 .srt：$srtfile"
    echo "🔧 正在封装软字幕[可能需要几分钟]..."
    ffmpeg -i "$video" -i "$srtfile" -c:v copy -c:a copy -c:s mov_text "$output"
    echo
    echo "✅ 输出文件：$output"
}

# 硬字幕处理
hard_sub() {
    local filter
    timestamp=$(get_timestamp)
    
    # 使用新的to_lower函数替换${subext,,}
    if [ "$(to_lower "$subext")" = "ass" ]; then
        filter="ass='$subtitle'"
    else
        filter="subtitles='$subtitle'"
    fi
    
    # 输出到output文件夹
    output="output/${basename}_hard_${timestamp}.mp4"
    echo "🔧 正在烧录硬字幕[可能需要较长时间，请耐心等待]..."
    ffmpeg -i "$video" -vf "$filter" -c:a copy "$output"
    echo
    echo "✅ 输出文件：$output"
}

# 取消当前视频处理
cancel_current() {
    echo "提示: 已取消该视频处理。"
}

# 批量处理所有视频
batch_process() {
    clear_screen
    echo "📦 批量处理模式已启用"
    echo
    
    # 获取时间戳
    timestamp=$(get_timestamp)
    
    # 安全遍历文件
    for video in *.mkv *.mp4 *.avi; do
        # 检查文件是否存在（避免处理通配符本身）
        if [ -f "$video" ]; then
            process_video "$video" "$batch_mode"
        fi
    done
    
    echo "🏁 所有文件处理完成。"
    echo
    pause
    main_menu
}

# 手动处理模式
manual_process() {
    clear_screen
    echo "📋 手动处理模式已启用"
    echo
    echo "    tips: 🤔 硬字幕:  即为内嵌烧录字幕, 对视频每一帧进行处理, 耗时往往很长, 由于需实时解码视频流并重新编码"
    echo "                      消耗大量CPU/GPU算力, 但可以保留ass字幕样式，不过字幕会永久写入视频画面，不可移除 "
    echo "          😉 软字幕:  即为内封字幕, 实际上是添加 .srt字幕轨道, 几乎不占用计算资源, 若播放媒体支持, 字幕[可开/关]"
    echo "                      仅封装不重编码, 速度极快[秒级完成]"
    echo
    
    # 获取时间戳
    timestamp=$(get_timestamp)
    
    # 安全遍历文件
    for video in *.mkv *.mp4 *.avi; do
        # 检查文件是否存在（避免处理通配符本身）
        if [ -f "$video" ]; then
            process_video "$video" "manual"
        fi
    done
    
    echo "🏁 所有文件处理完成。"
    echo
    pause
    main_menu
}

# 自动处理模式菜单
auto_process_menu() {
    clear_screen
    echo "================================ 自动处理模式 ==============================================================="
    echo
    echo "    🚀🚀🚀                  请选择批量处理方式：                    🚀🚀🚀    "
    echo
    echo "    🐳🐳🐳    1. 全部封装为软字幕                                   🐳🐳🐳     "
    echo "    🐌🐌🐌    2. 全部封装为硬字幕                                   🐌🐌🐌    "
    echo "    🐙🐙🐙    3. 根据字幕类型智能处理 [srt--软字幕, ass--硬字幕]    🐙🐙🐙   "
    echo "    🦴🦴🦴    4. 返回主菜单                                         🦴🦴🦴        "
    echo
    echo "    tips: 🤔 硬字幕:  即为内嵌烧录字幕, 对视频每一帧进行处理, 耗时往往很长, 由于需实时解码视频流并重新编码"
    echo "                      消耗大量CPU/GPU算力, 但可以保留ass字幕样式，不过字幕会永久写入视频画面，不可移除 "
    echo "          😉 软字幕:  即为内封字幕, 实际上是添加 .srt字幕轨道, 几乎不占用计算资源, 若播放媒体支持, 字幕[可开/关]"
    echo "                      仅封装不重编码, 速度极快[秒级完成]"
    echo
    echo "=============================================================================================================="
    echo
    
    local auto_choice
    read -p "请输入选项数字 [1-4]：" auto_choice
    
    case "$auto_choice" in
        "1")
            batch_mode="soft"
            batch_process
            ;;
        "2")
            batch_mode="hard"
            batch_process
            ;;
        "3")
            batch_mode="smart"
            batch_process
            ;;
        "4")
            main_menu
            ;;
        *)
            echo
            echo "❌ 无效输入，请重新输入！"
            sleep 2
            auto_process_menu
            ;;
    esac
}

# 主菜单函数
main_menu() {
    clear_screen
    echo "===================== 视频字幕处理大师 v1.0 ====================="
    echo
    echo
    echo "    🚀🚀🚀            请选择操作模式：           🚀🚀🚀    "
    echo
    echo "    🕹 🕹 🕹    1. 自动处理模式[批量处理所有视频]   🕹 🕹 🕹 "
    echo "    ✏ ✏ ✏    2. 手动处理模式[逐个处理视频]       ✏ ✏ ✏ "
    echo "    ⛩ ⛩ ⛩    0. 退出程序                         ⛩ ⛩ ⛩ "
    echo
    echo "================================================================="
    echo
    
    local menu_choice
    read -p "请输入选项数字 [0-2]：" menu_choice
    
    case "$menu_choice" in
        "1")
            auto_process_menu
            ;;
        "2")
            manual_process
            ;;
        "0")
            exit 0
            ;;
        *)
            echo
            echo "❌ 无效输入，请重新输入！"
            sleep 2
            main_menu
            ;;
    esac
}

# 启动主菜单
main_menu