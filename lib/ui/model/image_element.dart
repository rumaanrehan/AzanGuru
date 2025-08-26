import 'package:azan_guru_mobile/ui/model/media.dart';

class ImageElement {
  Media? image;

  ImageElement({
    this.image,
  });

  factory ImageElement.fromJson(Map<String, dynamic> json) => ImageElement(
        image: json["image"] == null ? null : Media.fromJson(json["image"]),
      );

  Map<String, dynamic> toJson() => {
        "image": image?.toJson(),
      };
}
