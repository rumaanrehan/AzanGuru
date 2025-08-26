import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AlertDialog(
          title: const Text("Update Required"),
          content: const Text("Please update the app to continue."),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse('https://play.google.com/store/apps/details?id=com.azanguru');
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                }
              },
              child: const Text("Update Now"),
            )
          ],
        ),
      ),
    );
  }
}
