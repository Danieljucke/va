class ChatMessage {
  final String? text;
  final String? image;
  final String? audioLength;
  final String? audioPath;
  final bool isMe;
  final String time;
  final String? messageStatus;  
  final String? senderName;

  ChatMessage({
    this.text,
    this.image,
    this.audioLength,
    this.audioPath,
    required this.isMe,
    required this.time,
    this.messageStatus,
    this.senderName,
  });
}