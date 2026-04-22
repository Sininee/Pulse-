class Song {
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverArtId,
    required this.durationSeconds,
  });

  final String id;
  final String title;
  final String artist;
  final String coverArtId;
  final int durationSeconds;

  String get durationText {
    final duration = Duration(seconds: durationSeconds);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}