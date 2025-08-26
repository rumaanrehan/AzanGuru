// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MDLLoginParam {
  String? userName;
  String? password;

  MDLLoginParam({
    this.userName,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': userName?.trim(),
      'password': password?.trim(),
    };
  }

  factory MDLLoginParam.fromMap(Map<String, dynamic> map) {
    return MDLLoginParam(
      userName: map['userName'] != null ? map['userName'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MDLLoginParam.fromJson(String source) => MDLLoginParam.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MDLUserRegisterParam {
  String? firstName;
  // String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  int? studentAge;
  String? studentGander;
  String? username;
  String? phoneNumber;

  // String? country;
  // String? state;
  // String? city;
  // String? pinCode;

  MDLUserRegisterParam({
    this.firstName,
    // this.lastName,
    this.email,
    this.password,
    this.confirmPassword,
    this.studentAge,
    this.studentGander,
    this.username,
    this.phoneNumber,
    // this.country,
    // this.state,
    // this.city,
    // this.pinCode,
  });
}

class RegisterUserInput {
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final String firstName;
  // final String lastName;
  final String studentGander;
  final int? studentAge;

  RegisterUserInput({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.firstName,
    // required this.lastName,
    required this.studentGander,
    required this.studentAge,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'firstName': firstName,
      // 'lastName': lastName,
      'studentGander': studentGander,
      'studentAge': studentAge,
    };
  }

  factory RegisterUserInput.fromMap(Map<String, dynamic> map) {
    return RegisterUserInput(
      username: map['username'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      password: map['password'] as String,
      firstName: map['firstName'] as String,
      // lastName: map['lastName'] as String,
      studentGander: map['studentGander'] as String,
      studentAge: map['studentAge'] != null ? map['studentAge'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterUserInput.fromJson(String source) => RegisterUserInput.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RegisterUserInput(username: $username, email: $email,phoneNumber:$phoneNumber, password: $password, firstName: $firstName, '
        // 'lastName: $lastName,'
        ' studentGander: $studentGander)';
  }

  @override
  bool operator ==(covariant RegisterUserInput other) {
    if (identical(this, other)) return true;

    return other.username == username &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.password == password &&
        other.firstName == firstName &&
        // other.lastName == lastName &&
        other.studentGander == studentGander;
  }

  @override
  int get hashCode {
    return username.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        password.hashCode ^
        firstName.hashCode ^
        // lastName.hashCode ^
        studentGander.hashCode;
  }
}

class MDLChangePasswordParam {
  String? currentPassword;
  String? newPassword;
  String? confirmPassword;

  MDLChangePasswordParam({
    this.currentPassword,
    this.newPassword,
    this.confirmPassword,
  });
}
