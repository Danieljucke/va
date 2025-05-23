import 'package:antmap_mvp/utils/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMessageBubble extends StatefulWidget {
  final String audioPath;
  final bool isMe;
  final bool isDarkMode;

  const AudioMessageBubble({
    required this.audioPath,
    required this.isMe,
    required this.isDarkMode,
    super.key,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    
    // Correction de la gestion des futures
    _initAudio();
    
    _player.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });
  }

  Future<void> _initAudio() async {
    try {
      // Utiliser await au lieu de then pour une meilleure gestion des erreurs
      await _player.setAsset(widget.audioPath);
      if (mounted) {
        setState(() {
          _duration = _player.duration ?? Duration.zero;
        });
      }
    } catch (error) {
      print('Error loading audio: $error');
      // Gérer l'erreur de manière appropriée
    }
  }



  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      setState(() {}); // Mettre à jour l'UI après le changement d'état
    } catch (e) {
      print('Error toggling play/pause: $e');
      // Afficher un message d'erreur à l'utilisateur si nécessaire
    }
  }


  @override
  Widget build(BuildContext context) {
    final colors = widget.isDarkMode ? AppTheme.darkColors : AppTheme.lightColors;
    final playedPercent = _duration.inMilliseconds == 0
        ? 0
        : _position.inMilliseconds / _duration.inMilliseconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
      color: widget.isMe ? colors.senderBubbleBackground
                              : colors.receiverBubbleBackground,
      borderRadius: BorderRadius.circular(25.0),
    ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Icon(
              _player.playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            height: 30,
            child: Row(
              children: List.generate(30, (index) {
                final barPercent = index / 30;
                final isPlayed = barPercent <= playedPercent;
                return Container(
                  width: 3,
                  height: (index % 2 == 0) ? 15.0 : 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isPlayed
                        ? Colors.orange
                        : (widget.isMe ? Colors.white : const Color(0xFF708090)),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(_duration - _position),
            style: TextStyle(
              color: widget.isMe ? Colors.white : Colors.black87,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
