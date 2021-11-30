import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum Type { video, music }

class VideoDetail {
  static const _replace = '_';

  Type type;
  final StreamManifest manifest;
  final Video video;
  final YoutubeExplode yt;
  late StreamInfo streamInfo;

  VideoDetail({
    required this.manifest,
    required this.video,
    required this.yt,
    this.type = Type.video,
  });

  String get name => video.title
        .replaceAll('/', _replace)
        .replaceAll('\\', _replace)
        .replaceAll('!', _replace)
        .replaceAll('%', _replace)
        .replaceAll('*', _replace)
        .replaceAll('?', _replace)
        .replaceAll(':', _replace)
        .replaceAll('|', _replace);
}
