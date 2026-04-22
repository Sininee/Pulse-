import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'navidrome_api.dart';
import 'playlist.dart';
import 'song.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({
    super.key,
    required this.api,
    required this.playlists,
    required this.selectedPlaylist,
    required this.playlistSongsFuture,
    required this.currentSong,
    required this.searchText,
    required this.onSelectPlaylist,
    required this.onBackToPlaylists,
    required this.onPlayPlaylist,
    required this.onPlaySong,
  });

  final NavidromeApi api;
  final List<PlaylistSummary> playlists;
  final PlaylistSummary? selectedPlaylist;
  final Future<List<Song>>? playlistSongsFuture;
  final Song? currentSong;
  final String searchText;
  final ValueChanged<PlaylistSummary> onSelectPlaylist;
  final VoidCallback onBackToPlaylists;
  final ValueChanged<List<Song>> onPlayPlaylist;
  final ValueChanged<Song> onPlaySong;

  @override
  Widget build(BuildContext context) {
    if (selectedPlaylist == null || playlistSongsFuture == null) {
      return _buildPlaylistListOnly();
    }

    return _buildPlaylistDetailsOnly();
  }

  Widget _buildPlaylistListOnly() {
    if (playlists.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'No playlists found.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: playlists.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final playlist = playlists[index];

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelectPlaylist(playlist),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: playlist.coverArtId.isEmpty
                        ? Container(
                            width: 54,
                            height: 54,
                            color: AppColors.panelAlt,
                            child: const Icon(Icons.queue_music_rounded),
                          )
                        : CachedNetworkImage(
                            imageUrl: api.coverArtUrl(playlist.coverArtId),
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 54,
                              height: 54,
                              color: AppColors.panelAlt,
                              child: const Icon(Icons.queue_music_rounded),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${playlist.songCount} songs • ${playlist.durationText}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        if (playlist.owner.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            playlist.owner,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistDetailsOnly() {
    final playlist = selectedPlaylist!;

    return FutureBuilder<List<Song>>(
      future: playlistSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final allSongs = snapshot.data ?? [];
        final query = searchText.trim().toLowerCase();

        final visibleSongs = query.isEmpty
            ? allSongs
            : allSongs.where((song) {
                return song.title.toLowerCase().contains(query) ||
                    song.artist.toLowerCase().contains(query);
              }).toList();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBackToPlaylists,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: visibleSongs.isEmpty ? null : () => onPlayPlaylist(visibleSongs),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    query.isEmpty
                        ? '${allSongs.length} songs'
                        : '${visibleSongs.length} of ${allSongs.length} songs',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text('#', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    Expanded(
                      flex: 8,
                      child: Text('TITLE', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text('TIME', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visibleSongs.isEmpty
                    ? const Center(
                        child: Text(
                          'No songs match your search.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: visibleSongs.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final song = visibleSongs[index];
                          final isCurrent = currentSong?.id == song.id;

                          return InkWell(
                            onTap: () => onPlaySong(song),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              color: isCurrent ? Colors.white.withAlpha(8) : Colors.transparent,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 36,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isCurrent ? AppColors.accent : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: song.coverArtId.isEmpty
                                              ? Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: AppColors.panel,
                                                  child: const Icon(Icons.music_note, size: 18),
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: api.coverArtUrl(song.coverArtId),
                                                  width: 44,
                                                  height: 44,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, url, error) => Container(
                                                    width: 44,
                                                    height: 44,
                                                    color: AppColors.panel,
                                                    child: const Icon(Icons.music_note, size: 18),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: isCurrent ? Colors.white : null,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                song.artist,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      song.durationText,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(color: AppColors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}