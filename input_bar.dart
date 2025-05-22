// Project: antmap_mvp
import 'dart:async';
import 'dart:ui';
import 'package:antmap_mvp/models/chat.dart';
import 'package:antmap_mvp/widgets/chat/animatedWaveformBar.dart';
import 'package:antmap_mvp/widgets/chat/audio_recorder.dart';
import 'package:flutter/material.dart';
import 'package:antmap_mvp/widgets/chat/emoji_keyboard.dart';
import 'package:antmap_mvp/widgets/chat/attachment_panel.dart';


class InputBar extends StatefulWidget {
  final bool isDarkMode;
  final Function(ChatMessage) onMessageSent;
  final Function(bool) onAIOptionsToggle; // Ajoutez cette nouvelle propriété

  const InputBar({
    super.key,
    required this.isDarkMode,
    required this.onMessageSent,
    required this.onAIOptionsToggle, // Ajoutez ce paramètre requis
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final AudioRecorderController _audioRecorderController = AudioRecorderController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final GlobalKey<State<EmojiKeyboard>> _emojiKeyboardKey = GlobalKey<State<EmojiKeyboard>>();
  
  bool isRecording = false;
  bool isPaused = false;
  bool isAttachmentPanelVisible = false;
  bool isEmojiPickerVisible = false;
  bool isAIOptionsVisible = false; // Gardez cette variable pour la logique interne
  String? recordedFilePath;
  Duration recordingDuration = Duration.zero;
  Timer? _timer;
  
  // Animation controller pour le panneau d'attachments
  late AnimationController _attachmentPanelController;
  late Animation<Offset> _attachmentPanelAnimation;
  
  // Animation controller pour le panneau d'emoji
  late AnimationController _emojiPanelController;
  late Animation<Offset> _emojiPanelAnimation;
  
  // Animation controller pour l'icône IA
  late AnimationController _iaIconRotationController;
  late Animation<double> _iaIconRotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _audioRecorderController.addListener(_updateRecordingState);
    _messageController.addListener(_onTextChanged);
    
    // Initialisation de l'animation du panneau d'attachments
    _attachmentPanelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _attachmentPanelAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _attachmentPanelController,
      curve: Curves.easeOut,
    ));
    
