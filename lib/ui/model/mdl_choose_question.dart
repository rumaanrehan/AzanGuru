// To parse this JSON data, do
//
//     final agQuestions = agQuestionsFromJson(jsonString);

import 'dart:convert';
import 'package:azan_guru_mobile/constant/extensions.dart';
import 'package:azan_guru_mobile/ui/model/media_node.dart';

AgQuestions agQuestionsFromJson(String str) =>
    AgQuestions.fromJson(json.decode(str));

String agQuestionsToJson(AgQuestions data) => json.encode(data.toJson());

class AgQuestions {
  List<AgQuestionsNode>? nodes;

  AgQuestions({
    this.nodes,
  });

  factory AgQuestions.fromJson(Map<String, dynamic> json) => AgQuestions(
        nodes: json["nodes"] == null
            ? []
            : List<AgQuestionsNode>.from(
                json["nodes"]!.map((x) => AgQuestionsNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class AgQuestionsNode {
  String? id;
  String? title;
  DateTime? date;
  int? agQuestionId;
  ChooseYourCourse? chooseYourCourse;

  AgQuestionsNode({
    this.id,
    this.title,
    this.date,
    this.agQuestionId,
    this.chooseYourCourse,
  });

  factory AgQuestionsNode.fromJson(Map<String, dynamic> json) =>
      AgQuestionsNode(
        id: json["id"],
        title: json["title"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        agQuestionId: json["agQuestionId"],
        chooseYourCourse: json["chooseYourCourse"] == null
            ? null
            : ChooseYourCourse.fromJson(json["chooseYourCourse"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "date": date?.toIso8601String(),
        "agQuestionId": agQuestionId,
        "chooseYourCourse": chooseYourCourse?.toJson(),
      };
}

class ChooseYourCourse {
  String? alphabetOrderWordOrder;
  String? alphabets;
  List<String>? questionType;
  List<Option>? options;
  String? questionInUrdu;
  dynamic questionAudio;
  CorrectAlphabetNextQuestion? correctAlphabetNextQuestion;
  dynamic correctAlphabetOrder;
  dynamic incorectAlphabetNextQuestion;
  IncorrectAlphabetOrder? incorrectAlphabetOrder;

  List<Option>? get optionIndexed => options?.mapIndexed((e, i) {
        e.oldIndex ??= i + 1;
        return e;
      }).toList();

  ChooseYourCourse({
    this.alphabetOrderWordOrder,
    this.alphabets,
    this.questionType,
    this.options,
    this.questionInUrdu,
    this.questionAudio,
    this.correctAlphabetNextQuestion,
    this.correctAlphabetOrder,
    this.incorectAlphabetNextQuestion,
    this.incorrectAlphabetOrder,
  });

  factory ChooseYourCourse.fromJson(Map<String, dynamic> json) =>
      ChooseYourCourse(
        alphabetOrderWordOrder: json["alphabetOrderWordOrder"],
        alphabets: json["alphabets"],
        questionType: json["questionType"] == null
            ? []
            : List<String>.from(json["questionType"]!.map((x) => x)),
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
        questionInUrdu: json["questionInUrdu"],
        questionAudio: json["questionAudio"],
        correctAlphabetNextQuestion: json["correctAlphabetNextQuestion"] == null
            ? null
            : CorrectAlphabetNextQuestion.fromJson(
                json["correctAlphabetNextQuestion"]),
        correctAlphabetOrder: json["correctAlphabetOrder"],
        incorectAlphabetNextQuestion: json["incorectAlphabetNextQuestion"],
        incorrectAlphabetOrder: json["incorrectAlphabetOrder"] == null
            ? null
            : IncorrectAlphabetOrder.fromJson(json["incorrectAlphabetOrder"]),
      );

  Map<String, dynamic> toJson() => {
        "alphabetOrderWordOrder": alphabetOrderWordOrder,
        "alphabets": alphabets,
        "questionType": questionType == null
            ? []
            : List<dynamic>.from(questionType!.map((x) => x)),
        "options": options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
        "questionInUrdu": questionInUrdu,
        "questionAudio": questionAudio,
        "correctAlphabetNextQuestion": correctAlphabetNextQuestion?.toJson(),
        "correctAlphabetOrder": correctAlphabetOrder,
        "incorectAlphabetNextQuestion": incorectAlphabetNextQuestion,
        "incorrectAlphabetOrder": incorrectAlphabetOrder?.toJson(),
      };
}

class IncorrectAlphabetOrder {
  List<IncorrectAlphabetOrderEdge>? edges;

  IncorrectAlphabetOrder({
    this.edges,
  });

  factory IncorrectAlphabetOrder.fromJson(Map<String, dynamic> json) =>
      IncorrectAlphabetOrder(
        edges: json["edges"] == null
            ? []
            : List<IncorrectAlphabetOrderEdge>.from(json["edges"]!
                .map((x) => IncorrectAlphabetOrderEdge.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "edges": edges == null
            ? []
            : List<dynamic>.from(edges!.map((x) => x.toJson())),
      };
}

class IncorrectAlphabetOrderEdge {
  ShowCourseNode? node;

  IncorrectAlphabetOrderEdge({
    this.node,
  });

  factory IncorrectAlphabetOrderEdge.fromJson(Map<String, dynamic> json) =>
      IncorrectAlphabetOrderEdge(
        node:
            json["node"] == null ? null : ShowCourseNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class CorrectAlphabetNextQuestion {
  List<CorrectAlphabetNextQuestionEdge>? edges;

  CorrectAlphabetNextQuestion({
    this.edges,
  });

  factory CorrectAlphabetNextQuestion.fromJson(Map<String, dynamic> json) =>
      CorrectAlphabetNextQuestion(
        edges: json["edges"] == null
            ? []
            : List<CorrectAlphabetNextQuestionEdge>.from(json["edges"]!
                .map((x) => CorrectAlphabetNextQuestionEdge.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "edges": edges == null
            ? []
            : List<dynamic>.from(edges!.map((x) => x.toJson())),
      };
}

class CorrectAlphabetNextQuestionEdge {
  NextQuestionNode? node;

  CorrectAlphabetNextQuestionEdge({
    this.node,
  });

  factory CorrectAlphabetNextQuestionEdge.fromJson(Map<String, dynamic> json) =>
      CorrectAlphabetNextQuestionEdge(
        node: json["node"] == null
            ? null
            : NextQuestionNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class Option {
  String? option;
  List<String>? questionIcon;
  AudioOption? audioOption;
  NextQuestion? nextQuestion;
  ShowCourse? showCourse;
  bool? isSelected;

  /// for local use only
  int? oldIndex;

  Option({
    this.option,
    this.questionIcon,
    this.audioOption,
    this.nextQuestion,
    this.showCourse,
    this.isSelected,
    this.oldIndex,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        option: json["option"],
        questionIcon: json["questionIcon"] == null
            ? []
            : List<String>.from(json["questionIcon"]!.map((x) => x)),
        audioOption: json["audioOption"] == null
            ? null
            : AudioOption.fromJson(json["audioOption"]),
        nextQuestion: json["nextQuestion"] == null
            ? null
            : NextQuestion.fromJson(json["nextQuestion"]),
        showCourse: json["showCourse"] == null
            ? null
            : ShowCourse.fromJson(json["showCourse"]),
      );

  Map<String, dynamic> toJson() => {
        "option": option,
        "questionIcon": questionIcon == null
            ? []
            : List<dynamic>.from(questionIcon!.map((x) => x)),
        "audioOption": audioOption?.toJson(),
        "nextQuestion": nextQuestion?.toJson(),
        "showCourse": showCourse?.toJson(),
      };
}

class AudioOption {
  MediaNode? node;

  AudioOption({
    this.node,
  });

  factory AudioOption.fromJson(Map<String, dynamic> json) => AudioOption(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class NextQuestion {
  List<NextQuestionNode>? nodes;

  NextQuestion({
    this.nodes,
  });

  factory NextQuestion.fromJson(Map<String, dynamic> json) => NextQuestion(
        nodes: json["nodes"] == null
            ? []
            : List<NextQuestionNode>.from(
                json["nodes"]!.map((x) => NextQuestionNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class NextQuestionNode {
  String? slug;
  String? status;
  String? id;

  NextQuestionNode({
    this.slug,
    this.status,
    this.id,
  });

  factory NextQuestionNode.fromJson(Map<String, dynamic> json) =>
      NextQuestionNode(
        slug: json["slug"],
        status: json["status"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "status": status,
        "id": id,
      };
}

class ShowCourse {
  List<ShowCourseNode>? nodes;

  ShowCourse({
    this.nodes,
  });

  factory ShowCourse.fromJson(Map<String, dynamic> json) => ShowCourse(
        nodes: json["nodes"] == null
            ? []
            : List<ShowCourseNode>.from(
                json["nodes"]!.map((x) => ShowCourseNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class ShowCourseNode {
  String? id;
  String? name;
  String? description;
  CourseTypeImage? courseTypeImage;

  ShowCourseNode({
    this.id,
    this.name,
    this.description,
    this.courseTypeImage,
  });

  factory ShowCourseNode.fromJson(Map<String, dynamic> json) => ShowCourseNode(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        courseTypeImage: json["courseTypeImage"] == null
            ? null
            : CourseTypeImage.fromJson(json["courseTypeImage"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "courseTypeImage": courseTypeImage?.toJson(),
      };
}

class CourseTypeImage {
  CourseCategoryImage? courseCategoryImage;
  String? chooseCourseInfo;

  CourseTypeImage({
    this.courseCategoryImage,
    this.chooseCourseInfo,
  });

  factory CourseTypeImage.fromJson(Map<String, dynamic> json) =>
      CourseTypeImage(
        courseCategoryImage: json["courseCategoryImage"] == null
            ? null
            : CourseCategoryImage.fromJson(json["courseCategoryImage"]),
        chooseCourseInfo: json["chooseCourseInfo"],
      );

  Map<String, dynamic> toJson() => {
        "courseCategoryImage": courseCategoryImage?.toJson(),
      };
}

class CourseCategoryImage {
  CourseCategoryImageNode? node;

  CourseCategoryImage({
    this.node,
  });

  factory CourseCategoryImage.fromJson(Map<String, dynamic> json) =>
      CourseCategoryImage(
        node: json["node"] == null
            ? null
            : CourseCategoryImageNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class CourseCategoryImageNode {
  int? mediaItemId;
  String? mediaItemUrl;

  CourseCategoryImageNode({
    this.mediaItemId,
    this.mediaItemUrl,
  });

  factory CourseCategoryImageNode.fromJson(Map<String, dynamic> json) =>
      CourseCategoryImageNode(
        mediaItemId: json["mediaItemId"],
        mediaItemUrl: json["mediaItemUrl"],
      );

  Map<String, dynamic> toJson() => {
        "mediaItemId": mediaItemId,
        "mediaItemUrl": mediaItemUrl,
      };
}
