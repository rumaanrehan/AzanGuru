// // To parse this JSON data, do
// //
// //     final liveClassesData = liveClassesDataFromJson(jsonString);
//
// import 'dart:convert';
//
// LiveClassesData liveClassesDataFromJson(String str) =>
//     LiveClassesData.fromJson(json.decode(str));
//
// String liveClassesDataToJson(LiveClassesData data) =>
//     json.encode(data.toJson());
//
// class LiveClassesData {
//   String? id;
//   GeneralOptionsFields? generalOptionsFields;
//
//   LiveClassesData({
//     this.id,
//     this.generalOptionsFields,
//   });
//
//   factory LiveClassesData.fromJson(Map<String, dynamic> json) =>
//       LiveClassesData(
//         id: json["id"],
//         generalOptionsFields: json["generalOptionsFields"] == null
//             ? null
//             : GeneralOptionsFields.fromJson(json["generalOptionsFields"]),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "generalOptionsFields": generalOptionsFields?.toJson(),
//       };
// }
//
// class GeneralOptionsFields {
//   LiveClassesLink? liveClassesLink;
//   String? liveClassInfo;
//   List<String>? liveClassesAvailability;
//   String? askToLiveTeacher;
//   List<LiveClassInfoSection>? liveClassInfoSection;
//
//   GeneralOptionsFields({
//     this.liveClassesLink,
//     this.liveClassInfo,
//     this.liveClassesAvailability,
//     this.askToLiveTeacher,
//     this.liveClassInfoSection,
//   });
//
//   factory GeneralOptionsFields.fromJson(Map<String, dynamic> json) =>
//       GeneralOptionsFields(
//         liveClassesLink: json["liveClassesLink"] == null
//             ? null
//             : LiveClassesLink.fromJson(json["liveClassesLink"]),
//         liveClassInfo: json["liveClassInfo"],
//         liveClassesAvailability: json["liveClassesAvailability"] == null
//             ? []
//             : List<String>.from(json["liveClassesAvailability"]!.map((x) => x)),
//         askToLiveTeacher: json["askToLiveTeacher"],
//         liveClassInfoSection: json["liveClassInfoSection"] == null
//             ? []
//             : List<LiveClassInfoSection>.from(json["liveClassInfoSection"]!
//                 .map((x) => LiveClassInfoSection.fromJson(x))),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "liveClassesLink": liveClassesLink?.toJson(),
//         "liveClassInfo": liveClassInfo,
//         "liveClassesAvailability": liveClassesAvailability == null
//             ? []
//             : List<dynamic>.from(liveClassesAvailability!.map((x) => x)),
//         "askToLiveTeacher": askToLiveTeacher,
//         "liveClassInfoSection": liveClassInfoSection == null
//             ? []
//             : List<dynamic>.from(liveClassInfoSection!.map((x) => x.toJson())),
//       };
// }
//
// class LiveClassInfoSection {
//   bool? availableForNonSubscribers;
//   List<String>? whichDay;
//   List<AddMoreRange>? addMoreRanges;
//
//   LiveClassInfoSection({
//     this.availableForNonSubscribers,
//     this.whichDay,
//     this.addMoreRanges,
//   });
//
//   factory LiveClassInfoSection.fromJson(Map<String, dynamic> json) =>
//       LiveClassInfoSection(
//         availableForNonSubscribers: json["availableForNonSubscribers"],
//         whichDay: json["whichDay"] == null
//             ? []
//             : List<String>.from(json["whichDay"]!.map((x) => x)),
//         addMoreRanges: json["addMoreRanges"] == null
//             ? []
//             : List<AddMoreRange>.from(
//                 json["addMoreRanges"]!.map((x) => AddMoreRange.fromJson(x))),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "availableForNonSubscribers": availableForNonSubscribers,
//         "whichDay":
//             whichDay == null ? [] : List<dynamic>.from(whichDay!.map((x) => x)),
//         "addMoreRanges": addMoreRanges == null
//             ? []
//             : List<dynamic>.from(addMoreRanges!.map((x) => x.toJson())),
//       };
// }
//
// class AddMoreRange {
//   String? endTime;
//   String? startTime;
//
//   AddMoreRange({
//     this.endTime,
//     this.startTime,
//   });
//
//   factory AddMoreRange.fromJson(Map<String, dynamic> json) => AddMoreRange(
//         endTime: json["endTime"],
//         startTime: json["startTime"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "endTime": endTime,
//         "startTime": startTime,
//       };
// }
//
// class LiveClassesLink {
//   String? title;
//   String? url;
//
//   LiveClassesLink({
//     this.title,
//     this.url,
//   });
//
//   factory LiveClassesLink.fromJson(Map<String, dynamic> json) =>
//       LiveClassesLink(
//         title: json["title"],
//         url: json["url"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "title": title,
//         "url": url,
//       };
// }







