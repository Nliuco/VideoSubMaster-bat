# VideoSubMaster - Cross-Platform Subtitle Processor

![Batch Processing](https://img.shields.io/badge/Batch-Processing-blue)
![FFmpeg](https://img.shields.io/badge/Powered%20by-FFmpeg-orange)
![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey)
![Linux](https://img.shields.io/badge/Platform-Linux-success)
![MacOS](https://img.shields.io/badge/Platform-MacOS-silver)

**Now supporting Windows, Linux and macOS!** VideoSubMaster is a powerful script that automates subtitle embedding and burning for video files across multiple platforms. Designed for content creators and media archivists, it provides intelligent processing of SRT and ASS subtitle formats with both batch and manual operation modes.

## ✨ Key Features

- **Cross-Platform Support**: Run on Windows (Batch), Linux/macOS (Bash)
- **Dual Processing Modes**:
  - 🚀 **Soft Embedding**: Fast container-level subtitle embedding (preserves quality)
  - 🔥 **Hard Burning**: Full video re-encoding with burned-in subtitles
- **Intelligent Format Handling**:
  - Auto-converts ASS to SRT when needed
  - Smart mode: SRT → soft embedding, ASS → hard burning
- **Special Character Support**: Handles complex filenames with brackets/spaces
- **Organized Output**: Automatically saves processed files in `/output` folder
- **User-Friendly Interface**: Menu-driven workflow with visual feedback

## ⚙️ System Requirements

| Platform | Requirements |
|----------|--------------|
| **Windows** | 1. Windows 10/11<br>2. [FFmpeg](https://ffmpeg.org/) in PATH<br>3. PowerShell access |
| **Linux/macOS** | 1. Bash shell<br>2. [FFmpeg](https://ffmpeg.org/) installed<br>3. Coreutils (standard on most systems) |

## 🚀 Getting Started

### Installation
```bash
git clone https://github.com/yourusername/VideoSubMaster.git
cd VideoSubMaster
```

### Usage
1. Place your video files (.mkv, .mp4, .avi) in the script directory
2. Place matching subtitle files (.srt, .ass) with same base filename
3. Run the script:
   ```bash
   # Windows
   VideoSubMaster.bat
   
   # Linux/macOS (make executable first)
   chmod +x VideoSubMaster.sh
   ./VideoSubMaster.sh
   ```

### Workflow Options
```
===================== Video Subtitle Master =====================

  1. Auto Processing Mode [Batch Process All Videos]
  2. Manual Processing Mode [Process Videos Individually]
  0. Exit Program
```

**Auto Mode Options**:
```
  1. Embed all as soft subtitles
  2. Burn all as hard subtitles
  3. Smart processing [SRT→soft, ASS→hard]
  4. Return to main menu
```

## 📂 File Structure

| File/Folder          | Description                          | Platform       |
|----------------------|--------------------------------------|----------------|
| `VideoSubMaster.bat` | Main processing script               | Windows        |
| `VideoSubMaster.sh`  | Main processing script               | Linux/macOS    |
| `/output`            | Processed video files (auto-created) | All platforms  |
| `*.srt/ass`          | Subtitle files (match video names)   | All platforms  |

## ⏱️ Performance Comparison

| Process Type   | Speed       | Quality Preservation | Output Size     |
| -------------- | ----------- | -------------------- | --------------- |
| Soft Subtitles | ⚡ Very Fast | ✅ Original Quality  | Slightly Larger |
| Hard Subtitles | ⏳ Slower    | ⚠️ Re-encoded        | Variable        |

> **Note**: Hard subtitle processing time depends on video resolution, length, and hardware capabilities.

## 🌟 Platform-Specific Notes

### Windows
- Requires PowerShell for timestamp generation
- Best performance on Windows 10/11

### Linux/macOS
- Requires execution permission: `chmod +x VideoSubMaster.sh`
- Tested on Ubuntu 20.04+ and macOS Big Sur+
- Uses `date` command for timestamp generation

## ❓ Frequently Asked Questions

**Q: Why is soft subtitle processing faster?**  
A: Soft embedding only modifies the container without video re-encoding, while hard burning requires full video processing.

**Q: How do I install FFmpeg on Linux/macOS?**  
```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# macOS (Homebrew)
brew install ffmpeg
```

**Q: Can I process videos in subfolders?**  
A: The current version only processes files in the script directory. For recursive processing, modify the file search commands.

**Q: Why do I get "Permission denied" on Linux/macOS?**  
A: Run `chmod +x VideoSubMaster.sh` to make the script executable.

## 🤝 Contributing

We welcome contributions for all platforms! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a pull request

**Platform Contribution Guidelines**:
- Keep Windows (BAT) and Unix (Bash) implementations consistent
- Maintain cross-platform file and directory structure
- Use platform-neutral terminology in documentation

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Subtitle Processing!** 🎬✨  
For support, open an issue on GitHub.