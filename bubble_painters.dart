import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  final Color color;
  final bool isMe;
  
  BubblePainter({required this.color, required this.isMe});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final radius = 20.0;
    final tailWidth = 10.0;
    final tailHeight = 10.0;
    
    if (isMe) {
      path.moveTo(0, radius);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(size.width - radius - tailWidth, size.height);
      path.quadraticBezierTo(size.width - tailWidth, size.height, size.width - tailWidth, size.height - radius);
      path.lineTo(size.width - tailWidth , radius);
      path.quadraticBezierTo(size.width - tailWidth, 0, size.width - radius - tailWidth, 0);
      path.lineTo(radius, 0);
      path.quadraticBezierTo(0, 0, 0, radius);
      path.lineTo(size.width - tailWidth, size.height - tailHeight);
      path.quadraticBezierTo(
        size.width - tailWidth, size.height - tailHeight,
        size.width, size.height
      );
      path.quadraticBezierTo(
        size.width - tailWidth, size.height - tailHeight,
        size.width - tailWidth, size.height - tailHeight * 4
      );
    
    } else {
      // Bulle du receiver
      path.moveTo(radius + tailWidth, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
      path.lineTo(radius + tailWidth, size.height);
      path.quadraticBezierTo(
        tailWidth, size.height, 
        tailWidth, size.height - tailHeight
      );
      path.quadraticBezierTo(
        tailWidth, size.height - tailHeight, 
        0, size.height - tailHeight
      );
      path.quadraticBezierTo(
        tailWidth, size.height - tailHeight, 
        tailWidth, size.height - radius - tailHeight
      );
      path.lineTo(tailWidth, radius);
      path.quadraticBezierTo(tailWidth, 0, radius + tailWidth, 0);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BubbleClipper extends CustomClipper<Path> {
  final bool isMe;
  BubbleClipper(this.isMe);
  
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 30.0;
    final tailWidth = 10.0;
    final tailHeight = 10.0;
    
    if (isMe) {
      path.moveTo(0, radius);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(size.width - radius - tailWidth, size.height);
      path.quadraticBezierTo(size.width - tailWidth, size.height, size.width - tailWidth, size.height - radius);
      path.lineTo(size.width - tailWidth , radius);
      path.quadraticBezierTo(size.width - tailWidth, 0, size.width - radius - tailWidth, 0);
      path.lineTo(radius, 0);
      path.quadraticBezierTo(0, 0, 0, radius);
      path.lineTo(size.width - tailWidth, size.height - tailHeight);
      path.quadraticBezierTo(size.width - tailWidth, size.height - tailHeight, size.width, size.height);
      path.quadraticBezierTo(size.width - tailWidth, size.height - tailHeight, size.width - tailWidth, size.height - tailHeight * 4);
    } else {
      path.moveTo(radius + tailWidth, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
      path.lineTo(radius + tailWidth, size.height);
      path.quadraticBezierTo(radius - 4, size.height, tailWidth, size.height - tailHeight);
      path.quadraticBezierTo(tailWidth, size.height - tailHeight, 0, size.height - tailHeight);
      path.quadraticBezierTo(tailWidth, size.height - tailHeight, tailWidth, size.height - radius - tailHeight);
      path.lineTo(tailWidth, radius);
      path.quadraticBezierTo(tailWidth, 0, radius + tailWidth, 0);
    }
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class AudioBubbleClipper extends CustomClipper<Path> {
  final bool isMe;
  AudioBubbleClipper(this.isMe);
  
  @override
  Path getClip(Size size) {
    const radius = 25.0;
    const tailSize = 8.0;
    final path = Path();
    
    if (isMe) {
      // bulle droite
      path.moveTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
      path.lineTo(radius + tailSize, size.height);
      path.quadraticBezierTo(tailSize, size.height, tailSize, size.height - radius);
      path.lineTo(tailSize, radius + 6);
      path.quadraticBezierTo(tailSize, 0, 0, 0);
    } else {
      // bulle gauche avec encoche
      path.moveTo(tailSize + radius, 0);
      path.quadraticBezierTo(tailSize, 0, tailSize, radius + 6);
      path.lineTo(tailSize, size.height - radius);
      path.quadraticBezierTo(tailSize, size.height, tailSize + radius, size.height);
      path.lineTo(size.width - radius, size.height);
      path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius);
      path.lineTo(size.width, radius);
      path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
      path.lineTo(tailSize + radius, 0);
    }
    
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
