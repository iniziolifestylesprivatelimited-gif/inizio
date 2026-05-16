import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/faq_model.dart';
import '../utils/constants.dart';

class FaqService {
  static String get faqUrl => "${ApiConstants.baseUrl}/faqs";

  static Future<List<FaqModel>> fetchFaqs() async {
    try {
      final res = await http.get(Uri.parse(faqUrl));

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((e) => FaqModel.fromJson(e)).toList();
      } else {
        print("Failed to load FAQs: ${res.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching FAQs: $e");
      return [];
    }
  }
}
