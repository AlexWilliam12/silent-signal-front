import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:refactoring/widgets/shared/image_viewer.dart';

class ChatBubble extends StatefulWidget {
  final String type;
  final String message;
  final bool isSentByMe;

  const ChatBubble({
    super.key,
    required this.type,
    required this.message,
    required this.isSentByMe,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final player = AudioPlayer();
  final playerNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    playerNotifier.dispose();
    super.dispose();
  }

  Future<void> toggleAudio() async {
    if (playerNotifier.value) {
      await player.pause();
      playerNotifier.value = false;
    } else {
      playerNotifier.value = true;
      await player.setUrl(widget.message);
      await player.play();
      playerNotifier.value = false;
    }
  }

  Widget renderContent(BuildContext context) {
    switch (widget.type) {
      case 'text':
        return Text(
          widget.message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        );
      case 'image/jpeg' || 'image/jpg' || 'image/png':
        return SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: ImageViewer(path: widget.message),
        );
      case 'file':
        return Row(
          children: [
            const Icon(Icons.attach_file, color: Colors.white),
            Text(
              'File: ${widget.message.split('/').last}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );
      case 'audio/aac':
        return ValueListenableBuilder(
          valueListenable: playerNotifier,
          builder: (context, value, child) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  onPressed: () async => await toggleAudio(),
                  icon: Icon(
                    playerNotifier.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Audio: ${widget.message.substring(widget.message.lastIndexOf('file=') + 5)}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        );
      default:
        return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: CustomPaint(
          painter: _ChatBubblePainter(isSentByMe: widget.isSentByMe),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: widget.isSentByMe
                  ? Colors.blue
                  : const Color.fromARGB(255, 114, 0, 108),
              borderRadius: BorderRadius.circular(15),
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
