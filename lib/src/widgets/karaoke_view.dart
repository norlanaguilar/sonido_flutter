import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/lyric_line.dart';
import '../theme/app_colors.dart';

class KaraokeView extends StatefulWidget {
  const KaraokeView({super.key});

  @override
  State<KaraokeView> createState() => _KaraokeViewState();
}

class _KaraokeViewState extends State<KaraokeView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static const double _lineHeight = 64.0;
  static const double _visibleOffset = 200.0;

  int _lastScrolledIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLine(int index) {
    if (index < 0) return;
    if (index == _lastScrolledIndex) return;
    _lastScrolledIndex = index;

    if (!_scrollController.hasClients) return;

    final targetOffset = (index * _lineHeight) - _visibleOffset;
    final clamped = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();

    // Trigger auto-scroll whenever the current lyric changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLine(provider.currentLyricIndex);
    });

    return Column(
      children: [
        // Manual search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Buscar letra (artista - título)...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  ),
                  onSubmitted: (query) {
                    provider.manualSearchLyrics(query);
                    _searchController.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final q = _searchController.text.trim();
                  if (q.isNotEmpty) {
                    provider.manualSearchLyrics(q);
                    _searchController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Buscar',
                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        // Lyrics content
        Expanded(child: _buildLyricsBody(provider)),
      ],
    );
  }

  Widget _buildLyricsBody(PlayerProvider provider) {
    switch (provider.lyricsState) {
      case LyricsState.idle:
        return _buildEmptyState(
          icon: Icons.lyrics_outlined,
          message: 'Selecciona una pista para ver la letra',
        );

      case LyricsState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
              SizedBox(height: 16),
              Text(
                'Buscando letra...',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );

      case LyricsState.error:
        return _buildEmptyState(
          icon: Icons.wifi_off_rounded,
          message: 'Error al buscar la letra.\nRevisa tu conexión.',
          isError: true,
        );

      case LyricsState.notFound:
        return _buildEmptyState(
          icon: Icons.music_off_rounded,
          message: 'No se encontró letra sincronizada.\nIntenta buscar manualmente.',
        );

      case LyricsState.loaded:
        return _buildLyricsList(provider.lyrics, provider.currentLyricIndex);
    }
  }

  Widget _buildLyricsList(List<LyricLine> lines, int currentIndex) {
    // Reset scrolled index when lyrics change
    if (_lastScrolledIndex > lines.length) {
      _lastScrolledIndex = -1;
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: lines.length,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      itemBuilder: (context, i) {
        final line = lines[i];
        final isCurrent = i == currentIndex;
        final isPast = i < currentIndex;

        return SizedBox(
          height: _lineHeight,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: isCurrent ? 20 : 16,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCurrent
                    ? AppColors.accent
                    : isPast
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                height: 1.3,
              ),
              child: Text(
                line.text.isEmpty ? '♪' : line.text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    bool isError = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: isError ? AppColors.error.withAlpha(160) : AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                color: isError ? AppColors.error.withAlpha(200) : AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
