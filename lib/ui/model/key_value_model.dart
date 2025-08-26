class KeyValueModel {
  String? key;
  String? value;

  KeyValueModel({
    this.key,
    this.value,
  });

  factory KeyValueModel.fromJson(Map<String, dynamic> json) => KeyValueModel(
        key: json["key"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
      };
}
