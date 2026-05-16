import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/privacy_model.dart';
import '../utils/constants.dart';

class PrivacyService {
  static String get privacyUrl => "${ApiConstants.baseUrl}/privacy";
  static Future<PrivacyModel?> fetchPrivacy() async {
    try {
      final res = await http.get(Uri.parse(privacyUrl));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return PrivacyModel.fromJson(data);
      } else {
        print("Failed to load privacy: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching privacy: $e");
      return null;
    }
  }
}
