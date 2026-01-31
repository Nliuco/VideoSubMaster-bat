# VideoSubMaster 扩展性功能提案

> 📅 创建日期: 2025年  
> 🔖 状态: 提案阶段 (Draft)  
> 🌿 分支: feature/extensibility-proposals

---

## 📋 目录

1. [提案概述](#提案概述)
2. [功能提案列表](#功能提案列表)
   - [P1: 递归子目录处理](#p1-递归子目录处理)
   - [P2: 多字幕轨道支持](#p2-多字幕轨道支持)
   - [P3: 字幕样式自定义](#p3-字幕样式自定义)
   - [P4: 配置文件支持](#p4-配置文件支持)
   - [P5: 日志记录系统](#p5-日志记录系统)
   - [P6: 进度显示与预估](#p6-进度显示与预估)
   - [P7: 字幕预览功能](#p7-字幕预览功能)
   - [P8: 批量重命名工具](#p8-批量重命名工具)
3. [实现优先级](#实现优先级)
4. [技术考量](#技术考量)

---

## 提案概述

本文档提出了一系列扩展性功能，旨在增强 VideoSubMaster 的实用性和用户体验。这些提案基于以下原则：

- 🎯 **实用性**: 解决用户实际痛点
- 🔄 **兼容性**: 保持跨平台一致性 (Windows/Linux/macOS)
- 🧩 **模块化**: 功能可独立启用/禁用
- 📈 **可扩展**: 为未来发展留有空间

---

## 功能提案列表

### P1: 递归子目录处理

**优先级**: ⭐⭐⭐⭐⭐ (高)

#### 问题描述
当前版本仅处理脚本所在目录的文件，用户需要手动将文件移动到脚本目录，或多次运行脚本处理不同文件夹。

#### 提议功能
- 添加递归扫描选项，自动发现所有子目录中的视频和字幕文件
- 保持原有目录结构在输出文件夹中
- 可配置扫描深度限制

#### 预期实现

```bash
# 新增菜单选项
echo "  3. 递归处理模式 [处理所有子目录]"

# 递归查找函数
find_videos_recursive() {
    local max_depth="${1:-5}"  # 默认最大深度5
    find . -maxdepth "$max_depth" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \)
}
```

#### 影响范围
- `batch_process()` 函数
- `manual_process()` 函数  
- 输出路径生成逻辑

---

### P2: 多字幕轨道支持

**优先级**: ⭐⭐⭐⭐ (中高)

#### 问题描述
当前只支持单字幕文件，无法处理多语言字幕场景（如同时有中文和英文字幕）。

#### 提议功能
- 支持同时封装多个字幕轨道
- 自动识别字幕语言（基于文件名或内容检测）
- 设置默认字幕轨道

#### 预期实现

```bash
# 多字幕文件检测
find_all_subtitles() {
    local basename="$1"
    local subs=()
    
    # 查找所有匹配的字幕文件
    for sub in "${basename}"*.srt "${basename}"*.ass; do
        [ -f "$sub" ] && subs+=("$sub")
    done
    
    echo "${subs[@]}"
}

# FFmpeg 多轨道封装
# ffmpeg -i video.mp4 -i sub_zh.srt -i sub_en.srt \
#        -map 0:v -map 0:a -map 1 -map 2 \
#        -c copy -c:s mov_text \
#        -metadata:s:s:0 language=chi \
#        -metadata:s:s:1 language=eng \
#        output.mp4
```

#### 文件命名约定
| 命名模式 | 语言 |
|---------|------|
| `video.zh.srt` | 中文 |
| `video.en.srt` | 英文 |
| `video.ja.srt` | 日文 |
| `video.chs.srt` | 简体中文 |
| `video.cht.srt` | 繁体中文 |

---

### P3: 字幕样式自定义

**优先级**: ⭐⭐⭐ (中)

#### 问题描述
硬字幕烧录时使用默认样式，用户可能需要自定义字体、大小、颜色、位置等。

#### 提议功能
- 预设样式模板（标准、电影、动漫等）
- 自定义字体/大小/颜色
- 字幕位置调整（上/中/下）
- 描边和阴影设置

#### 预期实现

```bash
# 样式配置
SUBTITLE_STYLES=(
    "standard:FontSize=24,OutlineColour=&H40000000,BorderStyle=3"
    "movie:FontSize=22,OutlineColour=&H80000000,BorderStyle=1,MarginV=30"
    "anime:FontSize=28,PrimaryColour=&HFFFFFF,OutlineColour=&H000000,BorderStyle=3"
)

# 字幕样式菜单
select_subtitle_style() {
    echo "选择字幕样式:"
    echo "  1. 标准 (Standard)"
    echo "  2. 电影 (Movie)"
    echo "  3. 动漫 (Anime)"
    echo "  4. 自定义 (Custom)"
}

# FFmpeg 样式应用
# ffmpeg -i video.mp4 -vf "subtitles=sub.srt:force_style='FontSize=24,Outline=1'" output.mp4
```

---

### P4: 配置文件支持

**优先级**: ⭐⭐⭐⭐ (中高)

#### 问题描述
每次运行都需要手动选择选项，无法保存用户偏好设置。

#### 提议功能
- 创建配置文件 (`videosubmaster.conf`)
- 保存默认处理模式、输出路径、编码参数等
- 支持项目级和全局级配置

#### 预期配置文件格式

```ini
# VideoSubMaster 配置文件
# ~/.videosubmaster.conf 或 ./videosubmaster.conf

[general]
# 默认处理模式: soft | hard | smart | manual
default_mode=smart

# 输出目录 (相对或绝对路径)
output_dir=./output

# 递归处理深度 (0=禁用递归)
recursive_depth=0

[encoding]
# 视频编码器: libx264 | libx265 | copy
video_codec=libx264

# 视频质量 (CRF值, 越小质量越好)
video_quality=23

# 音频编码器: aac | copy
audio_codec=copy

[subtitle]
# 默认字幕样式
default_style=standard

# 字幕字体
font_name=Arial

# 字幕大小
font_size=24

[logging]
# 启用日志: true | false
enabled=true

# 日志文件路径
log_file=./videosubmaster.log

# 日志级别: debug | info | warn | error
log_level=info
```

#### 实现代码

```bash
# 加载配置
load_config() {
    local config_file="${1:-videosubmaster.conf}"
    
    if [ -f "$config_file" ]; then
        source "$config_file"
        echo "✅ 已加载配置: $config_file"
    elif [ -f "$HOME/.videosubmaster.conf" ]; then
        source "$HOME/.videosubmaster.conf"
        echo "✅ 已加载全局配置"
    fi
}
```

---

### P5: 日志记录系统

**优先级**: ⭐⭐⭐ (中)

#### 问题描述
处理大量文件时，难以追踪哪些文件成功/失败，以及失败原因。

#### 提议功能
- 详细的处理日志记录
- 分级日志（DEBUG/INFO/WARN/ERROR）
- 处理结果汇总报告
- 支持日志轮转

#### 预期日志格式

```
[2025-01-15 14:30:25] [INFO] VideoSubMaster v1.0 启动
[2025-01-15 14:30:25] [INFO] 扫描视频文件...
[2025-01-15 14:30:26] [INFO] 发现 15 个视频文件
[2025-01-15 14:30:26] [INFO] 处理: movie01.mp4
[2025-01-15 14:30:26] [INFO]   └─ 字幕: movie01.srt (SRT格式)
[2025-01-15 14:30:28] [INFO]   └─ 完成: output/movie01_soft_20250115_143028.mp4
[2025-01-15 14:30:28] [WARN] 处理: movie02.mp4
[2025-01-15 14:30:28] [WARN]   └─ 跳过: 未找到匹配字幕
[2025-01-15 14:35:00] [INFO] ========== 处理汇总 ==========
[2025-01-15 14:35:00] [INFO] 总计: 15 | 成功: 13 | 跳过: 2 | 失败: 0
```

#### 实现代码

```bash
# 日志级别定义
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# 当前日志级别
CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_line="[$timestamp] [$level] $message"
    
    # 输出到控制台
    echo "$log_line"
    
    # 写入日志文件
    [ -n "$LOG_FILE" ] && echo "$log_line" >> "$LOG_FILE"
}

log_info()  { log "INFO" "$1"; }
log_warn()  { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }
log_debug() { [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_DEBUG ] && log "DEBUG" "$1"; }
```

---

### P6: 进度显示与预估

**优先级**: ⭐⭐⭐ (中)

#### 问题描述
硬字幕烧录时间较长，用户无法了解处理进度和剩余时间。

#### 提议功能
- 实时显示处理进度百分比
- 预估剩余时间
- 当前帧/总帧数显示
- 处理速度 (FPS) 显示

#### 预期实现

```bash
# 使用 FFmpeg 的 -progress 参数
process_with_progress() {
    local input="$1"
    local output="$2"
    local filter="$3"
    
    # 获取视频总时长（秒）
    local duration=$(ffprobe -v error -show_entries format=duration \
                    -of default=noprint_wrappers=1:nokey=1 "$input")
    
    # 使用管道获取进度
    ffmpeg -i "$input" -vf "$filter" -c:a copy "$output" \
           -progress pipe:1 2>/dev/null | \
    while read line; do
        if [[ "$line" == out_time_ms=* ]]; then
            local current_ms="${line#out_time_ms=}"
            local current_sec=$((current_ms / 1000000))
            local progress=$((current_sec * 100 / ${duration%.*}))
            
            # 显示进度条
            printf "\r[%-50s] %d%%" $(printf '#%.0s' $(seq 1 $((progress/2)))) $progress
        fi
    done
    echo
}
```

#### 进度显示效果
```
🔧 正在烧录硬字幕...
[########################--------------------------] 48%
⏱  预估剩余时间: 5分32秒 | 速度: 24.5 fps
```

---

### P7: 字幕预览功能

**优先级**: ⭐⭐ (低)

#### 问题描述
用户在烧录硬字幕前无法预览最终效果，可能导致样式不满意需要重新处理。

#### 提议功能
- 生成短片段预览（如前30秒）
- 快速预览不同样式效果
- 使用 FFplay 即时预览（如果可用）

#### 预期实现

```bash
# 生成预览片段
generate_preview() {
    local video="$1"
    local subtitle="$2"
    local duration="${3:-30}"  # 默认30秒
    local preview_file="preview_${basename}.mp4"
    
    echo "🔍 生成预览片段 (${duration}秒)..."
    ffmpeg -i "$video" -t "$duration" -vf "subtitles=$subtitle" \
           -c:a copy "$preview_file"
    
    echo "✅ 预览文件: $preview_file"
    
    # 如果有 FFplay，自动播放
    if command -v ffplay &> /dev/null; then
        read -p "是否立即播放预览? [Y/n]: " play_choice
        [ "${play_choice,,}" != "n" ] && ffplay -autoexit "$preview_file"
    fi
}
```

---

### P8: 批量重命名工具

**优先级**: ⭐⭐ (低)

#### 问题描述
视频和字幕文件名不匹配是常见问题，用户需要手动重命名才能处理。

#### 提议功能
- 智能匹配视频和字幕文件（基于相似度）
- 交互式确认重命名
- 批量重命名预览
- 支持正则表达式模式

#### 预期实现

```bash
# 字幕匹配建议
suggest_subtitle_matches() {
    echo "🔍 检测到以下视频没有匹配的字幕:"
    echo
    
    for video in *.mkv *.mp4 *.avi; do
        [ -f "$video" ] || continue
        local basename="${video%.*}"
        
        # 检查是否有匹配字幕
        if [ ! -f "${basename}.srt" ] && [ ! -f "${basename}.ass" ]; then
            echo "  ❌ $video"
            
            # 查找可能匹配的字幕
            echo "     可能的字幕文件:"
            for sub in *.srt *.ass; do
                [ -f "$sub" ] || continue
                # 简单相似度匹配（可扩展为更复杂的算法）
                if [[ "$sub" == *"${basename:0:5}"* ]]; then
                    echo "       → $sub"
                fi
            done
            echo
        fi
    done
}

# 批量重命名
batch_rename() {
    echo "批量重命名工具"
    echo "==============="
    echo
    echo "输入重命名模式 (使用 {n} 表示序号):"
    echo "例如: Episode_{n} 将生成 Episode_01, Episode_02..."
    read -p "模式: " pattern
    
    local n=1
    for video in *.mkv *.mp4 *.avi; do
        [ -f "$video" ] || continue
        local ext="${video##*.}"
        local new_name="${pattern//\{n\}/$(printf '%02d' $n)}.$ext"
        echo "  $video → $new_name"
        ((n++))
    done
    
    read -p "确认重命名? [y/N]: " confirm
    [ "${confirm,,}" = "y" ] && echo "执行重命名..." || echo "已取消"
}
```

---

## 实现优先级

根据实用性、实现难度和用户需求，建议按以下顺序实现：

| 优先级 | 提案 | 预计工时 | 难度 |
|--------|------|----------|------|
| 1️⃣ | P1: 递归子目录处理 | 2-3小时 | ⭐⭐ |
| 2️⃣ | P4: 配置文件支持 | 3-4小时 | ⭐⭐ |
| 3️⃣ | P5: 日志记录系统 | 2-3小时 | ⭐⭐ |
| 4️⃣ | P2: 多字幕轨道支持 | 4-5小时 | ⭐⭐⭐ |
| 5️⃣ | P6: 进度显示与预估 | 3-4小时 | ⭐⭐⭐ |
| 6️⃣ | P3: 字幕样式自定义 | 4-5小时 | ⭐⭐⭐ |
| 7️⃣ | P8: 批量重命名工具 | 2-3小时 | ⭐⭐ |
| 8️⃣ | P7: 字幕预览功能 | 2-3小时 | ⭐⭐ |

---

## 技术考量

### 跨平台兼容性

所有新功能必须同时在 `.bat` (Windows) 和 `.sh` (Unix) 版本中实现，保持功能一致性。

#### Windows 特殊处理
- 使用 `PowerShell` 处理复杂字符串操作
- 路径分隔符使用 `\`
- 使用 `findstr` 替代 `grep`

#### Unix 特殊处理
- 确保 POSIX 兼容性
- 测试 Bash 3.x 和 4.x+
- 处理 macOS 和 Linux 的差异（如 `date` 命令）

### 向后兼容性

- 所有新功能应为可选项
- 默认行为保持与当前版本一致
- 配置文件缺失时使用合理默认值

### 测试计划

建议为每个新功能创建测试用例：

```bash
# 测试目录结构
tests/
├── test_recursive.sh      # 递归处理测试
├── test_multi_track.sh    # 多轨道测试
├── test_config.sh         # 配置文件测试
├── test_logging.sh        # 日志系统测试
└── fixtures/              # 测试数据
    ├── sample_video.mp4
    ├── sample.srt
    └── sample.ass
```

---

## 反馈与讨论

欢迎对以上提案提出意见和建议！您可以：

- 🐛 在 [Issues](../../issues) 中提出问题
- 💡 通过 [Discussions](../../discussions) 讨论新想法
- 🔀 提交 Pull Request 贡献代码

---

*此文档将随项目发展持续更新。*
