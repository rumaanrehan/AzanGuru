import 'package:azan_guru_mobile/ui/model/media_node.dart';

class Role {
  final String id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Roles {
  final List<Role> nodes;

  Roles({
    required this.nodes,
  });

  factory Roles.fromJson(Map<String, dynamic> json) {
    var nodesJson = json['nodes'] as List;
    List<Role> nodesList = nodesJson.map((i) => Role.fromJson(i)).toList();

    return Roles(
      nodes: nodesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes.map((role) => role.toJson()).toList(),
    };
  }
}

// Updated User class to include Roles
class User {
  Avatar? avatar;
  String? email;
  String? gender;
  int? databaseId;
  String? description;
  String? firstName;
  String? id;
  String? lastName;
  String? name;
  String? nicename;
  String? nickname;
  String? username;
  String? locale;
  String? phone;
  StudentsOptions? studentsOptions;
  GeneralUserOptions? generalUserOptions;
  Roles? roles;

  User({
    this.avatar,
    this.email,
    this.gender,
    this.databaseId,
    this.description,
    this.firstName,
    this.id,
    this.lastName,
    this.name,
    this.nicename,
    this.nickname,
    this.username,
    this.locale,
    this.phone,
    this.studentsOptions,
    this.generalUserOptions,
    this.roles, // Add this line
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
        email: json["email"],
        gender: json["gender"],
        databaseId: json["databaseId"],
        description: json["description"],
        firstName: json["firstName"],
        id: json["id"],
        lastName: json["lastName"],
        name: json["name"],
        nicename: json["nicename"],
        nickname: json["nickname"],
        username: json["username"],
        locale: json["locale"],
        phone: json["phone"],
        studentsOptions: json["studentsOptions"] == null
            ? null
            : StudentsOptions.fromJson(json["studentsOptions"]),
        generalUserOptions: json["generalUserOptions"] == null
            ? null
            : GeneralUserOptions.fromJson(json["generalUserOptions"]),
        roles: json["roles"] == null
            ? null
            : Roles.fromJson(json["roles"]), // Add this line
      );

  Map<String, dynamic> toJson() => {
        "avatar": avatar?.toJson(),
        "email": email,
        "gender": gender,
        "databaseId": databaseId,
        "description": description,
        "firstName": firstName,
        "id": id,
        "lastName": lastName,
        "name": name,
        "nicename": nicename,
        "nickname": nickname,
        "username": username,
        "locale": locale,
        "phone": phone,
        "studentsOptions": studentsOptions?.toJson(),
        "generalUserOptions": generalUserOptions?.toJson(),
        "roles": roles?.toJson(), // Add this line
      };
}

class GeneralUserOptions {
  int? phoneNumber;
  String? agUserAuthKey;

  GeneralUserOptions({
    this.phoneNumber,
    this.agUserAuthKey,
  });

  factory GeneralUserOptions.fromJson(Map<String, dynamic> json) =>
      GeneralUserOptions(
        phoneNumber: json["phoneNumber"],
        agUserAuthKey: json["agUserAuthKey"],
      );

  Map<String, dynamic> toJson() => {
        "phoneNumber": phoneNumber,
        "agUserAuthKey": agUserAuthKey,
      };
}

class StudentsOptions {
  StudentPicture? studentPicture;
  List<String>? studentInappProductId;

  StudentsOptions({
    this.studentPicture,
    this.studentInappProductId,
  });

  factory StudentsOptions.fromJson(Map<String, dynamic> json) =>
      StudentsOptions(
          studentPicture: json["studentPicture"] == null
              ? null
              : StudentPicture.fromJson(
                  json["studentPicture"],
                ),
          studentInappProductId: json['studentInappProductId'] != null
              ? List<String>.from(json['studentInappProductId'])
              : null);
  Map<String, dynamic> toJson() => {
        "studentPicture": studentPicture?.toJson(),
        "studentInappProductId": studentInappProductId ?? null,
      };
}

class PurchaseInfo {
  final String userId;
  final String courseId;
  final String orderId;
  final String productId;
  final String isSubRenewing;

  PurchaseInfo({
    required this.userId,
    required this.courseId,
    required this.orderId,
    required this.productId,
    required this.isSubRenewing,
  });

  factory PurchaseInfo.fromJson(Map<String, dynamic> json) {
    return PurchaseInfo(
      userId: json['user_id'],
      courseId: json['course_id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      isSubRenewing:
          json['is_sub_renewing'] ?? '', // Default to empty string if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'course_id': courseId,
      'order_id': orderId,
      'product_id': productId,
      'is_sub_renewing': isSubRenewing,
    };
  }
}

class StudentPicture {
  MediaNode? node;

  StudentPicture({
    this.node,
  });

  factory StudentPicture.fromJson(Map<String, dynamic> json) => StudentPicture(
        node: json["node"] == null ? null : MediaNode.fromJson(json["node"]),
      );

  Map<String, dynamic> toJson() => {
        "node": node?.toJson(),
      };
}

class Avatar {
  String? url;

  Avatar({
    this.url,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}
