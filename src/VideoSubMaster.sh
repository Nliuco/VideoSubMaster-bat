#!/bin/bash
# ========================================================
# VideoSubMaster - 视频字幕处理大师 v1.1
# 功能：批量/手动处理视频字幕（软字幕封装/硬字幕烧录）
# 新增：递归子目录处理功能
# 作者：[Pianone]
# 日期：2025-06-03 14:39 pm
# ========================================================

# 设置UTF-8编码
export LANG=en_US.UTF-8

# 全局变量
RECURSIVE_MODE=0        # 递归模式开关 (0=关闭, 1=开启)
RECURSIVE_DEPTH=5       # 递归深度限制
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"  # 脚本所在目录

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

# 递归查找视频文件函数
find_videos() {
    local search_dir="${1:-.}"
    
    if [ "$RECURSIVE_MODE" -eq 1 ]; then
        # 递归模式：查找所有子目录
        find "$search_dir" -maxdepth "$RECURSIVE_DEPTH" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" \) 2>/dev/null
    else
        # 普通模式：仅当前目录
        find "$search_dir" -maxdepth 1 -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" \) 2>/dev/null
    fi
}

# 创建输出目录（保持子目录结构）
create_output_dir() {
    local video_path="$1"
    local video_dir=$(dirname "$video_path")
    local output_subdir="output"
    
    if [ "$RECURSIVE_MODE" -eq 1 ] && [ "$video_dir" != "." ]; then
        # 递归模式下保持目录结构
        output_subdir="output/${video_dir#./}"
    fi
    
    mkdir -p "$output_subdir" 2>/dev/null
    echo "$output_subdir"
}

# 处理视频函数
process_video() {
    local video="$1"
    local mode="$2"
    local video_dir=$(dirname "$video")
    local video_filename=$(basename "$video")
    local basename_noext="${video_filename%.*}"
    local subtitle=""
    local subext=""
    
    # 完整路径的基础名（不含扩展名）
    local full_basename="${video%.*}"
    
    # 清理文件名中的特殊字符（仅用于显示）
    clean_name="$basename_noext"
    clean_name="${clean_name//[/}"
    clean_name="${clean_name//]/}"
    clean_name="${clean_name//(/}"
    clean_name="${clean_name//)/}"
    
    # 查找字幕（在视频所在目录查找）
    if [ -f "${full_basename}.ass" ]; then
        subtitle="${full_basename}.ass"
        subext="ass"
    elif [ -f "${full_basename}.srt" ]; then
        subtitle="${full_basename}.srt"
        subext="srt"
    else
        echo "✈  跳过：未找到字幕 → $video"
        echo
        return
    fi
    
    # 创建输出目录（递归模式下保持目录结构）
    output_dir=$(create_output_dir "$video")
    
    # 设置全局变量供其他函数使用
    current_video="$video"
    current_subtitle="$subtitle"
    current_subext="$subext"
    current_basename="$clean_name"
    current_output_dir="$output_dir"
    
    echo
    echo "🔎 处理视频：$video"
    echo "📝 字幕文件：$subtitle"
    echo "📄 字幕格式：.$subext"
    [ "$RECURSIVE_MODE" -eq 1 ] && echo "📂 输出目录：$output_dir"
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
    
    # 使用全局变量 current_subext
    if [ "$(to_lower "$current_subext")" = "srt" ]; then
        soft_sub
    else
        hard_sub
    fi
}

# 软字幕处理
soft_sub() {
    # 使用全局变量 current_subext
    if [ "$(to_lower "$current_subext")" = "srt" ]; then
        # 输出到对应目录（支持递归模式）
        timestamp=$(get_timestamp)
        output="${current_output_dir}/${current_basename}_soft_${timestamp}.mp4"
        echo "🔧 正在封装软字幕[可能需要几分钟]..."
        ffmpeg -i "$current_video" -i "$current_subtitle" -c copy -c:s mov_text "$output" -y
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
        
        case "$(to_lower "$confirm")" in
            "y")
                convert_ass_to_srt
                break
                ;;
            "n")
                manual_mode "$current_video"
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
    srtfile="${current_output_dir}/${current_basename}_converted_${timestamp}.srt"
    echo "🔧 正在转换字幕格式[可能需要几分钟]..."
    ffmpeg -i "$current_subtitle" "$srtfile" -y
    
    # 输出到对应目录（支持递归模式）
    output="${current_output_dir}/${current_basename}_soft_${timestamp}.mp4"
    echo
    echo "🔁 已转换为 .srt：$srtfile"
    echo "🔧 正在封装软字幕[可能需要几分钟]..."
    ffmpeg -i "$current_video" -i "$srtfile" -c:v copy -c:a copy -c:s mov_text "$output" -y
    echo
    echo "✅ 输出文件：$output"
}

# 硬字幕处理
hard_sub() {
    local filter
    timestamp=$(get_timestamp)
    
    # 使用全局变量 current_subext
    if [ "$(to_lower "$current_subext")" = "ass" ]; then
        filter="ass='$current_subtitle'"
    else
        filter="subtitles='$current_subtitle'"
    fi
    
    # 输出到对应目录（支持递归模式）
    output="${current_output_dir}/${current_basename}_hard_${timestamp}.mp4"
    echo "🔧 正在烧录硬字幕[可能需要较长时间，请耐心等待]..."
    ffmpeg -i "$current_video" -vf "$filter" -c:a copy "$output" -y
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
    
    if [ "$RECURSIVE_MODE" -eq 1 ]; then
        echo "📦 批量处理模式已启用 [递归模式 - 深度: $RECURSIVE_DEPTH]"
    else
        echo "📦 批量处理模式已启用"
    fi
    echo
    
    # 获取时间戳
    timestamp=$(get_timestamp)
    
    # 统计变量
    total_count=0
    processed_count=0
    
    # 使用临时文件存储视频列表（兼容 sh）
    tmp_file=$(mktemp)
    find_videos "." > "$tmp_file"
    
    while IFS= read -r video; do
        [ -z "$video" ] && continue
        total_count=$((total_count + 1))
        process_video "$video" "$batch_mode"
        processed_count=$((processed_count + 1))
    done < "$tmp_file"
    
    rm -f "$tmp_file"
    
    echo
    if [ "$total_count" -eq 0 ]; then
        echo "⚠️  未找到任何视频文件"
    else
        echo "🏁 所有文件处理完成。共处理 $processed_count 个视频。"
    fi
    echo
    pause
    main_menu
}

