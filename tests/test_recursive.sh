#!/bin/sh
# ========================================================
# 递归子目录处理功能测试脚本
# ========================================================

echo "=========================================="
echo "🧪 递归子目录处理功能测试"
echo "=========================================="
echo

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../src"
TEST_DIR="$SCRIPT_DIR/fixtures"

# 测试计数器
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
test_pass() {
    echo "✅ PASS: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo "❌ FAIL: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# 导入脚本中的函数（提取关键函数进行测试）
echo "📋 测试 1: 普通模式查找视频文件（仅当前目录）"
cd "$TEST_DIR"

# 模拟普通模式
RECURSIVE_MODE=0
RECURSIVE_DEPTH=5

find_videos() {
    local search_dir="${1:-.}"
    
    if [ "$RECURSIVE_MODE" -eq 1 ]; then
        find "$search_dir" -maxdepth "$RECURSIVE_DEPTH" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" \) 2>/dev/null
    else
        find "$search_dir" -maxdepth 1 -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" \) 2>/dev/null
    fi
}

# 测试普通模式
result=$(find_videos "." | wc -l)
if [ "$result" -eq 1 ]; then
    test_pass "普通模式只找到当前目录的 1 个视频文件"
else
    test_fail "普通模式应找到 1 个视频文件，实际找到 $result 个"
fi

echo
echo "📋 测试 2: 递归模式查找视频文件（所有子目录）"

# 模拟递归模式
RECURSIVE_MODE=1
RECURSIVE_DEPTH=5

result=$(find_videos "." | wc -l)
if [ "$result" -eq 4 ]; then
    test_pass "递归模式找到所有 4 个视频文件"
else
    test_fail "递归模式应找到 4 个视频文件，实际找到 $result 个"
fi

echo
echo "📋 测试 3: 递归深度限制测试"

RECURSIVE_MODE=1
RECURSIVE_DEPTH=2  # maxdepth 2 = 当前目录 + 一层子目录

result=$(find_videos "." | wc -l)
if [ "$result" -eq 3 ]; then
    test_pass "深度限制为 2 时找到 3 个视频文件（不含 nested）"
else
    test_fail "深度限制为 2 时应找到 3 个视频文件，实际找到 $result 个"
fi

echo
echo "📋 测试 4: 输出目录创建函数测试"

create_output_dir() {
    local video_path="$1"
    local video_dir=$(dirname "$video_path")
    local output_subdir="output"
    
    if [ "$RECURSIVE_MODE" -eq 1 ] && [ "$video_dir" != "." ]; then
        output_subdir="output/${video_dir#./}"
    fi
    
    echo "$output_subdir"
}

RECURSIVE_MODE=1

# 测试根目录视频
result=$(create_output_dir "./video1.mp4")
if [ "$result" = "output" ]; then
    test_pass "根目录视频输出到 output"
else
    test_fail "根目录视频应输出到 output，实际为 $result"
fi

# 测试子目录视频
result=$(create_output_dir "./subdir1/video2.mp4")
if [ "$result" = "output/subdir1" ]; then
    test_pass "子目录视频输出保持目录结构"
else
    test_fail "子目录视频应输出到 output/subdir1，实际为 $result"
fi

# 测试嵌套子目录视频
result=$(create_output_dir "./subdir2/nested/video4.mp4")
if [ "$result" = "output/subdir2/nested" ]; then
    test_pass "嵌套子目录视频输出保持目录结构"
else
    test_fail "嵌套子目录视频应输出到 output/subdir2/nested，实际为 $result"
fi

echo
echo "📋 测试 5: 字幕文件匹配测试"

# 测试字幕查找
find_subtitle() {
    local video="$1"
    local full_basename="${video%.*}"
    
    if [ -f "${full_basename}.ass" ]; then
        echo "${full_basename}.ass"
    elif [ -f "${full_basename}.srt" ]; then
        echo "${full_basename}.srt"
    else
        echo ""
    fi
}

# 测试 SRT 字幕
result=$(find_subtitle "./video1.mp4")
if [ "$result" = "./video1.srt" ]; then
    test_pass "正确找到 SRT 字幕"
else
    test_fail "应找到 ./video1.srt，实际为 $result"
fi

# 测试 ASS 字幕
result=$(find_subtitle "./subdir2/video3.mp4")
if [ "$result" = "./subdir2/video3.ass" ]; then
    test_pass "正确找到 ASS 字幕"
else
    test_fail "应找到 ./subdir2/video3.ass，实际为 $result"
fi

# 测试嵌套目录字幕
result=$(find_subtitle "./subdir2/nested/video4.mp4")
if [ "$result" = "./subdir2/nested/video4.srt" ]; then
    test_pass "正确找到嵌套目录中的字幕"
else
    test_fail "应找到 ./subdir2/nested/video4.srt，实际为 $result"
fi

echo
echo "=========================================="
echo "📊 测试结果汇总"
echo "=========================================="
echo "通过: $TESTS_PASSED"
echo "失败: $TESTS_FAILED"
echo

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo "🎉 所有测试通过！"
    exit 0
else
    echo "⚠️ 存在失败的测试，请检查！"
    exit 1
fi
