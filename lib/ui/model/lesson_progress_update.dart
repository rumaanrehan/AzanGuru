class MDLLessonProgress {
  Data? data;

  MDLLessonProgress({this.data});

  MDLLessonProgress.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Users? users;

  Data({this.users});

  Data.fromJson(Map<String, dynamic> json) {
    users = json['users'] != null ? Users.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (users != null) {
      data['users'] = users!.toJson();
    }
    return data;
  }
}

class Users {
  List<Nodes>? nodes;

  Users({this.nodes});

  Users.fromJson(Map<String, dynamic> json) {
    if (json['nodes'] != null) {
      nodes = <Nodes>[];
      json['nodes'].forEach((v) {
        nodes!.add(Nodes.fromJson(v));
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

class Nodes {
  String? id;
  String? username;
  String? email;
  StudentsOptions? studentsOptions;

  Nodes({this.id, this.username, this.email, this.studentsOptions});

  Nodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    studentsOptions = json['studentsOptions'] != null
        ? StudentsOptions.fromJson(json['studentsOptions'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    if (studentsOptions != null) {
      data['studentsOptions'] = studentsOptions!.toJson();
    }
    return data;
  }
}

class StudentsOptions {
  int? studentAge;
  List<String>? studentBatch;
  double? studentProgress;
  String? studentUpdatedTime;
  String? studentCompletedQuizzes;

  StudentsOptions(
      {this.studentAge,
      this.studentBatch,
      this.studentCompletedQuizzes,
      this.studentProgress});

  StudentsOptions.fromJson(Map<String, dynamic> json) {
    studentAge = json['studentAge'];
    studentBatch = json['studentBatch'];
    studentCompletedQuizzes = json['studentCompletedQuizzes'];
    studentProgress = json['studentProgress'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['studentAge'] = studentAge;
    data['studentBatch'] = studentBatch;
    data['studentProgress'] = studentProgress ?? 0;
    data['studentUpdatedTime'] = studentUpdatedTime;
    data['studentCompletedQuizzes'] = studentCompletedQuizzes;
    return data;
  }
}
