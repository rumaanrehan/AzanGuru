// To parse this JSON data, do
//
//     final helpDeskDetail = helpDeskDetailFromJson(jsonString);

import 'dart:convert';

import 'package:azan_guru_mobile/ui/model/media_node.dart';

HelpDeskDetail helpDeskDetailFromJson(String str) =>
    HelpDeskDetail.fromJson(json.decode(str));

String helpDeskDetailToJson(HelpDeskDetail data) => json.encode(data.toJson());

class HelpDeskDetail {
  String? id;
  String? title;
  DateTime? date;
  HelpDesk? helpDesk;

  HelpDeskDetail({
    this.id,
    this.title,
    this.date,
    this.helpDesk,
  });

  factory HelpDeskDetail.fromJson(Map<String, dynamic> json) => HelpDeskDetail(
        id: json["id"],
        title: json["title"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        helpDesk: json["helpDesk"] == null
            ? null
            : HelpDesk.fromJson(json["helpDesk"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "date": date?.toIso8601String(),
        "helpDesk": helpDesk?.toJson(),
      };
}

class HelpDesk {
  String? helpDeskText;
  List<HelpDeskVideoSection>? helpDeskVideoSection;
  List<HelpDeskImageSection>? helpDeskImageSection;
  List<HelpDeskAudioSection>? helpDeskAudioSection;

  HelpDesk({
    this.helpDeskText,
    this.helpDeskVideoSection,
    this.helpDeskImageSection,
    this.helpDeskAudioSection,
  });

  factory HelpDesk.fromJson(Map<String, dynamic> json) => HelpDesk(
        helpDeskText: json["helpDeskText"],
        helpDeskVideoSection: json["helpDeskVideoSection"] == null
            ? []
            : List<HelpDeskVideoSection>.from(json["helpDeskVideoSection"]!
                .map((x) => HelpDeskVideoSection.fromJson(x))),
        helpDeskImageSection: json["helpDeskImageSection"] == null
            ? []
            : List<HelpDeskImageSection>.from(json["helpDeskImageSection"]!
                .map((x) => HelpDeskImageSection.fromJson(x))),
        helpDeskAudioSection: json["helpDeskAudioSection"] == null
            ? []
            : List<HelpDeskAudioSection>.from(json["helpDeskAudioSection"]!
                .map((x) => HelpDeskAudioSection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "helpDeskText": helpDeskText,
        "helpDeskVideoSection": helpDeskVideoSection == null
            ? []
            : List<dynamic>.from(helpDeskVideoSection!.map((x) => x.toJson())),
        "helpDeskImageSection": helpDeskImageSection == null
            ? []
            : List<dynamic>.from(helpDeskImageSection!.map((x) => x.toJson())),
        "helpDeskAudioSection": helpDeskAudioSection == null
            ? []
            : List<dynamic>.from(helpDeskAudioSection!.map((x) => x.toJson())),
      };
}

class HelpDeskAudioSection {
  HelpDeskAudioClass? helpDeskAudio;

  HelpDeskAudioSection({
    this.helpDeskAudio,
  });

  factory HelpDeskAudioSection.fromJson(Map<String, dynamic> json) =>
      HelpDeskAudioSection(
        helpDeskAudio: json["helpDeskAudio"] == null
            ? null
            : HelpDeskAudioClass.fromJson(json["helpDeskAudio"]),
      );

  Map<String, dynamic> toJson() => {
        "helpDeskAudio": helpDeskAudio?.toJson(),
      };
}

class HelpDeskAudioClass {
  MediaNode? node;

  HelpDeskAudioClass({
    this.node,
  });

  factory HelpDeskAudioClass.fromJson(Map<String, dynamic> json) =>
      HelpDeskAudioClass(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

// class HelpDeskAudioNode {
//   int? mediaItemId;
//   String? mediaItemUrl;

//   HelpDeskAudioNode({
//     this.mediaItemId,
//     this.mediaItemUrl,
//   });

//   factory HelpDeskAudioNode.fromJson(Map<String, dynamic> json) =>
//       HelpDeskAudioNode(
//         mediaItemId: json["mediaItemId"],
//         mediaItemUrl: json["mediaItemUrl"],
//       );

//   Map<String, dynamic> toJson() => {
//         "mediaItemId": mediaItemId,
//         "mediaItemUrl": mediaItemUrl,
//       };
// }

class HelpDeskImageSection {
  HelpDeskAudioClass? helpDeskImage;

  HelpDeskImageSection({
    this.helpDeskImage,
  });

  factory HelpDeskImageSection.fromJson(Map<String, dynamic> json) =>
      HelpDeskImageSection(
        helpDeskImage: json["helpDeskImage"] == null
            ? null
            : HelpDeskAudioClass.fromJson(json["helpDeskImage"]),
      );

  Map<String, dynamic> toJson() => {
        "helpDeskImage": helpDeskImage?.toJson(),
      };
}

class HelpDeskVideoSection {
  VideoFile? videoFile;
  String? videoFileUrl;

  HelpDeskVideoSection({
    this.videoFile,
    this.videoFileUrl,
  });

  factory HelpDeskVideoSection.fromJson(Map<String, dynamic> json) =>
      HelpDeskVideoSection(
        videoFileUrl: json["videoFileUrl"],
        videoFile: json["videoFile"] == null
            ? null
            : VideoFile.fromJson(json["videoFile"]),
      );

  Map<String, dynamic> toJson() => {
        "videoFileUrl": videoFileUrl,
        "videoFile": videoFile?.toJson(),
      };

  String get videoUrl {
    if (videoFileUrl?.isEmpty ?? false) return '';
    // Split the URL by '/'
    List<String> parts = videoFileUrl?.split('/') ?? [];

    if (parts.isNotEmpty) {
      // Get the last part of the URL
      String videoId = parts.last;
      return 'https://vz-a554f220-6c6.b-cdn.net/$videoId/playlist.m3u8';
    } else {
      return videoFile?.node?.mediaItemUrl ?? '';
    }
  }
}

class VideoFile {
  VideoFileNode? node;

  VideoFile({
    this.node,
  });

  factory VideoFile.fromJson(Map<String, dynamic> json) => VideoFile(
        node:
            json["node"] == null ? null : VideoFileNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class VideoFileNode {
  int? mediaItemId;
  String? mediaItemUrl;
  String? mediaType;

  VideoFileNode({
    this.mediaItemId,
    this.mediaItemUrl,
    this.mediaType,
  });

  factory VideoFileNode.fromJson(Map<String, dynamic> json) => VideoFileNode(
        mediaItemId: json["mediaItemId"],
        mediaItemUrl: json["mediaItemUrl"],
        mediaType: json["mediaType"],
      );

  Map<String, dynamic> toJson() => {
        "mediaItemId": mediaItemId,
        "mediaItemUrl": mediaItemUrl,
        "mediaType": mediaType,
      };
}
