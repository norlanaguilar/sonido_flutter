import 'package:just_audio/just_audio.dart';

/// Renamed to avoid conflict with Flutter's built-in RepeatMode.
enum PlayerRepeatMode { off, one, all }

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get playing => _player.playing;
  int? get currentIndex => _player.currentIndex;

  Future<void> setFilePath(String path) async {
    await _player.setFilePath(path);
  }

  Future<void> setPlaylist(List<String> paths, {int initialIndex = 0}) async {
    final sources = paths.map((p) => AudioSource.file(p)).toList();
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: initialIndex,
    );
  }

  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();
  Future<void> stop() async => _player.stop();

  /// Seek within the current track (or jump to [index] in playlist).
  Future<void> seek(Duration position, {int? index}) async {
    await _player.seek(position, index: index);
  }

  Future<void> seekToNext() async => _player.seekToNext();
  Future<void> seekToPrevious() async => _player.seekToPrevious();

  void setRepeatMode(PlayerRepeatMode mode) {
    switch (mode) {
      case PlayerRepeatMode.off:
        _player.setLoopMode(LoopMode.off);
      case PlayerRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
      case PlayerRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
    }
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
