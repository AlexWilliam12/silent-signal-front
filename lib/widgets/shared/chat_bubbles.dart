import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/providers/audio_player_provider.dart';
import 'package:refactoring/widgets/shared/image_viewer.dart';
import 'package:video_player/video_player.dart';

class TextChatBubble extends StatelessWidget {
  final String content;
  const TextChatBubble({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        content,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class ImageChatBubble extends StatelessWidget {
  final String content;
  final bool isSentByMe;

  const ImageChatBubble({
    super.key,
    required this.content,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ImageViewer(path: content),
      ),
    );
  }
}

class FileChatBubble extends StatelessWidget {
  final String content;
  const FileChatBubble({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: Colors.white),
          Text(
            'File: ${content.split('/').last}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class AudioChatBubble extends StatefulWidget {
  final String content;
  const AudioChatBubble({super.key, required this.content});

  @override
  State<AudioChatBubble> createState() => _AudioChatBubbleState();
}

class _AudioChatBubbleState extends State<AudioChatBubble> {
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerProvider(),
      child: Consumer<AudioPlayerProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (!provider.isPlaying && !provider.isPaused) {
                    await provider.play(widget.content);
                  } else if (!provider.isPlaying && provider.isPaused) {
                    await provider.resume();
                  } else if (provider.isPlaying && !provider.isPaused) {
                    await provider.pause();
                  }
                },
                icon: Icon(
                  provider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    isDragging = true;
                  },
                  onHorizontalDragUpdate: (details) {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final localOffset =
                        box.globalToLocal(details.globalPosition);
                    double progress = localOffset.dx / box.size.width;
                    if (progress < 0) progress = 0;
                    if (progress > 1) progress = 1;
                    setState(() {
                      provider.position = Duration(
                          milliseconds:
                              (progress * provider.duration.inMilliseconds)
                                  .round());
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    isDragging = false;
                    await provider.seek(provider.position);
                  },
                  onTapDown: (details) {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final localOffset =
                        box.globalToLocal(details.globalPosition);
                    double progress = localOffset.dx / box.size.width;
                    if (progress < 0) progress = 0;
                    if (progress > 1) progress = 1;
                    setState(() {
                      provider.position = Duration(
                          milliseconds:
                              (progress * provider.duration.inMilliseconds)
                                  .round());
                    });
                    provider.seek(provider.position);
                  },
                  child: CustomPaint(
                    painter: _ProgressBarPainter(
                      provider.position,
                      provider.duration,
                    ),
                    child: Container(
                      height: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final Duration position;
  final Duration duration;

  _ProgressBarPainter(this.position, this.duration);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    double progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds)
        : 0.0;

    double progressPosition = progress * size.width;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(progressPosition, size.height / 2),
      paint,
    );

    canvas.drawCircle(
      Offset(progressPosition, size.height / 2),
      6.0,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class VideoChatBubble extends StatefulWidget {
  final String content;
  final bool isSentByMe;

  const VideoChatBubble({
    super.key,
    required this.content,
    required this.isSentByMe,
  });

  @override
  State<VideoChatBubble> createState() => _VideoChatBubbleState();
}

class _VideoChatBubbleState extends State<VideoChatBubble> {
  late VideoPlayerController controller;
  late Future<void> initializeVideoPlayerFuture;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.content));
    initializeVideoPlayerFuture = controller.initialize();
    controller.setLooping(true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PopScope(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 100),
                child: FutureBuilder(
                  future: initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            VideoPlayer(controller),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: VideoProgressIndicator(
                                controller,
                                allowScrubbing: true,
                              ),
                            ),
                            Center(
                              child: IconButton(
                                onPressed: () async {
                                  if (isPlaying) {
                                    setState(() {
                                      isPlaying = false;
                                    });
                                    await controller.pause();
                                  } else {
                                    setState(() {
                                      isPlaying = true;
                                    });
                                    await controller.play();
                                  }
                                },
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
      child: SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FutureBuilder(
            future: initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      VideoPlayer(controller),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VideoProgressIndicator(controller,
                            allowScrubbing: true),
                      ),
                      Center(
                        child: IconButton(
                          onPressed: () async {
                            if (isPlaying) {
                              setState(() {
                                isPlaying = false;
                              });
                              await controller.pause();
                            } else {
                              setState(() {
                                isPlaying = true;
                              });
                              await controller.play();
                            }
                          },
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
