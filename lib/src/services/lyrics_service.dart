import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lyric_line.dart';

class LyricsService {
  static const _baseUrl = 'https://lrclib.net/api';

  /// Fetches synced (LRC) lyrics for the given artist and track.
  /// First tries exact match, then falls back to search.
  Future<List<LyricLine>> fetchLyrics({
    required String artist,
    required String title,
  }) async {
    // 1. Try exact get endpoint
    final exactUri = Uri.parse('$_baseUrl/get').replace(queryParameters: {
      'artist_name': artist,
      'track_name': title,
    });

    try {
      final response = await http.get(exactUri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final syncedLyrics = data['syncedLyrics'] as String?;
        if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
          return _parseLrc(syncedLyrics);
        }
      }
    } catch (_) {
      // Fall through to search
    }

    // 2. Fallback: search endpoint
    final query = '$artist $title'.trim();
    final searchUri = Uri.parse('$_baseUrl/search').replace(queryParameters: {'q': query});

    try {
      final response = await http.get(searchUri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          final syncedLyrics = map['syncedLyrics'] as String?;
          if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
            return _parseLrc(syncedLyrics);
          }
        }
      }
    } catch (_) {
      // Nothing found
    }

    return [];
  }

  /// Fetches lyrics with an arbitrary free-text query (used for manual search).
  Future<List<LyricLine>> searchLyrics(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {'q': query.trim()});

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          final syncedLyrics = map['syncedLyrics'] as String?;
          if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
            return _parseLrc(syncedLyrics);
          }
        }
      }
    } catch (_) {
      // Nothing found
    }

    return [];
  }

  /// Parses LRC format: `[mm:ss.xx] line text`
  List<LyricLine> _parseLrc(String lrc) {
    final lines = lrc.split('\n');
    final result = <LyricLine>[];

    // Regex: [mm:ss.xx] or [mm:ss.xxx]
    final timeRegex = RegExp(r'^\[(\d{1,2}):(\d{2})\.(\d{2,3})\](.*)$');

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final match = timeRegex.firstMatch(line);
      if (match == null) continue;

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final centStr = match.group(3)!;
      // Normalize to milliseconds
      final millis = centStr.length == 2
          ? int.parse(centStr) * 10
          : int.parse(centStr);
      final text = match.group(4)!.trim();

      // Skip metadata-only lines (empty text) but keep them for timing
      final timestamp = Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: millis,
      );

      result.add(LyricLine(timestamp: timestamp, text: text));
    }

    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }
}
