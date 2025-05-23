import 'package:antmap_mvp/utils/theme_config.dart';
import 'package:flutter/material.dart';

class MultipleMediaBubble extends StatelessWidget {
  final List<String> mediaFiles;
  final bool isMe;
  final bool isDarkMode;
  final Function(String)? onMediaTap;

  const MultipleMediaBubble({
    required this.mediaFiles,
    required this.isMe,
    required this.isDarkMode,
    this.onMediaTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDarkMode ? AppTheme.darkColors : AppTheme.lightColors;
    final displayCount = mediaFiles.length > 4 ? 4 : mediaFiles.length;
    final remainingCount = mediaFiles.length - 4;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isMe ? colors.senderBubbleBackground : colors.receiverBubbleBackground,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          // Media grid
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: _buildMediaGrid(displayCount, remainingCount),
            ),
          ),
          
          // Download indicator
          if (mediaFiles.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.download,
                    size: 16,
                    color: (isMe ? colors.senderBubbleText : colors.receiverBubbleText)
                        .withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mediaFiles.length}+ files to download',
                    style: TextStyle(
                      color: (isMe ? colors.senderBubbleText : colors.receiverBubbleText)
                          .withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(int displayCount, int remainingCount) {
    if (displayCount == 1) {
      return _buildMediaItem(mediaFiles[0], null);
    } else if (displayCount == 2) {
      return Row(
        children: [
          Expanded(child: _buildMediaItem(mediaFiles[0], null)),
          const SizedBox(width: 2),
          Expanded(child: _buildMediaItem(mediaFiles[1], null)),
        ],
      );
    } else if (displayCount == 3) {
      return Row(
        children: [
          Expanded(
            child: _buildMediaItem(mediaFiles[0], null),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildMediaItem(mediaFiles[1], null)),
                const SizedBox(height: 2),
                Expanded(child: _buildMediaItem(mediaFiles[2], null)),
              ],
            ),
          ),
        ],
      );
    } else {
      // 4 or more items
      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildMediaItem(mediaFiles[0], null)),
                const SizedBox(height: 2),
                Expanded(child: _buildMediaItem(mediaFiles[2], null)),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildMediaItem(mediaFiles[1], null)),
                const SizedBox(height: 2),
                Expanded(
                  child: _buildMediaItem(
                    mediaFiles[3],
                    remainingCount > 0 ? '+$remainingCount' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMediaItem(String mediaPath, String? overlayText) {
    return GestureDetector(
      onTap: () => onMediaTap?.call(mediaPath),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media content
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _isVideo(mediaPath)
                  ? _buildVideoThumbnail(mediaPath)
                  : Image.asset(
                      mediaPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
            ),
            
            // Video play icon
            if (_isVideo(mediaPath))
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            
            // Overlay for remaining count
            if (overlayText != null)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text(
                    overlayText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoPath) {
    // In a real app, you would generate a thumbnail from the video
    // For now, we'll use a placeholder
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.videocam,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  bool _isVideo(String mediaPath) {
    final extension = mediaPath.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }
}
