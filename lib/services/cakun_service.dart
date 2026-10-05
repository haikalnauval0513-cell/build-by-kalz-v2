import 'dart:convert';
import 'package:http/http.dart' as http;

class CakunService {
  static const String baseUrl = 'http://reviactyserver.szxennofficialid.web.id:3054';
  static const int defaultDuration = 50000;

  static Future<CakunResult> createAkun({
    required String username,
    required String telegramId,
    String? password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/cakun'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'telegramId': telegramId,
              'password': (password != null && password.trim().isNotEmpty)
                  ? password.trim()
                  : null,
            }),
          )
          .timeout(const Duration(seconds: 25));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return CakunResult.success(
          AkunData.fromJson(data['data'] as Map<String, dynamic>),
        );
      } else {
        return CakunResult.error(data['message']?.toString() ?? 'Gagal create akun');
      }
    } catch (e) {
      return CakunResult.error('Koneksi error: $e');
    }
  }
}

class CakunResult {
  final bool success;
  final String? message;
  final AkunData? data;
  CakunResult._({required this.success, this.message, this.data});
  factory CakunResult.success(AkunData data) => CakunResult._(success: true, data: data);
  factory CakunResult.error(String message) => CakunResult._(success: false, message: message);
}

class AkunData {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String pairId;
  final int durationDays;
  final String telegramId;

  AkunData({
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.pairId,
    required this.durationDays,
    required this.telegramId,
  });

  factory AkunData.fromJson(Map<String, dynamic> json) => AkunData(
        username: json['username'] ?? '',
        password: json['password'] ?? '',
        role: json['role'] ?? 'member',
        expiredDate: json['expiredDate'] ?? '',
        pairId: json['pairId'] ?? '',
        durationDays: json['durationDays'] ?? CakunService.defaultDuration,
        telegramId: json['telegramId'] ?? '',
      );
}