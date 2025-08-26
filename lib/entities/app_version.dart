class AppVersion {
  final String android;
  final String ios;

  AppVersion({required this.android, required this.ios});

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      android: json['android'],
      ios: json['ios'],
    );
  }
}
