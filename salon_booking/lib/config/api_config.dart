class ApiConfig {
  // 🔥 CHANGE ONLY THIS IP ADDRESS - It updates everywhere!
  // static const String _baseIp = '10.97.98.16';
  static const String _baseIp = '10.97.98.16';
  static const String _port = '8000';
  
  // Don't change this - it's automatically constructed
  static const String baseUrl = 'http://$_baseIp:$_port/api';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 10);
}