import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // 🔥 Set this to true when using ngrok
  static const bool useNgrok = true;

  static String get baseUrl {
    if (useNgrok) {
      return "https://cushy-unvitiating-pearly.ngrok-free.dev/api";
    }

    // Default local setup
    if (kIsWeb) {
      return "http://localhost:5000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api";
    } else {
      return "http://localhost:5000/api";
    }
  }
}
