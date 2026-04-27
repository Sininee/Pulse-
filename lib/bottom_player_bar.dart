import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'app_theme.dart';
import 'navidrome_api.dart';
import 'song.dart';

class BottomPlayerBar extends StatelessWidget {
  const BottomPlayerBar({
    super.key,
    required this.api,
    required this.player,
    required this.currentSong,
    required this.shuffleEnabled,
    required this.repeatEnabled,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
    required this.onPrevious,
    required this.onNext,
  });

  final NavidromeApi api;
  final AudioPlayer player;
  final Song? currentSong;
  final bool shuffleEnabled;
  final bool repeatEnabled;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleRepeat;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        return Container(
          height: compact ? 156 : 108,
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: compact ? _buildCompactLayout(context) : _buildWideLayout(context),
        );
      },
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: currentSong == null
                    ? _buildTrackPlaceholder(coverSize: 48)
                    : _buildTrackInfo(coverSize: 48),
              ),
              const SizedBox(width: 8),
              _buildVolumeControls(compact: true),
            ],
          ),
          const SizedBox(height: 8),
          _buildTransportControls(compact: true),
          const SizedBox(height: 4),
          Expanded(child: _buildProgressBar(context)),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: currentSong == null
                ? _buildTrackPlaceholder(coverSize: 60)
                : _buildTrackInfo(coverSize: 60),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTransportControls(compact: false),
                const SizedBox(height: 8),
                _buildProgressBar(context),
              ],
            ),
          ),
          SizedBox(
            width: 260,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildVolumeControls(compact: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo({required double coverSize}) {
    final song = currentSong!;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(coverSize >= 60 ? 12 : 10),
          child: CachedNetworkImage(
            imageUrl: api.coverArtUrl(song.coverArtId),
            width: coverSize,
            height: coverSize,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(
              width: coverSize,
              height: coverSize,
              color: AppColors.panel,
              child: const Icon(Icons.music_note),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
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
    );
  }

Widget _buildTrackPlaceholder({required double coverSize}) {
  return Row(
    children: [
      Container(
        width: coverSize,
        height: coverSize,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(55),
          borderRadius: BorderRadius.circular(coverSize >= 60 ? 12 : 10),
          border: Border.all(color: Colors.grey.withAlpha(35)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(55),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 86,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(45),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildTransportControls({required bool compact}) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        final iconSize = compact ? 22.0 : 24.0;
        final mainButtonSize = compact ? 50.0 : 58.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onToggleShuffle,
              icon: Icon(
                Icons.shuffle_rounded,
                size: iconSize,
                color: shuffleEnabled ? AppColors.accent : null,
              ),
            ),
            IconButton(
              onPressed: currentSong == null ? null : onPrevious,
              icon: Icon(Icons.skip_previous_rounded, size: iconSize),
            ),
            const SizedBox(width: 6),
            InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: currentSong == null
                  ? null
                  : () async {
                      if (playing) {
                        await player.pause();
                      } else {
                        await player.play();
                      }
                    },
              child: Container(
                width: mainButtonSize,
                height: mainButtonSize,
                decoration: BoxDecoration(
                  color: currentSong == null ? Colors.grey.withAlpha(40) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: currentSong == null ? Colors.grey.withAlpha(130) : Colors.black,
                  size: compact ? 28 : 32,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: currentSong == null ? null : onNext,
              icon: Icon(Icons.skip_next_rounded, size: iconSize),
            ),
            IconButton(
              onPressed: onToggleRepeat,
              icon: Icon(
                Icons.repeat_rounded,
                size: iconSize,
                color: repeatEnabled ? AppColors.accent : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durationSnapshot) {
        final total = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final maxMs = total.inMilliseconds <= 0 ? 1 : total.inMilliseconds;
            final value = position.inMilliseconds.clamp(0, maxMs).toDouble();

            return Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(_formatDuration(position)),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: value,
                      max: maxMs.toDouble(),
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.panelAlt,
                      onChanged: total == Duration.zero
                          ? null
                          : (newValue) => player.seek(
                                Duration(milliseconds: newValue.round()),
                              ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    _formatDuration(total),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVolumeControls({required bool compact}) {
    return SizedBox(
      width: compact ? 160 : 260,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.volume_up_rounded),
          ),
          Expanded(
            child: StreamBuilder<double>(
              stream: player.volumeStream,
              initialData: player.volume,
              builder: (context, snapshot) {
                final volume = snapshot.data ?? 1.0;

                return Slider(
                  value: volume,
                  onChanged: player.setVolume,
                  activeColor: Colors.white,
                  inactiveColor: AppColors.panelAlt,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${duration.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }
}