import 'package:azan_guru_mobile/ui/model/media_node.dart';

class Media {
  MediaNode? node;

  Media({
    this.node,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}
