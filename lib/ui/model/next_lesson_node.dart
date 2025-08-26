class NextLessonNode {
  String? id;
  int? databaseId;
  String? slug;
  DateTime? date;

  NextLessonNode({
    this.id,
    this.databaseId,
    this.slug,
    this.date,
  });

  factory NextLessonNode.fromJson(Map<String, dynamic> json) => NextLessonNode(
        id: json["id"],
        databaseId: json["databaseId"],
        slug: json["slug"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "databaseId": databaseId,
        "slug": slug,
        "date": date?.toIso8601String(),
      };
}
