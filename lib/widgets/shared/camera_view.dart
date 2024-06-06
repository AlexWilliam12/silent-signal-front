import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:refactoring/models/user_model.dart';
import 'package:refactoring/widgets/shared/video_player_view.dart';

class CameraView extends StatefulWidget {
  final UserModel contact;
  const CameraView({super.key, required this.contact});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final notifier = ValueNotifier<bool>(false);
  late List<CameraDescription> cameras;
  late CameraController controller;
  Future<void>? initializeControllerFuture;

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.ultraHigh);
    initializeControllerFuture = controller.initialize();
    setState(() {});
  }

  Future<void> startRecord() async {
    notifier.value = true;
    await controller.startVideoRecording();
  }

  Future<void> stopRecord() async {
    notifier.value = false;
    final file = await controller.stopVideoRecording();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerView(
            file: File(file.path),
            contact: widget.contact,
          ),
        ),
      ).then((value) => Navigator.pop(context, value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, value, child) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(
                    controller,
                    child: Positioned(
                      width: MediaQuery.of(context).size.width,
                      bottom: 50,
                      child: InkWell(
                        onTap: () async {
                          if (!notifier.value) {
                            await startRecord();
                          } else {
                            await stopRecord();
                          }
                        },
                        child: Center(
                          child: InkWell(
                            child: Opacity(
                              opacity: 0.5,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(75),
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width: 65,
                                    height: 65,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(65),
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
