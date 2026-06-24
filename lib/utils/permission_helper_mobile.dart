import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkMicrophonePermission() async {
  if (Platform.isIOS) {
    // iOS uses speech_to_text's built-in permissions
    return true;
  }

  // Android uses permission_handler
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
  }
  return status.isGranted;
}
