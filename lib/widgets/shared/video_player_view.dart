import 'dart:io';

import 'package:flutter/material.dart';
import 'package:refactoring/models/user_model.dart';
import 'package:refactoring/widgets/shared/custom_app_bar.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final File file;
  final UserModel contact;

  const VideoPlayerView({
    super.key,
    required this.file,
    required this.contact,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController controller;
  late Future<void> initializeVideoPlayerFuture;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.file);
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
    return Scaffold(
      appBar: CustomAppBar(
        isMainScreen: false,
        title: 'Display',
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, widget.file);
            },
            icon: const Row(
              children: [
                Text(
                  'Send',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 600,
                  width: MediaQuery.of(context).size.width,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
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
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
