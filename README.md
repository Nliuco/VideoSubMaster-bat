# VideoSubMaster - Intelligent Subtitle Processor

![Batch Processing](https://img.shields.io/badge/Batch-Processing-blue)
![FFmpeg](https://img.shields.io/badge/Powered%20by-FFmpeg-orange)
![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey)

VideoSubMaster is a powerful Windows batch script that automates subtitle embedding and burning for video files. Designed for content creators and media archivists, it provides intelligent processing of SRT and ASS subtitle formats with both batch and manual operation modes.

## ✨ Key Features

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

1. **Windows OS** (Tested on Windows 10/11)
2. **[FFmpeg](https://ffmpeg.org/)** installed and added to system PATH
3. PowerShell access (for timestamp generation)

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
   ```batch
   VideoSubMaster.bat
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

| File/Folder          | Description                          |
| -------------------- | ------------------------------------ |
| `VideoSubMaster.bat` | Main processing script               |
| `/output`            | Processed video files (auto-created) |
| `*.srt/ass`          | Subtitle files (match video names)   |

## ⏱️ Performance Comparison

| Process Type   | Speed       | Quality Preservation | Output Size     |
| -------------- | ----------- | -------------------- | --------------- |
| Soft Subtitles | ⚡ Very Fast | ✅ Original Quality   | Slightly Larger |
| Hard Subtitles | ⏳ Slower    | ⚠️ Re-encoded         | Variable        |

> **Note**: Hard subtitle processing time depends on video resolution, length, and hardware capabilities.

## ❓ Frequently Asked Questions

**Q: Why is soft subtitle processing faster?**  
A: Soft embedding only modifies the container without video re-encoding, while hard burning requires full video processing.

**Q: Can I process videos in subfolders?**  
A: The current version only processes files in the script directory. For recursive processing, modify the `dir /b` commands.

**Q: How do I verify FFmpeg installation?**  
A: Run `ffmpeg -version` in Command Prompt. If not recognized, [download FFmpeg](https://ffmpeg.org/download.html) and add to PATH.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a pull request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Subtitle Processing!** 🎬✨  
For support, open an issue on GitHub.
