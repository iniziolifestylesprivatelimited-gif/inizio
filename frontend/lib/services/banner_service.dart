import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banner_model.dart';
import '../utils/constants.dart';

class BannerService {
  final String baseUrl = '${ApiConstants.baseUrl}/banners';

  // 📥 Get All Banners
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => BannerModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Please reload to fetch banners');
    }
  }
}
