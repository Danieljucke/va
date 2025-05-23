import 'package:antmap_mvp/models/chat.dart';
import 'package:antmap_mvp/utils/theme_config.dart';
import 'package:antmap_mvp/widgets/chat/AudioWaveformBubble.dart';
import 'package:antmap_mvp/widgets/chat/message/contact_message_bubble.dart';
import 'package:antmap_mvp/widgets/chat/message/file_message_bubble.dart';
import 'package:antmap_mvp/widgets/chat/message/link_message_bubble.dart';
import 'package:antmap_mvp/widgets/chat/message/location_message_bubble.dart';
import 'package:antmap_mvp/widgets/chat/message/multiple_media_bubble.dart';
import 'package:antmap_mvp/widgets/chat/message/video_message_bubble.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool isDarkMode;
  final bool isGroupChat;
  final Function(ChatMessage) onMessageAction;

  const MessageItem({
    super.key,
    required this.message,
    required this.isDarkMode,
    required this.isGroupChat,
    required this.onMessageAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && !message.isMe) {
          // Swipe right sur un message reçu
          onMessageAction(message);
        } else if (details.primaryVelocity! < 0 && message.isMe) {
          // Swipe left sur un message envoyé
          onMessageAction(message);
        }
      },
      onLongPress: () {
        onMessageAction(message);
      },
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // Afficher l'avatar de l'expéditeur si c'est un message reçu et qu'il s'agit d'un groupe
              if (!message.isMe && isGroupChat)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage("assets/images/profil_pictures/avatar${message.senderName == "Sharone" ? "2" : "1"}.jpg"),
                  ),
                ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Message content based on type
                    _buildMessageContent(),
                    
                    // Timestamp
                    Padding(
                      padding: EdgeInsets.only(
                        left: message.isMe ? 0 : 10,
                        right: message.isMe ? 10 : 0,
                        top: 9,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Affiche l'icône de statut du message si le message est de l'utilisateur
                          if (message.isMe && message.messageStatus != null)
                            _buildStatusIcon(message.messageStatus!),
                          
                          // Ajoute un espace si le message a un nom d'expéditeur ou est de l'utilisateur
                          if (message.senderName != null || message.isMe)
                            const SizedBox(width: 5),
                          
                          // Affiche l'heure du message
                          Text(
                            message.time,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              shadows: [
                                Shadow(
                                  offset: const Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.messageType) {
      case MessageType.text:
        return _buildTextMessage();
      
      case MessageType.image:
        return _buildImageMessage();
      
      case MessageType.video:
        return _buildVideoMessage();
      
      case MessageType.audio:
        return _buildAudioMessage();
      
      case MessageType.file:
        return _buildFileMessage();
      
      case MessageType.link:
        return _buildLinkMessage();
      
      case MessageType.contact:
        return _buildContactMessage();
      
      case MessageType.location:
        return _buildLocationMessage();
      
      case MessageType.multipleMedia:
        return _buildMultipleMediaMessage();
      
      }
  }

  Widget _buildStatusIcon(String status) {
    final Map<String, String> statusIcons = {
      'read': 'assets/icons/is_read.png',
      'sent': 'assets/icons/sent.png',
      'delivered': 'assets/icons/delivered.png',
    };
    
    final String? iconPath = statusIcons[status];
    
    if (iconPath == null) return const SizedBox.shrink();
    
    return Image.asset(
      iconPath,
      width: 14,
      height: 14,
    );
  }

  Widget _buildTextMessage() {
    final colors = isDarkMode ? AppTheme.darkColors : AppTheme.lightColors;
    
    return Container(
      decoration: BoxDecoration(
        color: message.isMe ? colors.senderBubbleBackground
                            : colors.receiverBubbleBackground,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          message.isMe ? 15.0 : 20.0,  // Padding gauche plus grand pour les messages reçus
          10.0,
          message.isMe ? 20.0 : 15.0,  // Padding droit plus grand pour les messages envoyés
          10.0,
        ),
        constraints: const BoxConstraints(
          maxWidth: 300, // Limite la largeur du message
        ),
        child: Text(
          message.text ?? '',
          style: TextStyle(
            color: message.isMe ? colors.senderBubbleText : colors.receiverBubbleText,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildImageMessage() {
    final colors = isDarkMode ? AppTheme.darkColors : AppTheme.lightColors;
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: message.isMe ? colors.senderBubbleBackground
                            : colors.receiverBubbleBackground,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.asset(
          message.image!,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVideoMessage() {
    return VideoMessageBubble(
      videoPath: message.videoPath!,
      isMe: message.isMe,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildAudioMessage() {
    return AudioMessageBubble(
      isMe: message.isMe,
      isDarkMode: isDarkMode,
      audioPath: message.audioPath!,
    );
  }

  Widget _buildFileMessage() {
    return FileMessageBubble(
      fileName: message.fileName ?? 'Unknown file',
      fileSize: message.fileSize ?? '0 KB',
      fileExtension: message.fileExtension ?? 'file',
      isMe: message.isMe,
      isDarkMode: isDarkMode,
      onTap: () {
        // Handle file tap (open, download, etc.)
        print('File tapped: ${message.fileName}');
      },
    );
  }

  Widget _buildLinkMessage() {
    return LinkMessageBubble(
      url: message.linkUrl!,
      title: message.linkTitle,
      description: message.linkDescription,
      imageUrl: message.linkImage,
      isMe: message.isMe,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildContactMessage() {
    return ContactMessageBubble(
      contactName: message.contactName!,
      contactPhone: message.contactPhone,
      contactAvatar: message.contactAvatar,
      contactUsername: message.senderUsername,
      isMe: message.isMe,
      isDarkMode: isDarkMode,
      /*onTap: () {
        // Handle contact tap (view details, add to contacts, etc.)
        print('Contact tapped: ${message.contact!.name}');
      },*/
    );
  }

  Widget _buildLocationMessage() {
    return LocationMessageBubble(
      location: message.locationInfo!,
      isMe: message.isMe,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildMultipleMediaMessage() {
    return MultipleMediaBubble(
      mediaFiles: message.mediaFiles!,
      isMe: message.isMe,
      isDarkMode: isDarkMode,
      onMediaTap: (mediaPath) {
        // Handle media tap (view full screen, download, etc.)
        print('Media tapped: $mediaPath');
      },
    );
  }
}