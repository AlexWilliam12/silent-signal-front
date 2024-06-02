import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  late CameraController controller;
  Future<void>? initializeControllerFuture;

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    final camera = cameras.first;

    controller = CameraController(camera, ResolutionPreset.ultraHigh);
    initializeControllerFuture = controller.initialize();
    setState(() {});
  }

  void switchCamera(int cameraIndex) {
    if (cameras.isNotEmpty && cameraIndex < cameras.length) {
      controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.ultraHigh,
      );
      controller.setFlashMode(FlashMode.off);
      initializeControllerFuture = controller.initialize();
    }
    setState(() {});
  }

  void toggleFlash() {
    controller.setFlashMode(
      controller.value.flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> handlePhoto(CameraController controller) async {
    final file = await controller.takePicture();
    if (mounted) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(file: file),
        ),
      ) as XFile;
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(
                controller,
                child: Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () => toggleFlash(),
                        icon: const CircleAvatar(
                          backgroundColor: Color.fromARGB(158, 255, 255, 255),
                          radius: 25,
                          child: Opacity(
                            opacity: 1.0,
                            child: Icon(
                              Icons.flash_on,
                              size: 25,
                              color: Color.fromARGB(157, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await handlePhoto(controller);
                          if (controller.value.flashMode == FlashMode.torch) {
                            toggleFlash();
                          }
                        },
                        icon: const CircleAvatar(
                          backgroundColor: Color.fromARGB(158, 255, 255, 255),
                          radius: 30,
                          child: Opacity(
                            opacity: 1.0,
                            child: Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Color.fromARGB(157, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          int nextCameraIndex =
                              (cameras.indexOf(controller.description) + 1) %
                                  cameras.length;
                          switchCamera(nextCameraIndex);
                        },
                        icon: const CircleAvatar(
                          backgroundColor: Color.fromARGB(158, 255, 255, 255),
                          radius: 25,
                          child: Opacity(
                            opacity: 1.0,
                            child: Icon(
                              Icons.swap_horiz,
                              size: 25,
                              color: Color.fromARGB(157, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final XFile file;

  const DisplayPictureScreen({super.key, required this.file});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Photo'),
        backgroundColor: const Color.fromARGB(255, 0, 15, 83),
        leading: null,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(widget.file),
            icon: const Icon(Icons.check),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 0.1,
        maxScale: 4.0,
        child: Image.file(File(widget.file.path)),
      ),
    );
  }
}
