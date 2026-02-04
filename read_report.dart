import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('analysis_report.txt');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }

  try {
    // Try reading as UTF-8 first
    print(file.readAsStringSync().substring(0, 2000));
  } catch (e) {
    try {
      // Try reading bytes and decoding as UTF-16LE (if possible via some logic, but Dart convert doesn't have standard UTF-16 decoder in core without dart:convert having it, wait, standard dart:convert doesn't have UTF-16)
      // We'll just read bytes and strip 0x00 pattern if it looks like ASCII with null bytes.
      final bytes = file.readAsBytesSync();
      final buffer = StringBuffer();
      for (int i = 0; i < bytes.length; i++) {
        if (bytes[i] != 0) {
          buffer.writeCharCode(bytes[i]);
        }
      }
      print(buffer.toString().substring(0, 2000));
    } catch (e2) {
      print('Could not read file: $e2');
    }
  }
}