import 'package:hive/hive.dart';

part 'live_classes_data.g.dart';

@HiveType(typeId: 5)
class LiveClassesData extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  GeneralOptionsFields? generalOptionsFields;

  LiveClassesData({
    this.id,
    this.generalOptionsFields,
  });

  factory LiveClassesData.fromJson(Map<String, dynamic> json) => LiveClassesData(
    id: json["id"],
    generalOptionsFields: json["generalOptionsFields"] == null
        ? null
        : GeneralOptionsFields.fromJson(json["generalOptionsFields"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "generalOptionsFields": generalOptionsFields?.toJson(),
  };
}

@HiveType(typeId: 6)
class GeneralOptionsFields extends HiveObject {
  @HiveField(0)
  LiveClassesLink? liveClassesLink;

  @HiveField(1)
  String? liveClassInfo;

  @HiveField(2)
  List<String>? liveClassesAvailability;

  @HiveField(3)
  String? askToLiveTeacher;

  @HiveField(4)
  List<LiveClassInfoSection>? liveClassInfoSection;

  GeneralOptionsFields({
    this.liveClassesLink,
    this.liveClassInfo,
    this.liveClassesAvailability,
    this.askToLiveTeacher,
    this.liveClassInfoSection,
  });

  factory GeneralOptionsFields.fromJson(Map<String, dynamic> json) =>
      GeneralOptionsFields(
        liveClassesLink: json["liveClassesLink"] == null
            ? null
            : LiveClassesLink.fromJson(json["liveClassesLink"]),
        liveClassInfo: json["liveClassInfo"],
        liveClassesAvailability: json["liveClassesAvailability"] == null
            ? []
            : List<String>.from(json["liveClassesAvailability"]!.map((x) => x)),
        askToLiveTeacher: json["askToLiveTeacher"],
        liveClassInfoSection: json["liveClassInfoSection"] == null
            ? []
            : List<LiveClassInfoSection>.from(json["liveClassInfoSection"]!
            .map((x) => LiveClassInfoSection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "liveClassesLink": liveClassesLink?.toJson(),
    "liveClassInfo": liveClassInfo,
    "liveClassesAvailability": liveClassesAvailability == null
        ? []
        : List<dynamic>.from(liveClassesAvailability!.map((x) => x)),
    "askToLiveTeacher": askToLiveTeacher,
    "liveClassInfoSection": liveClassInfoSection == null
        ? []
        : List<dynamic>.from(liveClassInfoSection!.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 7)
class LiveClassInfoSection extends HiveObject {
  @HiveField(0)
  bool? availableForNonSubscribers;

  @HiveField(1)
  List<String>? whichDay;

  @HiveField(2)
  List<AddMoreRange>? addMoreRanges;

  LiveClassInfoSection({
    this.availableForNonSubscribers,
    this.whichDay,
    this.addMoreRanges,
  });

  factory LiveClassInfoSection.fromJson(Map<String, dynamic> json) =>
      LiveClassInfoSection(
        availableForNonSubscribers: json["availableForNonSubscribers"],
        whichDay: json["whichDay"] == null
            ? []
            : List<String>.from(json["whichDay"]!.map((x) => x)),
        addMoreRanges: json["addMoreRanges"] == null
            ? []
            : List<AddMoreRange>.from(
            json["addMoreRanges"]!.map((x) => AddMoreRange.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "availableForNonSubscribers": availableForNonSubscribers,
    "whichDay":
    whichDay == null ? [] : List<dynamic>.from(whichDay!.map((x) => x)),
    "addMoreRanges": addMoreRanges == null
        ? []
        : List<dynamic>.from(addMoreRanges!.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 8)
class AddMoreRange extends HiveObject {
  @HiveField(0)
  String? endTime;

  @HiveField(1)
  String? startTime;

  AddMoreRange({
    this.endTime,
    this.startTime,
  });

  factory AddMoreRange.fromJson(Map<String, dynamic> json) => AddMoreRange(
    endTime: json["endTime"],
    startTime: json["startTime"],
  );

  Map<String, dynamic> toJson() => {
    "endTime": endTime,
    "startTime": startTime,
  };
}

@HiveType(typeId: 9)
class LiveClassesLink extends HiveObject {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? url;

  LiveClassesLink({
    this.title,
    this.url,
  });

  factory LiveClassesLink.fromJson(Map<String, dynamic> json) => LiveClassesLink(
    title: json["title"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "url": url,
  };
}