# 手动处理模式
manual_process() {
    clear_screen
    
    if [ "$RECURSIVE_MODE" -eq 1 ]; then
        echo "📋 手动处理模式已启用 [递归模式 - 深度: $RECURSIVE_DEPTH]"
    else
        echo "📋 手动处理模式已启用"
    fi
    echo
    echo "    tips: 🤔 硬字幕:  即为内嵌烧录字幕, 对视频每一帧进行处理, 耗时往往很长, 由于需实时解码视频流并重新编码"
    echo "                      消耗大量CPU/GPU算力, 但可以保留ass字幕样式，不过字幕会永久写入视频画面，不可移除 "
    echo "          😉 软字幕:  即为内封字幕, 实际上是添加 .srt字幕轨道, 几乎不占用计算资源, 若播放媒体支持, 字幕[可开/关]"
    echo "                      仅封装不重编码, 速度极快[秒级完成]"
    echo
    
    # 获取时间戳
    timestamp=$(get_timestamp)
    
    # 统计变量
    total_count=0
    processed_count=0
    
    # 使用临时文件存储视频列表（兼容 sh）
    tmp_file=$(mktemp)
    find_videos "." > "$tmp_file"
    
    while IFS= read -r video; do
        [ -z "$video" ] && continue
        total_count=$((total_count + 1))
        process_video "$video" "manual"
        processed_count=$((processed_count + 1))
    done < "$tmp_file"
    
    rm -f "$tmp_file"
    
    echo
    if [ "$total_count" -eq 0 ]; then
        echo "⚠️  未找到任何视频文件"
    else
        echo "🏁 所有文件处理完成。共处理 $processed_count 个视频。"
    fi
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

# 递归模式设置菜单
recursive_settings_menu() {
    clear_screen
    echo "===================== 递归处理设置 ====================="
    echo
    
    if [ "$RECURSIVE_MODE" -eq 1 ]; then
        echo "    当前状态: ✅ 已开启 (深度: $RECURSIVE_DEPTH)"
    else
        echo "    当前状态: ❌ 已关闭"
    fi
    echo
    echo "    1. 开启递归模式"
    echo "    2. 关闭递归模式"
    echo "    3. 设置递归深度 (当前: $RECURSIVE_DEPTH)"
    echo "    4. 返回主菜单"
    echo
    echo "========================================================="
    echo
    
    local choice
    read -p "请输入选项数字 [1-4]：" choice
    
    case "$choice" in
        "1")
            RECURSIVE_MODE=1
            echo
            echo "✅ 递归模式已开启"
            sleep 1
            recursive_settings_menu
            ;;
        "2")
            RECURSIVE_MODE=0
            echo
            echo "❌ 递归模式已关闭"
            sleep 1
            recursive_settings_menu
            ;;
        "3")
            echo
            read -p "请输入递归深度 (1-10，当前: $RECURSIVE_DEPTH)：" new_depth
            if [[ "$new_depth" =~ ^[0-9]+$ ]] && [ "$new_depth" -ge 1 ] && [ "$new_depth" -le 10 ]; then
                RECURSIVE_DEPTH=$new_depth
                echo "✅ 递归深度已设置为: $RECURSIVE_DEPTH"
            else
                echo "❌ 无效输入，请输入 1-10 之间的数字"
            fi
            sleep 1
            recursive_settings_menu
            ;;
        "4")
            main_menu
            ;;
        *)
            echo
            echo "❌ 无效输入，请重新输入！"
            sleep 1
            recursive_settings_menu
            ;;
    esac
}

# 主菜单函数
main_menu() {
    clear_screen
    echo "===================== 视频字幕处理大师 v1.1 ====================="
    echo
    
    # 显示递归模式状态
    if [ "$RECURSIVE_MODE" -eq 1 ]; then
        echo "    📂 递归模式: ✅ 已开启 (深度: $RECURSIVE_DEPTH)"
    else
        echo "    📂 递归模式: ❌ 已关闭"
    fi
    echo
    echo "    🚀🚀🚀            请选择操作模式：           🚀🚀🚀    "
    echo
    echo "    🕹 🕹 🕹    1. 自动处理模式[批量处理所有视频]   🕹 🕹 🕹 "
    echo "    ✏ ✏ ✏    2. 手动处理模式[逐个处理视频]       ✏ ✏ ✏ "
    echo "    📁📁📁    3. 递归模式设置[处理子目录]         📁📁📁 "
    echo "    ⛩ ⛩ ⛩    0. 退出程序                         ⛩ ⛩ ⛩ "
    echo
    echo "================================================================="
    echo
    
    local menu_choice
    read -p "请输入选项数字 [0-3]：" menu_choice
    
    case "$menu_choice" in
        "1")
            auto_process_menu
            ;;
        "2")
            manual_process
            ;;
        "3")
            recursive_settings_menu
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