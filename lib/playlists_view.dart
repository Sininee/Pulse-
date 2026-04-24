import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_language.dart';
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
      return _buildPlaylistListOnly(context);
    }

    return _buildPlaylistDetailsOnly(context);
  }

  Widget _buildPlaylistListOnly(BuildContext context) {
    final text = t(context);

    if (playlists.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            text.get('noPlaylists'),
            style: const TextStyle(color: AppColors.textMuted),
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
                          '${playlist.songCount} ${text.get('songs')} • ${playlist.durationText}',
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
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistDetailsOnly(BuildContext context) {
    final text = t(context);
    final playlist = selectedPlaylist!;

    return FutureBuilder<List<Song>>(
      future: playlistSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${text.get('error')}: ${snapshot.error}'));
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
                    FilledButton.icon(
                      onPressed: visibleSongs.isEmpty ? null : () => onPlayPlaylist(visibleSongs),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(text.get('play')),
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
                        ? '${allSongs.length} ${text.get('songs')}'
                        : '${visibleSongs.length} of ${allSongs.length} ${text.get('songs')}',
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
                child: Row(
                  children: [
                    const SizedBox(width: 36, child: Text('#')),
                    Expanded(
                      flex: 8,
                      child: Text(text.get('title')),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        text.get('time'),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visibleSongs.isEmpty
                    ? Center(
                        child: Text(
                          text.get('noSongsMatch'),
                          style: const TextStyle(color: AppColors.textMuted),
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
                                  SizedBox(width: 36, child: Text('${index + 1}')),
                                  Expanded(
                                    flex: 8,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: api.coverArtUrl(song.coverArtId),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
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
                                              ),
                                              Text(
                                                song.artist,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                ),
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