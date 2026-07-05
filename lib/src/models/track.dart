import 'package:path/path.dart' as p;

class Track {
  final String path;
  final String title;
  final String? artist;
  final String? album;
  final Duration? duration;

  const Track({
    required this.path,
    required this.title,
    this.artist,
    this.album,
    this.duration,
  });

  factory Track.fromPath(String filePath) {
    final fileName = p.basenameWithoutExtension(filePath);
    // Try to parse "Artist - Title" pattern
    final parts = fileName.split(' - ');
    if (parts.length >= 2) {
      return Track(
        path: filePath,
        title: parts.sublist(1).join(' - ').trim(),
        artist: parts[0].trim(),
      );
    }
    return Track(
      path: filePath,
      title: fileName,
    );
  }

  Track copyWith({
    String? path,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
  }) {
    return Track(
      path: path ?? this.path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Track && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
