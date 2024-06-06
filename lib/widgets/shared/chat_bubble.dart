import 'package:flutter/material.dart';
import 'package:refactoring/widgets/shared/chat_bubbles.dart';

class ChatBubble extends StatelessWidget {
  final String sender;
  final String type;
  final String content;
  final bool isSentByMe;
  final DateTime createdAt;

  const ChatBubble({
    super.key,
    required this.type,
    required this.content,
    required this.isSentByMe,
    required this.sender,
    required this.createdAt,
  });

  Widget renderContent(BuildContext context) {
    switch (type) {
      case 'text':
        return TextChatBubble(content: content);
      case 'image/jpeg' || 'image/jpg' || 'image/png':
        return ImageChatBubble(content: content, isSentByMe: isSentByMe);
      case 'file':
        return FileChatBubble(content: content);
      case 'audio/mpeg':
        return AudioChatBubble(content: content);
      case 'video/mp4':
        return VideoChatBubble(content: content, isSentByMe: isSentByMe);
      default:
        return const Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: CustomPaint(
          painter: _ChatBubblePainter(isSentByMe: isSentByMe),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isSentByMe
                  ? Colors.blue
                  : const Color.fromARGB(255, 114, 0, 108),
              borderRadius: BorderRadius.circular(10),
            ),
            child: renderContent(context),
          ),
        ),
      ),
    );
  }
}

class _ChatBubblePainter extends CustomPainter {
  final bool isSentByMe;

  _ChatBubblePainter({required this.isSentByMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          isSentByMe ? Colors.blue : const Color.fromARGB(255, 114, 0, 108);
    final path = Path();

    if (isSentByMe) {
      path.moveTo(size.width, size.height - 10);
      path.lineTo(size.width - 10, size.height);
      path.lineTo(size.width - 10, size.height - 10);
    } else {
      path.moveTo(0, size.height - 10);
      path.lineTo(10, size.height);
      path.lineTo(10, size.height - 10);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
