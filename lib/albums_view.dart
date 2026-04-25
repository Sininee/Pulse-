import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'album.dart';
import 'app_language.dart';
import 'app_theme.dart';
import 'navidrome_api.dart';
import 'song.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({
    super.key,
    required this.api,
    required this.albums,
    required this.selectedAlbum,
    required this.albumSongsFuture,
    required this.currentSong,
    required this.searchText,
    required this.onSelectAlbum,
    required this.onBackToAlbums,
    required this.onPlayAlbum,
    required this.onPlaySong,
  });

  final NavidromeApi api;
  final List<AlbumSummary> albums;
  final AlbumSummary? selectedAlbum;
  final Future<List<Song>>? albumSongsFuture;
  final Song? currentSong;
  final String searchText;
  final ValueChanged<AlbumSummary> onSelectAlbum;
  final VoidCallback onBackToAlbums;
  final ValueChanged<List<Song>> onPlayAlbum;
  final ValueChanged<Song> onPlaySong;

  @override
  Widget build(BuildContext context) {
    if (selectedAlbum == null || albumSongsFuture == null) {
      return _buildAlbumList(context);
    }

    return _buildAlbumSongs(context);
  }

  Widget _buildAlbumList(BuildContext context) {
    final text = t(context);

    if (albums.isEmpty) {
      return _emptyBox(text.get('noAlbums'));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: albums.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final album = albums[index];

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelectAlbum(album),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _cover(album.coverArtId, Icons.album_rounded, 54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          album.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${album.songCount} ${text.get('songs')} • ${album.durationText}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildAlbumSongs(BuildContext context) {
    final text = t(context);
    final album = selectedAlbum!;

    return FutureBuilder<List<Song>>(
      future: albumSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingBox();
        }

        if (snapshot.hasError) {
          return _emptyBox('${text.get('error')}: ${snapshot.error}');
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
                      onPressed: onBackToAlbums,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    _cover(album.coverArtId, Icons.album_rounded, 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            album.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: visibleSongs.isEmpty ? null : () => onPlayAlbum(visibleSongs),
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
                    const SizedBox(
                      width: 36,
                      child: Text('#', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    Expanded(
                      flex: 8,
                      child: Text(
                        text.get('title'),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        text.get('time'),
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: AppColors.textMuted),
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
                                        _cover(song.coverArtId, Icons.music_note, 44),
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

  Widget _cover(String coverArtId, IconData icon, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size >= 50 ? 10 : 8),
      child: coverArtId.isEmpty
          ? Container(
              width: size,
              height: size,
              color: AppColors.panelAlt,
              child: Icon(icon, size: size * 0.42),
            )
          : CachedNetworkImage(
              imageUrl: api.coverArtUrl(coverArtId),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: size,
                height: size,
                color: AppColors.panelAlt,
                child: Icon(icon, size: size * 0.42),
              ),
            ),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _loadingBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}