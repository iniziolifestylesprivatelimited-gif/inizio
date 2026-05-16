import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class LedgerService {
  Future<List<dynamic>> fetchMyLedgers(String token) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/ledger/my");

    final response = await http.get(
      url,
      headers: { 'Authorization': 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
