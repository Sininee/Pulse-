import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_language.dart';
import 'app_theme.dart';
import 'navidrome_api.dart';
import 'song.dart';

class TracksTable extends StatelessWidget {
  const TracksTable({
    super.key,
    required this.tracks,
    required this.api,
    required this.currentSong,
    required this.onPlaySong,
  });

  final List<Song> tracks;
  final NavidromeApi api;
  final Song? currentSong;
  final ValueChanged<Song> onPlaySong;

  @override
  Widget build(BuildContext context) {
    final text = t(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 36,
                  child: Text(
                    '#',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Text(
                    text.get('title'),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    text.get('time'),
                    style: const TextStyle(color: AppColors.textMuted),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: tracks.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final song = tracks[index];
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
                                child: CachedNetworkImage(
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
                          width: 70,
                          child: Text(
                            song.durationText,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                            ),
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
  }
}