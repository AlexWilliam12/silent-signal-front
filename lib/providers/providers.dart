import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/services/user_service.dart';
import 'package:silent_signal/services/websocket_service.dart';

class PrivateChatProvider extends WebsocketService {}

class GroupChatProvider extends WebsocketService {}

class UserProvider with ChangeNotifier {
  SensitiveUser? _user;

  SensitiveUser? get user => _user;

  Future<void> provide() async {
    _user = await UserService().fetchUser();
    notifyListeners();
  }
}

class CameraProvider with ChangeNotifier {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  List<CameraDescription> get cameras => _cameras;
  CameraController? get controller => _controller;
  Future<void> get initializeControllerFuture => _initializeControllerFuture;

  Future<void> loadCameras() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
    }
    notifyListeners();
  }

  void switchCamera(int cameraIndex) {
    if (_cameras.isNotEmpty && cameraIndex < _cameras.length) {
      _controller = CameraController(
        _cameras[cameraIndex],
        ResolutionPreset.ultraHigh,
      );
      _initializeControllerFuture = _controller!.initialize();
      notifyListeners();
    }
  }

  void toggleFlash() {
    if (_controller != null) {
      _controller!.setFlashMode(
        _controller!.value.flashMode == FlashMode.off
            ? FlashMode.torch
            : FlashMode.off,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
