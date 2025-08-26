// To parse this JSON data, do
//
//     final agCategories = agCategoriesFromJson(jsonString);

import 'dart:convert';

import 'package:azan_guru_mobile/ui/model/media_node.dart';

AgCategories agCategoriesFromJson(String str) =>
    AgCategories.fromJson(json.decode(str));

String agCategoriesToJson(AgCategories data) => json.encode(data.toJson());

class AgCategories {
  List<AgCategoriesNode>? nodes;

  AgCategories({
    this.nodes,
  });

  factory AgCategories.fromJson(Map<String, dynamic> json) => AgCategories(
        nodes: json["nodes"] == null
            ? []
            : List<AgCategoriesNode>.from(
                json["nodes"]!.map((x) => AgCategoriesNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class AgCategoriesNode {
  String? id;
  String? name;
  String? description;
  int? count;
  int? databaseId;
  CourseTypeImage? courseTypeImage;
  AgCourses? agCourses;
  AgCategoriesNode({
    this.id,
    this.name,
    this.description,
    this.count,
    this.databaseId,
    this.courseTypeImage,
    this.agCourses,
  });

  factory AgCategoriesNode.fromJson(Map<String, dynamic> json) =>
      AgCategoriesNode(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        count: json["count"],
        databaseId: json["databaseId"],
        courseTypeImage: json["courseTypeImage"] == null
            ? null
            : CourseTypeImage.fromJson(json["courseTypeImage"]),
        agCourses: json["agCourses"] == null
            ? null
            : AgCourses.fromJson(json["agCourses"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "count": count,
        "databaseId": databaseId,
        "courseTypeImage": courseTypeImage?.toJson(),
        "agCourses": agCourses?.toJson(),
      };
}

class AgCourses {
  List<AgCoursesNode>? nodes;

  AgCourses({
    this.nodes,
  });

  factory AgCourses.fromJson(Map<String, dynamic> json) => AgCourses(
        nodes: json["nodes"] == null
            ? []
            : List<AgCoursesNode>.from(
                json["nodes"]!.map((x) => AgCoursesNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class AgCoursesNode {
  int? agCourseId;
  String? id;
  String? title;
  LessonVideo? lessonVideo;
  dynamic preview;

  AgCoursesNode({
    this.agCourseId,
    this.id,
    this.title,
    this.lessonVideo,
    this.preview,
  });

  factory AgCoursesNode.fromJson(Map<String, dynamic> json) => AgCoursesNode(
        agCourseId: json["agCourseId"],
        id: json["id"],
        title: json["title"],
        lessonVideo: json["lessonVideo"] == null
            ? null
            : LessonVideo.fromJson(json["lessonVideo"]),
        preview: json["preview"],
      );

  Map<String, dynamic> toJson() => {
        "agCourseId": agCourseId,
        "id": id,
        "title": title,
        "lessonVideo": lessonVideo?.toJson(),
        "preview": preview,
      };
}

class LessonVideo {
  Video? video;

  LessonVideo({
    this.video,
  });

  factory LessonVideo.fromJson(Map<String, dynamic> json) => LessonVideo(
        video: json["video"] == null ? null : Video.fromJson(json["video"]),
      );

  Map<String, dynamic> toJson() => {
        "video": video?.toJson(),
      };
}

class Video {
  MediaNode? node;

  Video({
    this.node,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class CourseTypeImage {
  CourseCategoryImage? courseCategoryImage;
  String? courseHours;

  CourseTypeImage({
    this.courseCategoryImage,
    this.courseHours,
  });

  factory CourseTypeImage.fromJson(Map<String, dynamic> json) =>
      CourseTypeImage(
        courseCategoryImage: json["courseCategoryImage"] == null
            ? null
            : CourseCategoryImage.fromJson(json["courseCategoryImage"]),
        courseHours: json["courseHours"],
      );

  Map<String, dynamic> toJson() => {
        "courseCategoryImage": courseCategoryImage?.toJson(),
        "courseHours": courseHours,
      };
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
