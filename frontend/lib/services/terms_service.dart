import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/terms_model.dart';
import '../utils/constants.dart';

class TermsService {
  
  static String get termsUrl => "${ApiConstants.baseUrl}/terms";


  // Fetch latest Terms from backend
  static Future<TermsModel?> fetchTerms() async {
    try {
      final res = await http.get(Uri.parse(termsUrl));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return TermsModel.fromJson(data);
      } else {
        print("Failed to load terms: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching terms: $e");
      return null;
    }
  }
}
