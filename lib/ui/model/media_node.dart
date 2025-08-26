// class MediaNode {
//   int? mediaItemId;
//   String? mediaItemUrl;
//   String? title;
//
//   /// for local use
//   bool? isSelected;
//
//   MediaNode({
//     this.mediaItemId,
//     this.mediaItemUrl,
//     this.title,
//     this.isSelected,
//   });
//
//   factory MediaNode.fromJson(Map<String, dynamic> json) => MediaNode(
//         mediaItemId: json["mediaItemId"],
//         mediaItemUrl: json["mediaItemUrl"],
//         title: json["title"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "mediaItemId": mediaItemId,
//         "mediaItemUrl": mediaItemUrl,
//         "title": title,
//       };
// }






import 'package:hive/hive.dart';

part 'media_node.g.dart';

@HiveType(typeId: 4)
class MediaNode extends HiveObject {
  @HiveField(0)
  int? mediaItemId;

  @HiveField(1)
  String? mediaItemUrl;

  @HiveField(2)
  String? title;

  /// for local use
  @HiveField(3)
  bool? isSelected;

  MediaNode({
    this.mediaItemId,
    this.mediaItemUrl,
    this.title,
    this.isSelected,
  });

  factory MediaNode.fromJson(Map<String, dynamic> json) => MediaNode(
    mediaItemId: json["mediaItemId"],
    mediaItemUrl: json["mediaItemUrl"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "mediaItemId": mediaItemId,
    "mediaItemUrl": mediaItemUrl,
    "title": title,
  };
}
