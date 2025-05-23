class ChatMessage {
  final String? text;
  final String? image;
  final String? audioLength;
  final String? audioPath;
  final String? videoPath;
  final String? videoThumbnail;
  final String? linkUrl;
  final String? linkTitle;
  final String? linkDescription;
  final String? linkImage;
  final String? filePath;
  final String? fileName;
  final String? fileSize;
  final String? fileExtension;
  final LocationInfo? locationInfo;
  final String? contactName;
  final String? contactPhone;
  final String? contactAvatar;
  final List<String>? mediaFiles;
  final int? downloadCount; // Pour "10+" ou autres compteurs
  final bool isMe;
  final String time;
  final String? messageStatus;  
  final String? senderName;
  final MessageType messageType;

  ChatMessage({
    this.text,
    this.image,
    this.audioLength,
    this.audioPath,
    this.videoPath,
    this.videoThumbnail,
    this.linkUrl,
    this.linkTitle,
    this.linkDescription,
    this.linkImage,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.fileExtension,
    this.locationInfo,
    this.contactName,
    this.contactPhone,
    this.contactAvatar,
    this.mediaFiles,
    this.downloadCount,
    required this.isMe,
    required this.time,
    this.messageStatus,
    this.senderName,
    required this.messageType,
  });

  // Getters pour identifier le type de message
  int get filesCount => mediaFiles?.length ?? 0;
  bool get isTextMessage => text != null;
  bool get isImageMessage => image != null;
  bool get isAudioMessage => audioPath != null;
  bool get isVideoMessage => videoPath != null;
  bool get isLinkMessage => linkUrl != null;
  bool get isFileMessage => filePath != null;
  bool get isLocationMessage => locationInfo != null;
  bool get isContactMessage => contactName != null;
  bool get isMultipleMediaMessage => mediaFiles != null && mediaFiles!.isNotEmpty;
  String get senderUsername => senderName ?? 'Unknown';
}
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  link,
  contact,
  location,
  multipleMedia,
}
class LocationInfo {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });
}