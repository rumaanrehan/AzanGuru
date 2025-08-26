import 'package:azan_guru_mobile/ui/model/media.dart';

class VideoElement {
  String? streamVideoUrl;
  Media? video;

  VideoElement({
    this.video,
    this.streamVideoUrl,
  });

  factory VideoElement.fromJson(Map<String, dynamic> json) => VideoElement(
        streamVideoUrl: json["streamVideoUrl"] ?? '',
        video: json["video"] == null ? null : Media.fromJson(json["video"]),
      );

  Map<String, dynamic> toJson() => {
        "video": video?.toJson(),
      };

  /// Returns the URL of the video.
  ///
  /// This method checks if [streamVideoUrl] is not empty. If it is not empty,
  /// it splits the URL by '/' and gets the last part. It then appends this
  /// last part to the base URL "https://vz-a554f220-6c6.b-cdn.net/" and
  /// appends "/playlist.m3u8" to the end of the URL. If [streamVideoUrl] is
  /// empty, it checks if [video] is not null. If it is not null, it returns
  /// [video.node.mediaItemUrl].
  ///
  /// Returns:
  /// The URL of the video as a [String].
  String get videoUrl {
    if (streamVideoUrl?.isEmpty ?? false) return '';
    // Split the URL by '/'
    List<String> parts = streamVideoUrl?.split('/') ?? [];

    if (parts.isNotEmpty) {
      // Get the last part of the URL
      String videoId = parts.last;
      return 'https://vz-a554f220-6c6.b-cdn.net/$videoId/playlist.m3u8';
    } else {
      return video?.node?.mediaItemUrl ?? '';
    }
  }
}
