class MDLChooseCourse {
  String? question;
  List<MDLOption>? options;

  MDLChooseCourse({
    this.question,
    this.options,
  });
}

class MDLOption {
  String? title;
  String? image;
  bool isSelected;

  MDLOption({
    this.title,
    this.image,
    this.isSelected=false,
  });
}
