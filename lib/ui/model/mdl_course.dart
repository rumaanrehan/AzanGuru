import 'package:azan_guru_mobile/ui/model/ag_categories_data.dart';

class MDLCourseList {
  String? title;
  int? count;
  double? studentProgress;
  List<AgCategoriesNode>? mdlCourse;
  StudentCompletedLessons? studentCompletedLessons;

  MDLCourseList({
    this.title,
    this.count,
    this.studentProgress,
    this.studentCompletedLessons,
    this.mdlCourse,
  });
}

class StudentCompletedLessons {
  List<LessonNodes>? nodes;

  StudentCompletedLessons({this.nodes});

  StudentCompletedLessons.fromJson(Map<String, dynamic> json) {
    if (json['nodes'] != null) {
      nodes = <LessonNodes>[];
      json['nodes'].forEach((v) {
        nodes!.add(LessonNodes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (nodes != null) {
      data['nodes'] = nodes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LessonNodes {
  String? id;

  LessonNodes({this.id});

  LessonNodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}
