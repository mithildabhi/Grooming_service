import 'dart:io';

class ApiConfig {
  static const String _deviceIp = '192.168.29.87';
  static const String _port = '8000';

  static String get baseUrl {
    final String host;
    if (Platform.isAndroid) {
      host = _isEmulator ? '10.0.2.2' : _deviceIp;
    } else if (Platform.isIOS) {
      host = _isEmulator ? '127.0.0.1' : _deviceIp;
    } else {
      host = _deviceIp;
    }
    return 'http://$host:$_port/api';
  }

  static bool get _isEmulator {
    // On emulators, localhost/127.0.0.1 is the emulator itself,
    // so we use the special addresses. This is a reasonable default;
    // on a real device the _deviceIp is used instead.
    // For more robust detection, consider using device_info_plus.
    return const bool.fromEnvironment('IS_EMULATOR', defaultValue: true);
  }

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
