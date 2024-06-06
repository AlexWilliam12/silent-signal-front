import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
  late CameraController _controller;
  final _cameras = <CameraDescription>[];
  int _selectedCameraIndex = 0;

  CameraController get controller => _controller;
  List<CameraDescription> get cameras => _cameras;
  int get selectedCameraIndex => _selectedCameraIndex;

  set selectedCameraIndex(int index) {
    _selectedCameraIndex = index;
    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );
    _controller.initialize().then((_) {
      notifyListeners();
    });
  }
}
