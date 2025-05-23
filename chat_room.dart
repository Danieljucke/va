import 'package:antmap_mvp/models/chat.dart';
import 'package:antmap_mvp/utils/theme_provider.dart';
import 'package:antmap_mvp/widgets/chat/chat_header.dart';
import 'package:antmap_mvp/widgets/chat/input_bar.dart';
import 'package:antmap_mvp/widgets/chat/message_list.dart';
import 'package:antmap_mvp/widgets/chat/response_options.dart'; // Nouvel import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  bool isGroupChat = false; // Changez cette valeur pour tester le mode groupe
  bool isAIOptionsVisible = false; // Ajoutez cette variable d'état
  String get chatTitle => isGroupChat ? "Group Chat" : "Sharone";
  List<String> groupMembers = ["Mark", "John", "Jane", "Smith"];
  String status = "Online";
  
  // Liste des messages
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hey Mark !!",
      isMe: false,
      time: "8:12 AM",
      messageType: MessageType.text
    ),
    ChatMessage(
      image: "assets/images/singapore.jpg",
      isMe: true,
      time: "9:55 AM",
      messageStatus: "read",
      messageType: MessageType.image
    ),
    ChatMessage(
      isMe: false,
      time: "9:57 AM",
      audioLength: "0:26",
      audioPath: "assets/audio/audio1.mp3",
      messageType: MessageType.audio
    ),
    ChatMessage(
      fileName: 'presentation.jpg',
      fileSize: '2.5 MB',
      fileExtension: 'jpg',
      filePath: 'assets/files/presentation.jpg',
      isMe: true,
      time: '10:02 AM',
      messageStatus: 'delivered',
      messageType: MessageType.file,
    ),
    ChatMessage(
      linkUrl: 'https://www.fonewalls.com/',
      linkTitle: 'Amazing Website',
      linkDescription: 'Check out this amazing website with lots of cool features and content.',
      linkImage: 'https://www.fonewalls.com/wp-content/uploads/2160x3840-Background-HD-Wallpaper-502-768x1365.jpg',
      isMe: false,
      time: '10: 05 AM',
      messageType: MessageType.link,
    ),
    ChatMessage(
      locationInfo: LocationInfo(
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'San Francisco, CA, USA',
          //name: 'You shared location',
        ),
      isMe: true,
      time: '10:10 AM',
      messageStatus: 'delivered',
      messageType: MessageType.location,
    ),
    ChatMessage(
      contactName: 'John Doe',
      contactPhone: '+1234567890',
      senderName: 'Sharone',
      isMe: false,
      time: '10:15 AM',
      messageType: MessageType.contact,
    ),
    ChatMessage(
      mediaFiles: [
        'assets/uploads/images/photo1.jpg',
        'assets/uploads/videos/video1.mp4',
        'assets/uploads/images/photo2.jpg',
        'assets/uploads/videos/video1.mp4',
        'assets/uploads/images/photo3.jpg',
      ],
      downloadCount: 5,
      isMe: true,
      time: '10:20 AM',
      messageStatus: 'read',
      messageType: MessageType.multipleMedia,
    ),
    ChatMessage(
      text: "Hello, how are you?",
      isMe: false,
      time: "10:25 AM",
      videoPath: "assets/videos/video1.mp4",
      videoThumbnail: "assets/images/singapore.jpg",
      messageType: MessageType.video
    ),

  ];

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  // Ajoutez cette méthode pour gérer la visibilité des options IA
  void _toggleAIOptions(bool visible) {
    setState(() {
      isAIOptionsVisible = visible;
    });
  }

  String get subtitle => isGroupChat ? groupMembers.join(", ") : status;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
                (themeProvider.useSystemTheme &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background/${isDarkMode ? 'dark':'light'}_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header avec le profil et les boutons
            ChatHeader(
              isDarkMode: isDarkMode,
              isGroupChat: isGroupChat,
              chatTitle: chatTitle,
              subtitle: subtitle,
            ),
                        
            // Liste des messages
            Expanded(
              child: MessageList(
                messages: _messages,
                isDarkMode: isDarkMode,
                isGroupChat: isGroupChat,
                onMessageAction: (message) => ResponseOptions.show(context, message),
              ),
            ),
            
            // Panneau d'options IA (placé au-dessus de la barre d'entrée)
            if (isAIOptionsVisible)
              _buildAIOptionsPanel(isDarkMode),
                        
            // Barre de saisie de message
            InputBar(
              isDarkMode: isDarkMode,
              onMessageSent: _addMessage,
              onAIOptionsToggle: _toggleAIOptions, // Passez cette nouvelle fonction
            ),
          ],
        ),
      ),
    );
  }
  
  // Ajoutez cette méthode pour construire le panneau d'options IA
  Widget _buildAIOptionsPanel(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 80, right: 80),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAIOption(
            icon: 'assets/icons/${isDarkMode ? 'dark': 'light'}/translate.png',
            label: 'Translate',
            isDarkMode: isDarkMode,
            onTap: () {
              // Implémenter la fonctionnalité de traduction
              print('Translate option selected');
              setState(() {
                isAIOptionsVisible = false;
              });
            },
          ),
          const SizedBox(height: 8
          ),
          _buildAIOption(
            icon: 'assets/icons/${isDarkMode ? 'dark': 'light'}/rephrase.png',
            label: 'Rephrase',
            isDarkMode: isDarkMode,
            onTap: () {
              // Implémenter la fonctionnalité de reformulation
              print('Rephrase option selected');
              setState(() {
                isAIOptionsVisible = false;
              });
            },
          ),
          const SizedBox(height: 8
          ),
          _buildAIOption(
            icon: 'assets/icons/${isDarkMode ? 'dark': 'light'}/time2.png',
            label: 'Send Later',
            isDarkMode: isDarkMode,
            onTap: () {
              // Implémenter la fonctionnalité de reformulation
              print('Rephrase option selected');
              setState(() {
                isAIOptionsVisible = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAIOption({
    required String icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
