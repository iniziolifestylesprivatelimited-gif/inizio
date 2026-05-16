import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/brand_model.dart';
import '../utils/constants.dart';

class BrandService {
  final String baseUrl = '${ApiConstants.baseUrl}/brands';

  // 📥 Get All Brands
  Future<List<Brand>> fetchBrands() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Brand.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching brands: $e');
    }
  }

  Future<List<Brand>> fetchBrandsByCategory(String categoryId) async {
  final url = '${ApiConstants.baseUrl}/brands/category/$categoryId';
  final res = await http.get(Uri.parse(url));

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.map((e) => Brand.fromJson(e)).toList();
  }
  return [];
}

}
