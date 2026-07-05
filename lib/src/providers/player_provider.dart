import 'dart:async';
import 'dart:io'; // <-- Añadido para discriminar por Sistema Operativo
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart'; // <-- Añadido para leer carpetas nativas
import '../models/track.dart';
import '../models/lyric_line.dart';
import '../services/audio_service.dart';
import '../services/file_picker_service.dart';
import '../services/lyrics_service.dart';

enum LyricsState { idle, loading, loaded, error, notFound }

class PlayerProvider extends ChangeNotifier {
  final AudioService _audio = AudioService();
  final FilePickerService _filePicker = FilePickerService();
  final LyricsService _lyricsService = LyricsService();

  final List<Track> _queue = [];
  int _currentIndex = -1;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;
  bool _shuffle = false;
  double _volume = 1.0;

  List<LyricLine> _lyrics = [];
  LyricsState _lyricsState = LyricsState.idle;
  int _currentLyricIndex = -1;

  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration?> _durationSub;
  late final StreamSubscription<PlayerState> _stateSub;
  late final StreamSubscription<int?> _indexSub;

  PlayerProvider() {
    _positionSub = _audio.positionStream.listen(_onPosition);
    _durationSub = _audio.durationStream.listen(_onDuration);
    _stateSub = _audio.playerStateStream.listen(_onPlayerState);
    _indexSub = _audio.currentIndexStream.listen(_onIndex);
    
    // Si inicia en iOS, escanea la carpeta de forma automática de inmediato
    if (Platform.isIOS) {
      scanAndLoadIOSTracks();
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────
  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Track? get currentTrack =>
      (_currentIndex >= 0 && _currentIndex < _queue.length) ? _queue[_currentIndex] : null;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  PlayerRepeatMode get repeatMode => _repeatMode;
  bool get shuffle => _shuffle;
  double get volume => _volume;
  List<LyricLine> get lyrics => List.unmodifiable(_lyrics);
  LyricsState get lyricsState => _lyricsState;
  int get currentLyricIndex => _currentLyricIndex;

  // ── Carga Automática exclusiva para iOS ──────────────────────────────────
  Future<void> scanAndLoadIOSTracks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final entities = directory.listSync();
      
      _queue.clear(); // Limpiamos cola vieja para evitar duplicados al reescanear

      for (final entity in entities) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          // Filtramos formatos de música soportados
          if (path.endsWith('.mp3') || path.endsWith('.m4a') || path.endsWith('.wav')) {
            final track = Track.fromPath(entity.path);
            _queue.add(track);
          }
        }
      }

      notifyListeners();