    // Initialisation de l'animation du panneau d'emoji
    _emojiPanelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _emojiPanelAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _emojiPanelController,
      curve: Curves.easeOut,
    ));
    
    // Initialisation de l'animation de rotation pour l'icône IA
    _iaIconRotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _iaIconRotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5, // 180 degrés en radians
    ).animate(CurvedAnimation(
      parent: _iaIconRotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _audioRecorderController.removeListener(_updateRecordingState);
    _audioRecorderController.dispose();
    _attachmentPanelController.dispose();
    _emojiPanelController.dispose();
    _iaIconRotationController.dispose();
    _textFieldFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }


  void _updateRecordingState() {
    setState(() {
      isRecording = _audioRecorderController.isRecording;
      isPaused = _audioRecorderController.isPaused;
      recordingDuration = _audioRecorderController.recordingDuration;
      recordedFilePath = _audioRecorderController.recordedFilePath;
    });
  }

  // Fonction appelée lorsque le texte dans le champ change
  void _onTextChanged() {
    setState(() {
      // Forcer une mise à jour de l'état pour que l'UI se rafraîchisse
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showKeyboard() {
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  void _toggleAttachmentPanel() {
    // Masquer le clavier
    FocusScope.of(context).unfocus();
    
    // Ferme les autres panneaux s'ils sont ouverts
    _closeAllPanelsExcept('attachment');
      
    setState(() {
      isAttachmentPanelVisible = !isAttachmentPanelVisible;
      if (isAttachmentPanelVisible) {
        _attachmentPanelController.forward();
      } else {
        _attachmentPanelController.reverse();
        // Si on ferme le panneau et qu'aucun autre panneau n'est ouvert,
        // on peut afficher le clavier
        if (!isEmojiPickerVisible && !isAIOptionsVisible) {
          // Petit délai pour laisser l'animation se terminer
          Future.delayed(const Duration(milliseconds: 100), () {
            _showKeyboard();
          });
        }
      }
    });
  }

  // Dans votre méthode _toggleEmojiPanel()
  void _toggleEmojiPanel() {
    // Masquer le clavier
    FocusScope.of(context).unfocus();
    
    // Ferme les autres panneaux s'ils sont ouverts
    _closeAllPanelsExcept('emoji');
    
    setState(() {
      isEmojiPickerVisible = !isEmojiPickerVisible;
      if (isEmojiPickerVisible) {
        _emojiPanelController.forward();
        
        // S'assurer que le FocusNode du champ de recherche dans EmojiKeyboard n'est pas actif
        if (_emojiKeyboardKey.currentState != null) {
          (_emojiKeyboardKey.currentState as dynamic).clearSearchFocus();
        }
      } else {
        _emojiPanelController.reverse();
        // Si on ferme le panneau et qu'aucun autre panneau n'est ouvert,
        // on peut afficher le clavier
        if (!isAttachmentPanelVisible && !isAIOptionsVisible) {
          // Petit délai pour laisser l'animation se terminer
          Future.delayed(const Duration(milliseconds: 100), () {
            _showKeyboard();
          });
        }
      }
    });
  }


  // Nouvelle fonction pour afficher/masquer les options IA
   void _toggleAIOptions() {
    // Masquer le clavier
    FocusScope.of(context).unfocus();
    
    // Ferme les autres panneaux s'ils sont ouverts
    _closeAllPanelsExcept('ai');
    
    setState(() {
      isAIOptionsVisible = !isAIOptionsVisible;
      
      if (isAIOptionsVisible) {
        _iaIconRotationController.forward();
      } else {
        _iaIconRotationController.reverse();
        
        // Si on ferme le panneau et qu'aucun autre panneau n'est ouvert,
        // on peut afficher le clavier
        if (!isAttachmentPanelVisible && !isEmojiPickerVisible) {
          // Petit délai pour laisser l'animation se terminer
          Future.delayed(const Duration(milliseconds: 100), () {
            _showKeyboard();
          });
        }
      }
      
      // Notifier le parent du changement d'état
      widget.onAIOptionsToggle(isAIOptionsVisible);
    });
  }

  // Ferme tous les panneaux sauf celui spécifié
  void _closeAllPanelsExcept(String panelName) {
    if (panelName != 'attachment' && isAttachmentPanelVisible) {
      isAttachmentPanelVisible = false;
      _attachmentPanelController.reverse();
    }
    
    if (panelName != 'emoji' && isEmojiPickerVisible) {
      isEmojiPickerVisible = false;
      _emojiPanelController.reverse();
    }
    
    if (panelName != 'ai' && isAIOptionsVisible) {
      isAIOptionsVisible = false;
      _iaIconRotationController.reverse();
      widget.onAIOptionsToggle(false); // Notifier le parent
    }
  }


  // Fonction pour gérer l'option de traduction
  // ignore: unused_element
  void _handleTranslate() {
    // Implémenter la fonctionnalité de traduction ici
    print('Translate option selected');
    _toggleAIOptions(); // Ferme le panneau après sélection
  }

  // Fonction pour gérer l'option de reformulation
  // ignore: unused_element
  void _handleRephrase() {
    // Implémenter la fonctionnalité de reformulation ici
    print('Rephrase option selected');
    _toggleAIOptions(); // Ferme le panneau après sélection
  }

 @override
  Widget build(BuildContext context) {
    // Obtenir la hauteur du clavier
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input bar principal (toujours visible)
          _buildInputBar(),
          
          // Panneau d'attachments animé
          SlideTransition(
            position: _attachmentPanelAnimation,
            child: isAttachmentPanelVisible ? _buildAttachmentPanel() : const SizedBox.shrink(),
          ),
          
          // Panneau d'emoji animé
          SlideTransition(
            position: _emojiPanelAnimation,
            child: isEmojiPickerVisible ? _buildEmojiPanel() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }


  Widget _buildInputBar() {
    bool hasText = _messageController.text.isNotEmpty;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          decoration: BoxDecoration(
            // Fond transparent quand l'un des panneaux est visible
            color: (isAttachmentPanelVisible || isEmojiPickerVisible || isAIOptionsVisible)
                ? null
                : widget.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFF171717).withOpacity(0.1),
            border: (isAttachmentPanelVisible || isEmojiPickerVisible || isAIOptionsVisible)
                ? null  // Pas de bordure quand l'un des panneaux est visible
                : Border.all(
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF171717).withOpacity(0.1),
                    width: 1.0,
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    // Ajout d'une ombre pour donner de la profondeur quand l'un des panneaux est ouvert
                    boxShadow: (isAttachmentPanelVisible || isEmojiPickerVisible || isAIOptionsVisible)
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Icône smiley ou delete
                      isRecording
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _audioRecorderController.deleteRecording,
                            )
                          : IconButton(
                              icon: Image.asset('assets/icons/smiley.png',
                                  width: 25, height: 25),
                              onPressed: _toggleEmojiPanel,
                              color: isEmojiPickerVisible ? Colors.orange : null,
                            ),
                      // Zone de texte (cachée si enregistrement)
                      isRecording
                          ? Text(
                              _formatDuration(recordingDuration),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          : Expanded(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 50, 
                                  
                                ),
                                child: SingleChildScrollView(
                                  child: TextField(
                                    controller: _messageController,
                                    focusNode: _textFieldFocusNode,
                                    maxLines: null,
                                    minLines: 1,
                                    textCapitalization: TextCapitalization.sentences,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    decoration: const InputDecoration(
                                      hintText: "Type here...",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                      isCollapsed: false,
                                    ),
                                    onTap: () {
                                      _closeAllPanelsExcept('');
                                    },
                                    scrollPhysics: const NeverScrollableScrollPhysics(),
                                  
                                  ),
                                ),
                              ),
                            ),
                      // Icône attachement ou animation
                      isRecording
                          ? Container(
                              width: 175,
                              height: 25,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(15, (i) {
                                  final controller = AnimationController(
                                    vsync: this,
                                    duration: const Duration(milliseconds: 600),
                                  )..repeat(reverse: true);
                                  
                                  return AnimatedWaveformBar(
                                    isActive: true,
                                    color: Colors.orange,
                                    delay: Duration(milliseconds: 100 + i * 50),
                                    controller: controller,
                                  );
                                }),
                              ),
                            )
                          : IconButton(
                              icon: Image.asset('assets/icons/attachment.png',
                                  width: 25, height: 25),
                              onPressed: _toggleAttachmentPanel,
                              color: isAttachmentPanelVisible ? Colors.orange : null,
                            ),
                      // Icône micro ou IA selon l'état du champ de texte
                      hasText
                          ? RotationTransition(
                              turns: _iaIconRotationAnimation,
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/icons/ia_icon.png',
                                  width: 28,
                                  height: 28,
                                ),
                                onPressed: _toggleAIOptions,
                                color: isAIOptionsVisible ? Colors.orange : null,
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                isRecording
                                    ? (isPaused
                                        ? Icons.play_arrow
                                        : Icons.pause)
                                    : Icons.mic,
                                color: Colors.orange,
                                size: 28,
                              ),
                              onPressed: () {
                                if (!isRecording) {
                                  _audioRecorderController.startRecording();
                                } else {
                                  isPaused 
                                      ? _audioRecorderController.resumeRecording() 
                                      : _audioRecorderController.pauseRecording();
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ),
              // Bouton d'envoi
              const SizedBox(width: 10.0),
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF5E4842),
                ),
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/send.png',
                    width: 20,
                    height: 20,
                  ),
                  onPressed: () async {
                    // Fermer les panneaux ouverts
                    _closeAllPanelsExcept('');
                    
                    if (isRecording) {
                      await _audioRecorderController.stopRecording();
                      // Ajoute un message audio
                      widget.onMessageSent(ChatMessage(
                        isMe: true,
                        time: "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour < 12 ? 'AM' : 'PM'}",
                        audioLength: _formatDuration(recordingDuration),
                        messageStatus: "sent",
                      ));
                    } else if (_messageController.text.isNotEmpty) {
                      widget.onMessageSent(ChatMessage(
                        text: _messageController.text,
                        isMe: true,
                        time: "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour < 12 ? 'AM' : 'PM'}",
                        messageStatus: "sent",
                      ));
                      _messageController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //
  Widget _buildAttachmentPanel() {
    return AttachmentPanel(
    isDarkMode: widget.isDarkMode,
    onOptionSelected: (option) {
      _toggleAttachmentPanel(); // Ferme le panneau après sélection
      // Ajoutez ici la logique pour gérer chaque option si nécessaire
      print('Selected attachment option: $option');
    },
  );
  }
  
  // Dans votre méthode build ou dans une méthode qui construit le panneau d'emoji
  Widget _buildEmojiPanel() {
    return SlideTransition(
      position: _emojiPanelAnimation,
      child: SizedBox(
        height: 300, // Ajustez selon vos besoins
        child: EmojiKeyboard(
          key: _emojiKeyboardKey,
          onEmojiSelected: (emoji) {
            // Insérer l'emoji dans le champ de texte
            final text = _messageController.text;
            final selection = _messageController.selection;
            
            // Vérifier si la sélection est valide
            if (selection.baseOffset < 0) {
              // Si la sélection n'est pas valide, ajouter l'emoji à la fin du texte
              _messageController.text = text + emoji;
              _messageController.selection = TextSelection.collapsed(
                offset: _messageController.text.length,
              );
            } else {
              // Sinon, insérer l'emoji à la position du curseur
              final newText = text.replaceRange(
                selection.start,
                selection.end,
                emoji,
              );
              _messageController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: selection.baseOffset + emoji.length,
                ),
              );
            }
          },
          onClose: () {
            _toggleEmojiPanel(); // Ferme le panneau d'emoji
          },
          isDarkMode: Theme.of(context).brightness == Brightness.dark, // Ou votre logique pour le mode sombre
        ),
      ),
    );
  }

}