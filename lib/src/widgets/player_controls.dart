import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final position = provider.position;
    final duration = provider.duration;

    // Fix: use .toDouble() and explicit double literals for Slider
    final posSeconds = position.inMilliseconds.toDouble();
    final durSeconds = duration.inMilliseconds.toDouble();
    final maxVal = durSeconds > 0.0 ? durSeconds : 1.0;
    final sliderValue = posSeconds.clamp(0.0, maxVal);

    return Column(
      children: [
        // Waveform scrub bar using Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.waveformInactive,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accentGlow,
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 0.0,
                    max: maxVal,
                    onChanged: durSeconds > 0.0
                        ? (val) => provider.seekTo(
                              Duration(milliseconds: val.toInt()),
                            )
                        : null,
                  ),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Main controls row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle
            _ControlButton(
              icon: Icons.shuffle_rounded,
              active: provider.shuffle,
              onTap: provider.toggleShuffle,
              size: 22,
            ),
            // Previous
            _ControlButton(
              icon: Icons.skip_previous_rounded,
              onTap: provider.seekPrevious,
              size: 30,
            ),
            // Play / Pause
            GestureDetector(
              onTap: provider.togglePlay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(80),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.background,
                  size: 34,
                ),
              ),
            ),
            // Next
            _ControlButton(
              icon: Icons.skip_next_rounded,
              onTap: provider.seekNext,
              size: 30,
            ),
            // Repeat
            _RepeatButton(mode: provider.repeatMode, onTap: provider.cycleRepeatMode),
          ],
        ),
        const SizedBox(height: 16),
        // Volume
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.volume_down_rounded, size: 18, color: AppColors.textMuted),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                    activeTrackColor: AppColors.textSecondary,
                    inactiveTrackColor: AppColors.waveformInactive,
                    thumbColor: AppColors.textSecondary,
                    overlayColor: AppColors.accentGlow,
                  ),
                  child: Slider(
                    value: provider.volume.clamp(0.0, 1.0),
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) => provider.setVolume(val),
                  ),
                ),
              ),
              const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  final double size;

  const _ControlButton({
    required this.icon,
    this.active = false,
    this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: size,
          color: active ? AppColors.accent : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  final PlayerRepeatMode mode;
  final VoidCallback onTap;

  const _RepeatButton({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, active) = switch (mode) {
      PlayerRepeatMode.off => (Icons.repeat_rounded, false),
      PlayerRepeatMode.all => (Icons.repeat_rounded, true),
      PlayerRepeatMode.one => (Icons.repeat_one_rounded, true),
    };

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 22, color: active ? AppColors.accent : AppColors.textSecondary),
      ),
    );
  }
}
