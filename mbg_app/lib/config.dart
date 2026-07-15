import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5001';
    } else if (Platform.isAndroid) {
      // Genymotion menggunakan 10.0.3.2 untuk mengakses localhost PC
      return 'http://10.0.3.2:5001';
    } else {
      return 'http://127.0.0.1:5001';
    }
  }
}
