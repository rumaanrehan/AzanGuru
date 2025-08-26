class AgNotificationsList {
  List<NotificationNodes>? nodes;

  AgNotificationsList({this.nodes});

  AgNotificationsList.fromJson(Map<String, dynamic> json) {
    if (json['nodes'] != null) {
      nodes = <NotificationNodes>[];
      json['nodes'].forEach((v) {
        nodes!.add(NotificationNodes.fromJson(v));
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

class NotificationNodes {
  String? id;
  String? title;
  String? date;
  Notifications? notifications;

  NotificationNodes({
    this.id,
    this.title,
    this.date,
    this.notifications,
  });

  NotificationNodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    date = json['date'];
    notifications = json['notifications'] != null
        ? Notifications.fromJson(json['notifications'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['date'] = date;
    if (notifications != null) {
      data['notifications'] = notifications!.toJson();
    }
    return data;
  }
}

class Notifications {
  List<String>? notificationType;

  Notifications({
    this.notificationType,
  });

  Notifications.fromJson(Map<String, dynamic> json) {
    // Check if 'notificationType' is null before casting
    notificationType = json['notificationType'] != null
        ? List<String>.from(json['notificationType'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notificationType != null) {
      data['notificationType'] = notificationType;
    }
    return data;
  }
}

