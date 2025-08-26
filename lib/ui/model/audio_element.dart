import 'package:azan_guru_mobile/ui/model/media.dart';

class AudioElement {
  Media? audio;

  AudioElement({
    this.audio,
  });

  factory AudioElement.fromJson(Map<String, dynamic> json) => AudioElement(
        audio: json["audio"] == null ? null : Media.fromJson(json["audio"]),
      );

  Map<String, dynamic> toJson() => {
        "audio": audio?.toJson(),
      };
}
