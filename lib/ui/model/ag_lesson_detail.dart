import 'dart:convert';

import 'package:azan_guru_mobile/ui/model/audio_element.dart';
import 'package:azan_guru_mobile/ui/model/image_element.dart';
import 'package:azan_guru_mobile/ui/model/media.dart';
import 'package:azan_guru_mobile/ui/model/media_node.dart';
import 'package:azan_guru_mobile/ui/model/next_lesson_node.dart';
import 'package:azan_guru_mobile/ui/model/video_element.dart';

LessonDetail lessonDetailFromJson(String str) =>
    LessonDetail.fromJson(json.decode(str));

String lessonDetailToJson(LessonDetail data) => json.encode(data.toJson());

class HomeWork {
  List<LessonDetail>? nodes;

  HomeWork({
    this.nodes,
  });

  factory HomeWork.fromJson(Map<String, dynamic> json) => HomeWork(
        nodes: json["nodes"] == null
            ? []
            : List<LessonDetail>.from(
                json["nodes"]!.map((x) => LessonDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class LessonVideo {
  String? videoDetails;
  String? streamVideoUrl;
  Media? video;
  HomeWork? homeWork;
  Quizzes? quizzes;
  NextLesson? nextLesson;

  LessonVideo({
    this.videoDetails,
    this.streamVideoUrl,
    this.video,
    this.homeWork,
    this.quizzes,
    this.nextLesson,
  });

  factory LessonVideo.fromJson(Map<String, dynamic> json) => LessonVideo(
        videoDetails: json["videoDetails"],
        streamVideoUrl: json["streamVideoUrl"],
        video: json["video"] == null ? null : Media.fromJson(json["video"]),
        homeWork: json["homeWork"] == null
            ? null
            : HomeWork.fromJson(json["homeWork"]),
        quizzes:
            json["quizzes"] == null ? null : Quizzes.fromJson(json["quizzes"]),
        nextLesson: json["nextLesson"] == null
            ? null
            : NextLesson.fromJson(json["nextLesson"]),
      );

  Map<String, dynamic> toJson() => {
        "videoDetails": videoDetails,
        "streamVideoUrl": streamVideoUrl,
        "video": video?.toJson(),
        "homeWork": homeWork?.toJson(),
        "quizzes": quizzes?.toJson(),
        "nextLesson": nextLesson?.toJson(),
      };

  String get videoUrl {
    if (streamVideoUrl?.isEmpty ?? false) return '';
    // Split the URL by '/'
    List<String> parts = streamVideoUrl?.split('/') ?? [];

    if (parts.isNotEmpty) {
      // Get the last part of the URL
      String videoId = parts.last;
      return 'https://vz-a554f220-6c6.b-cdn.net/$videoId/playlist.m3u8';
    } else {
      return video?.node?.mediaItemUrl ?? '';
    }
  }

  String get videoThumbnail {
    // Split the URL by '/'
    List<String> parts = streamVideoUrl?.split('/') ?? [];

    if (parts.isNotEmpty) {
      // Get the last part of the URL
      String videoId = parts.last;
      return 'https://vz-a554f220-6c6.b-cdn.net/$videoId/thumbnail.jpg';
    } else {
      return '';
    }
  }
}

class LessonDetail {
  String? id;
  String? title;
  DateTime? date;
  int? databaseId;
  LessonVideo? lessonVideo;
  LessonHomeWork? lessonHomeWork;

  LessonDetail({
    this.id,
    this.title,
    this.date,
    this.databaseId,
    this.lessonVideo,
    this.lessonHomeWork,
  });

  factory LessonDetail.fromJson(Map<String, dynamic> json) => LessonDetail(
        id: json["id"],
        title: json["title"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        databaseId: json["databaseId"],
        lessonVideo: json["lessonVideo"] == null
            ? null
            : LessonVideo.fromJson(json["lessonVideo"]),
        lessonHomeWork: json["lessonHomeWork"] == null
            ? null
            : LessonHomeWork.fromJson(json["lessonHomeWork"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "date": date?.toIso8601String(),
        "databaseId": databaseId,
        "lessonVideo": lessonVideo?.toJson(),
        "lessonHomeWork": lessonHomeWork?.toJson(),
      };
}

class NextLesson {
  List<NextLessonNode>? nodes;

  NextLesson({
    this.nodes,
  });

  factory NextLesson.fromJson(Map<String, dynamic> json) => NextLesson(
        nodes: json["nodes"] == null
            ? []
            : List<NextLessonNode>.from(
                json["nodes"]!.map((x) => NextLessonNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class Quizzes {
  List<QuizzesNode>? nodes;

  Quizzes({
    this.nodes,
  });

  factory Quizzes.fromJson(Map<String, dynamic> json) => Quizzes(
        nodes: json["nodes"] == null
            ? []
            : List<QuizzesNode>.from(
                json["nodes"]!.map((x) => QuizzesNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class QuizzesNode {
  AgQuizzes? agQuizzes;

  QuizzesNode({
    this.agQuizzes,
  });

  factory QuizzesNode.fromJson(Map<String, dynamic> json) => QuizzesNode(
        agQuizzes: json["agQuizzes"] == null
            ? null
            : AgQuizzes.fromJson(json["agQuizzes"]),
      );

  Map<String, dynamic> toJson() => {
        "agQuizzes": agQuizzes?.toJson(),
      };
}

class AgQuizzes {
  List<AgQuizzesNode>? nodes;

  AgQuizzes({
    this.nodes,
  });

  factory AgQuizzes.fromJson(Map<String, dynamic> json) => AgQuizzes(
        nodes: json["nodes"] == null
            ? []
            : List<AgQuizzesNode>.from(
                json["nodes"]!.map((x) => AgQuizzesNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class AgQuizzesNode {
  String? id;
  String? title;
  int? databaseId;
  LessonQuiz? lessonQuiz;

  ///for local use only
  bool? isAnswerSubmitted;
  List<String>? givenAnswerList;
  List<String>? givenAnswerListIndex;

  AgQuizzesNode({
    this.id,
    this.title,
    this.databaseId,
    this.lessonQuiz,
    this.isAnswerSubmitted,
    this.givenAnswerList = const [],
    this.givenAnswerListIndex = const [],
  });

  factory AgQuizzesNode.fromJson(Map<String, dynamic> json) => AgQuizzesNode(
        id: json["id"],
        title: json["title"],
        databaseId: json["databaseId"],
        lessonQuiz: json["lessonQuiz"] == null
            ? null
            : LessonQuiz.fromJson(json["lessonQuiz"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "databaseId": databaseId,
        "lessonQuiz": lessonQuiz?.toJson(),
      };
}

class LessonQuiz {
  List<CreateYourQuiz>? createYourQuiz;

  LessonQuiz({
    this.createYourQuiz,
  });

  factory LessonQuiz.fromJson(Map<String, dynamic> json) => LessonQuiz(
        createYourQuiz: json["createYourQuiz"] == null
            ? []
            : List<CreateYourQuiz>.from(
                json["createYourQuiz"]!.map((x) => CreateYourQuiz.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "createYourQuiz": createYourQuiz == null
            ? []
            : List<dynamic>.from(createYourQuiz!.map((x) => x.toJson())),
      };
}

class CreateYourQuiz {
  List<Option>? options;
  QuizNameAudio? quizNameAudio;
  QuizNameAudio? quizImage;
  String? quizType;
  String? answer;
  List<AudioElement>? audios;

  CreateYourQuiz({
    this.options,
    this.quizNameAudio,
    this.quizImage,
    this.quizType,
    this.answer,
    this.audios,
  });

  factory CreateYourQuiz.fromJson(Map<String, dynamic> json) => CreateYourQuiz(
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
        quizNameAudio: json["quizNameAudio"] == null
            ? null
            : QuizNameAudio.fromJson(json["quizNameAudio"]),
        quizImage: json["quizImage"] == null
            ? null
            : QuizNameAudio.fromJson(json["quizImage"]),
        quizType: json["quizType"],
        answer: json["answer"],
        audios: json["audios"] == null
            ? []
            : List<AudioElement>.from(
                json["audios"]!.map((x) => AudioElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "options": options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
        "quizNameAudio": quizNameAudio?.toJson(),
        "quizImage": quizImage?.toJson(),
        "quizType": quizType,
        "answer": answer,
        "audios": audios == null
            ? []
            : List<dynamic>.from(audios!.map((x) => x.toJson())),
      };
}

class QuizNameAudio {
  MediaNode? node;

  QuizNameAudio({
    this.node,
  });

  factory QuizNameAudio.fromJson(Map<String, dynamic> json) => QuizNameAudio(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class Option {
  String? value;

  /// for local use only
  bool? isSelected;
  int? oldIndex;

  Option({
    this.value,
    this.isSelected,
    this.oldIndex,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
      };
}

class LessonHomeWork {
  bool? audioRecordingFromStudent;
  List<HomeWorkType>? homeWorkType;

  LessonHomeWork({
    this.audioRecordingFromStudent,
    this.homeWorkType,
  });

  factory LessonHomeWork.fromJson(Map<String, dynamic> json) => LessonHomeWork(
        audioRecordingFromStudent: json["audioRecordingFromStudent"],
        homeWorkType: json["homeWorkType"] == null
            ? []
            : List<HomeWorkType>.from(
                json["homeWorkType"]!.map((x) => HomeWorkType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "audioRecordingFromStudent": audioRecordingFromStudent,
        "homeWorkType": homeWorkType == null
            ? []
            : List<dynamic>.from(homeWorkType!.map((x) => x.toJson())),
      };
}

class HomeWorkType {
  List<AudioElement>? audios;
  List<VideoElement>? videos;
  List<ImageElement>? images;

  HomeWorkType({
    this.audios,
    this.videos,
    this.images,
  });

  factory HomeWorkType.fromJson(Map<String, dynamic> json) => HomeWorkType(
        audios: json["audios"] == null
            ? []
            : List<AudioElement>.from(
                json["audios"]!.map((x) => AudioElement.fromJson(x))),
        videos: json["videos"] == null
            ? []
            : List<VideoElement>.from(
                json["videos"]!.map((x) => VideoElement.fromJson(x))),
        images: json["images"] == null
            ? []
            : List<ImageElement>.from(
                json["images"]!.map((x) => ImageElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "audios": audios == null
            ? []
            : List<dynamic>.from(audios!.map((x) => x.toJson())),
        "videos": videos == null
            ? []
            : List<dynamic>.from(videos!.map((x) => x.toJson())),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
      };
}
