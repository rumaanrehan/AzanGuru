class AGCategory {
  String? id;
  String? name;
  int? count;

  AGCategory({
    this.id,
    this.name,
    this.count,
  });

  factory AGCategory.fromJson(Map<String, dynamic> json) => AGCategory(
        id: json["id"],
        name: json["name"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "count": count,
      };
}
