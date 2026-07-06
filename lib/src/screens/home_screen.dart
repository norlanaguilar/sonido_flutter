import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/now_playing_view.dart';
import '../widgets/karaoke_view.dart';
import '../widgets/track_tile.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 20,
        centerTitle: true,
        title: Image.asset(
          'assets/images/titulo.png',
          height: 35,
          fit: BoxFit.contain,
        ),
        actions: [
          // MODIFICADO: El botón '+' ahora está disponible tanto en Android como en iOS
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent, size: 26),
            tooltip: 'Agregar pistas',
            onPressed: provider.pickAndAddFiles,
          ),
          if (provider.queue.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, size: 22, color: AppColors.textMuted),
              tooltip: 'Limpiar cola',
              onPressed: () => _confirmClear(context, provider),
            ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'REPRODUCIENDO'),
            Tab(text: 'KARAOKE'),
            Tab(text: 'BIBLIOTECA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NowPlayingView(),
          KaraokeView(),
          _LibraryTab(),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, PlayerProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Limpiar biblioteca',
          style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Eliminar todas las pistas de la cola?',
          style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.clearQueue();
    }
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final queue = provider.queue;

    if (queue.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.library_music_outlined,
              size: 72,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tu biblioteca está vacía',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // MODIFICADO: Texto simplificado e inclusivo para ambos sistemas
            const Text(
              'Toca + para agregar archivos de audio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            // MODIFICADO: El botón grande central ahora se renderiza de forma global
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: provider.pickAndAddFiles,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar pistas'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Queue count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Text(
                '${queue.length} ${queue.length == 1 ? 'pista' : 'pistas'}',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // MODIFICADO: El botón "AGREGAR MÁS" de la lista también se habilita en iOS
              GestureDetector(
                onTap: provider.pickAndAddFiles,
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'AGREGAR MÁS',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        color: AppColors.accent,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: queue.length,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemBuilder: (context, i) {
              final track = queue[i];
              return TrackTile(
                track: track,
                index: i,
                isActive: provider.currentIndex == i,
                isPlaying: provider.isPlaying && provider.currentIndex == i,
                onTap: () => provider.playTrackAt(i),
                onRemove: () => provider.removeTrack(i),
              );
            },
          ),
        ),
      ],
    );
  }
}