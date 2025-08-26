class MDLQuestionAnswer {
  List<QuestionNodes>? nodes;

  MDLQuestionAnswer({this.nodes});

  MDLQuestionAnswer.fromJson(Map<String, dynamic> json) {
    if (json['nodes'] != null) {
      nodes = <QuestionNodes>[];
      json['nodes'].forEach((v) {
        nodes!.add(QuestionNodes.fromJson(v));
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

class QuestionNodes {
  String? id;
  String? title;
  String? date;
  String? content;

  QuestionNodes({this.id, this.title, this.date,this.content});

  QuestionNodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    date = json['date'];
    content = json['content']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['date'] = date;
    data['content'] = content;
    return data;
  }
}