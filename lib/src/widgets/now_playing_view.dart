import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import 'player_controls.dart';
import 'waveform_painter.dart';

class NowPlayingView extends StatelessWidget {
  const NowPlayingView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final track = provider.currentTrack;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Album art placeholder
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withAlpha(30),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.music_note_rounded,
              size: 80,
              color: AppColors.accentDim,
            ),
          ),
          const SizedBox(height: 32),
          // Track info
          if (track != null) ...[
            Text(
              track.title,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              track.artist ?? 'Artista desconocido',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Text(
              'Ninguna pista seleccionada',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 28),
          // Waveform
          WaveformWidget(
            progress: provider.duration.inMilliseconds > 0
                ? provider.position.inMilliseconds / provider.duration.inMilliseconds
                : 0.0,
            height: 44,
          ),
          const SizedBox(height: 8),
          // Controls
          const PlayerControls(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
