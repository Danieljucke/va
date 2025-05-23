import 'package:antmap_mvp/utils/theme_config.dart';
import 'package:flutter/material.dart';

class VideoMessageBubble extends StatelessWidget {
  final String videoPath;
  final String? thumbnailPath;
  final bool isMe;
  final bool isDarkMode;
  final int? downloadCount;

  const VideoMessageBubble({
    required this.videoPath,
    this.thumbnailPath,
    required this.isMe,
    required this.isDarkMode,
    this.downloadCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDarkMode ? AppTheme.darkColors : AppTheme.lightColors;
    
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isMe ? colors.senderBubbleBackground : colors.receiverBubbleBackground,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: thumbnailPath != null
                ? Image.asset(
                    thumbnailPath!,
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.videocam,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),
          // Play button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Color(0xFFCC7722),
              size: 30,
            ),
          ),
          // Download count indicator
          if (downloadCount != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$downloadCount+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}