class AlbumSummary {
  AlbumSummary({
    required this.id,
    required this.name,
    required this.artist,
    required this.songCount,
    required this.durationSeconds,
    required this.coverArtId,
  });

  final String id;
  final String name;
  final String artist;
  final int songCount;
  final int durationSeconds;
  final String coverArtId;

  String get durationText {
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}