      if (_queue.isNotEmpty) {
        await _loadQueue(initialIndex: 0);
      }
    } catch (e) {
      debugPrint("Error escaneando pistas locales en iOS: $e");
    }
  }

  // ── File picking (Mantenido intacto para Android) ─────────────────────────
  Future<void> pickAndAddFiles() async {
    final paths = await _filePicker.pickAudioFiles();
    if (paths.isEmpty) return;

    final wasEmpty = _queue.isEmpty;
    for (final path in paths) {
      final track = Track.fromPath(path);
      if (!_queue.contains(track)) {
        _queue.add(track);
      }
    }

    notifyListeners();

    if (wasEmpty && _queue.isNotEmpty) {
      await _loadQueue(initialIndex: 0);
    } else {
      await _refreshPlaylist();
    }
  }

  Future<void> removeTrack(int index) async {
    if (index < 0 || index >= _queue.length) return;
    final wasCurrentIndex = index == _currentIndex;
    _queue.removeAt(index);
    if (wasCurrentIndex) {
      await _audio.stop();
      _currentIndex = -1;
      _isPlaying = false;
    } else if (index < _currentIndex) {
      _currentIndex--;
    }
    if (_queue.isNotEmpty) {
      await _refreshPlaylist();
    }
    notifyListeners();
  }

  Future<void> clearQueue() async {
    await _audio.stop();
    _queue.clear();
    _currentIndex = -1;
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _lyrics = [];
    _lyricsState = LyricsState.idle;
    _currentLyricIndex = -1;
    notifyListeners();
  }

  // ── Playback control ─────────────────────────────────────────────────────
  Future<void> playTrackAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    await _audio.seek(Duration.zero, index: index);
    await _audio.play();
    _currentIndex = index;
    _isPlaying = true;
    notifyListeners();
    await _fetchLyricsForCurrent();
  }

  Future<void> togglePlay() async {
    if (_currentIndex < 0 && _queue.isNotEmpty) {
      await playTrackAt(0);
      return;
    }
    if (_isPlaying) {
      await _audio.pause();
    } else {
      await _audio.play();
    }
  }

  Future<void> seekNext() async => _audio.seekToNext();
  Future<void> seekPrevious() async => _audio.seekToPrevious();

  Future<void> seekTo(Duration pos) async => _audio.seek(pos);

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case PlayerRepeatMode.off:
        _repeatMode = PlayerRepeatMode.all;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.off;
    }
    _audio.setRepeatMode(_repeatMode);
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await _audio.setShuffleModeEnabled(_shuffle);
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await _audio.setVolume(_volume);
    notifyListeners();
  }

  // ── Lyrics ───────────────────────────────────────────────────────────────
  Future<void> _fetchLyricsForCurrent() async {
    final track = currentTrack;
    if (track == null) return;

    _lyrics = [];
    _currentLyricIndex = -1;
    _lyricsState = LyricsState.loading;
    notifyListeners();

    try {
      final lines = await _lyricsService.fetchLyrics(
        artist: track.artist ?? '',
        title: track.title,
      );
      if (lines.isEmpty) {
        _lyricsState = LyricsState.notFound;
      } else {
        _lyrics = lines;
        _lyricsState = LyricsState.loaded;
        _updateLyricIndex(_position);
      }
    } catch (_) {
      _lyricsState = LyricsState.error;
    }
    notifyListeners();
  }

  Future<void> manualSearchLyrics(String query) async {
    if (query.trim().isEmpty) return;
    _lyrics = [];
    _currentLyricIndex = -1;
    _lyricsState = LyricsState.loading;
    notifyListeners();

    try {
      final lines = await _lyricsService.searchLyrics(query);
      if (lines.isEmpty) {
        _lyricsState = LyricsState.notFound;
      } else {
        _lyrics = lines;
        _lyricsState = LyricsState.loaded;
        _updateLyricIndex(_position);
      }
    } catch (_) {
      _lyricsState = LyricsState.error;
    }
    notifyListeners();
  }

  void _updateLyricIndex(Duration pos) {
    if (_lyrics.isEmpty) {
      _currentLyricIndex = -1;
      return;
    }
    int idx = -1;
    for (int i = 0; i < _lyrics.length; i++) {
      if (_lyrics[i].timestamp <= pos) {
        idx = i;
      } else {
        break;
      }
    }
    if (idx != _currentLyricIndex) {
      _currentLyricIndex = idx;
    }
  }

  // ── Stream handlers ──────────────────────────────────────────────────────
  void _onPosition(Duration pos) {
    _position = pos;
    final prevIdx = _currentLyricIndex;
    _updateLyricIndex(pos);
    if (_currentLyricIndex != prevIdx) {
      notifyListeners();
    }
  }

  void _onDuration(Duration? dur) {
    _duration = dur ?? Duration.zero;
    notifyListeners();
  }

  void _onPlayerState(PlayerState state) {
    _isPlaying = state.playing;
    notifyListeners();
  }

  void _onIndex(int? idx) {
    if (idx != null && idx != _currentIndex && idx < _queue.length) {
      _currentIndex = idx;
      notifyListeners();
      _fetchLyricsForCurrent();
    }
  }

  // ── Internal helpers ─────────────────────────────────────────────────────
  Future<void> _loadQueue({required int initialIndex}) async {
    if (_queue.isEmpty) return;
    await _audio.setPlaylist(
      _queue.map((t) => t.path).toList(),
      initialIndex: initialIndex,
    );
    _currentIndex = initialIndex;
    notifyListeners();
    await _fetchLyricsForCurrent();
  }

  Future<void> _refreshPlaylist() async {
    if (_queue.isEmpty) return;
    final safeIndex = _currentIndex.clamp(0, _queue.length - 1);
    await _audio.setPlaylist(
      _queue.map((t) => t.path).toList(),
      initialIndex: safeIndex,
    );
  }

  @override
  Future<void> dispose() async {
    await _positionSub.cancel();
    await _durationSub.cancel();
    await _stateSub.cancel();
    await _indexSub.cancel();
    await _audio.dispose();
    super.dispose();
  }
}