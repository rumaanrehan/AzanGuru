import 'dart:convert';
import 'package:azan_guru_mobile/ui/model/next_lesson_node.dart';

AgCourseLessonList agCourseLessonListFromJson(String str) =>
    AgCourseLessonList.fromJson(json.decode(str));

String agCourseLessonListToJson(AgCourseLessonList data) =>
    json.encode(data.toJson());

class AgCourseLessonList {
  AgCourses? agCourses;

  AgCourseLessonList({
    this.agCourses,
  });

  factory AgCourseLessonList.fromJson(Map<String, dynamic> json) =>
      AgCourseLessonList(
        agCourses: json["agCourseCategoryPosts"] == null
            ? null
            : AgCourses.fromJson(json["agCourseCategoryPosts"]),
      );

  Map<String, dynamic> toJson() => {
        "agCourseCategoryPosts": agCourses?.toJson(),
      };
}

class AgCourses {
  List<Lesson>? nodes;

  AgCourses({
    this.nodes,
  });

  factory AgCourses.fromJson(Map<String, dynamic> json) => AgCourses(
        nodes: json["nodes"] == null
            ? []
            : List<Lesson>.from(json["nodes"]!.map((x) => Lesson.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class Lesson {
  String? id;
  String? title;
  DateTime? date;
  LessonVideo? lessonVideo;
  bool? completed;

  /// for local use only
  // bool? isLessonCompleted;

  Lesson({
    this.id,
    this.title,
    this.date,
    this.lessonVideo,
    this.completed,
    // this.isLessonCompleted,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json["id"],
        title: json["title"],
        completed: json["completed"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        lessonVideo: json["lessonVideo"] == null
            ? null
            : LessonVideo.fromJson(json["lessonVideo"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "completed": completed,
        "date": date?.toIso8601String(),
        "lessonVideo": lessonVideo?.toJson(),
      };
}

class LessonVideo {
  String? videoDetails;
  NextLesson? nextLesson;

  LessonVideo({
    this.videoDetails,
    this.nextLesson,
  });

  factory LessonVideo.fromJson(Map<String, dynamic> json) => LessonVideo(
        videoDetails: json["videoDetails"],
        nextLesson: json["nextLesson"] == null
            ? null
            : NextLesson.fromJson(json["nextLesson"]),
      );

  Map<String, dynamic> toJson() => {
        "videoDetails": videoDetails,
        "nextLesson": nextLesson?.toJson(),
      };
}

class NextLesson {
  List<Edge>? edges;

  NextLesson({
    this.edges,
  });

  factory NextLesson.fromJson(Map<String, dynamic> json) => NextLesson(
        edges: json["edges"] == null
            ? []
            : List<Edge>.from(json["edges"]!.map((x) => Edge.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "edges": edges == null
            ? []
            : List<dynamic>.from(edges!.map((x) => x.toJson())),
      };
}

class Edge {
  NextLessonNode? node;

  Edge({
    this.node,
  });

  factory Edge.fromJson(Map<String, dynamic> json) => Edge(
        node:
            json["node"] == null ? null : NextLessonNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}
