// To parse this JSON data, do
//
//     final agCourseDetail = agCourseDetailFromJson(jsonString);

import 'dart:convert';

import 'package:azan_guru_mobile/ui/model/mdl_course.dart';
import 'package:azan_guru_mobile/ui/model/media_node.dart';

AgCourseDetail agCourseDetailFromJson(String str) =>
    AgCourseDetail.fromJson(json.decode(str));

String agCourseDetailToJson(AgCourseDetail data) => json.encode(data.toJson());

class AgCourseDetail {
  String? id;
  int? count;
  int? databaseId;
  String? name;
  String? description;
  CourseTypeImage? courseTypeImage;

  AgCourseDetail({
    this.id,
    this.count,
    this.databaseId,
    this.name,
    this.description,
    this.courseTypeImage,
  });

  factory AgCourseDetail.fromJson(Map<String, dynamic> json) => AgCourseDetail(
        id: json["id"],
        count: json["count"],
        databaseId: json["databaseId"],
        name: json["name"],
        description: json["description"],
        courseTypeImage: json["courseTypeImage"] == null
            ? null
            : CourseTypeImage.fromJson(json["courseTypeImage"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "count": count,
        "databaseId": databaseId,
        "name": name,
        "description": description,
        "courseTypeImage": courseTypeImage?.toJson(),
      };
}

class CourseTypeImage {
  CourseCategoryImage? courseCategoryImage;
  String? courseHours;
  String? coursePrice;
  String? coursePreviewUrl;
  CoursePreview? coursePreview;
  StudentCompletedLessons? completedLessons;

  CourseTypeImage({
    this.courseCategoryImage,
    this.courseHours,
    this.coursePrice,
    this.coursePreview,
    this.coursePreviewUrl,
    this.completedLessons,
  });

  factory CourseTypeImage.fromJson(Map<String, dynamic> json) =>
      CourseTypeImage(
        courseCategoryImage: json["courseCategoryImage"] == null
            ? null
            : CourseCategoryImage.fromJson(json["courseCategoryImage"]),
        courseHours: json["courseHours"],
        coursePrice: json["coursePrice"],
        coursePreviewUrl: json["coursePreviewUrl"],
        coursePreview: json["coursePreview"] == null
            ? null
            : CoursePreview.fromJson(json["coursePreview"]),
        completedLessons: json["studentCompletedLessons"] == null
            ? null
            : StudentCompletedLessons.fromJson(json["studentCompletedLessons"]),
      );

  Map<String, dynamic> toJson() => {
        "courseCategoryImage": courseCategoryImage?.toJson(),
        "courseHours": courseHours,
        "coursePrice": coursePrice,
        "coursePreviewUrl": coursePreviewUrl,
        "coursePreview": coursePreview?.toJson(),
        "studentCompletedLessons": completedLessons?.toJson(),
      };

  String get videoUrl {
    if (coursePreviewUrl?.isEmpty ?? false) return '';
    // Split the URL by '/'
    List<String> parts = coursePreviewUrl?.split('/') ?? [];

    if (parts.isNotEmpty) {
      // Get the last part of the URL
      String videoId = parts.last;
      return 'https://vz-a554f220-6c6.b-cdn.net/$videoId/playlist.m3u8';
    } else {
      return coursePreview?.node?.mediaItemUrl ?? '';
    }
  }
}

class CourseCategoryImage {
  MediaNode? node;

  CourseCategoryImage({
    this.node,
  });

  factory CourseCategoryImage.fromJson(Map<String, dynamic> json) =>
      CourseCategoryImage(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class CoursePreview {
  MediaNode? node;

  CoursePreview({
    this.node,
  });

  factory CoursePreview.fromJson(Map<String, dynamic> json) => CoursePreview(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}
