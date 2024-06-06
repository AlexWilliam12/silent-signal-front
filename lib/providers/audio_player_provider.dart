import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isPaused = false;

  AudioPlayerProvider() {
    player.positionStream.listen((p) {
      position = p;
      notifyListeners();
    });

    player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await stop();
      } else if (state.playing) {
        isPlaying = true;
        isPaused = false;
        notifyListeners();
      } else {
        isPlaying = false;
        notifyListeners();
      }
    });
  }

  Future<void> play(String url) async {
    duration = await player.setUrl(url) ?? const Duration();
    isPaused = false;
    isPlaying = true;
    notifyListeners();
    await player.play();
  }

  Future<void> resume() async {
    isPaused = false;
    isPlaying = true;
    notifyListeners();
    await player.play();
  }

  Future<void> pause() async {
    isPaused = true;
    isPlaying = false;
    notifyListeners();
    await player.pause();
  }

  Future<void> stop() async {
    isPaused = false;
    isPlaying = false;
    position = Duration.zero;
    notifyListeners();
    await player.stop();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
    notifyListeners();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
