import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductService {
  final String baseUrl = '${ApiConstants.baseUrl}/products';

  // 🔐 Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 🧾 Fetch All Products (Protected Route)
  Future<List<Product>> fetchProducts() async {
    try {
      final token = await getToken();
      print("TOKEN USED === $token");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("PRODUCT RESPONSE === ${response.statusCode}");
      print("BODY ==== ${response.body}");

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => Product.fromJson(e)).toList();
      }

      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  // 🏷 Fetch Products by Category
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      final token = await getToken();
      final url = '$baseUrl/category/$categoryId';

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => Product.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      throw Exception("Error fetching products by category: $e");
    }
  }

  // 🏢 Fetch Products by Brand
  Future<List<Product>> fetchProductsByBrand(String brandId) async {
    try {
      final token = await getToken();
      final url = '$baseUrl/brand/$brandId';

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => Product.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      throw Exception("Error fetching products by brand: $e");
    }
  }

  // 🏷 Fetch Products by Brand + Category
  Future<List<Product>> fetchProductsByBrandAndCategory(
      String category, String brand) async {
    try {
      final token = await getToken();
      final url = '$baseUrl?category=$category&brand=$brand';

      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Product.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      throw Exception("Error fetching brand/category products: $e");
    }
  }

  // 🔍 Fetch Single Product
  Future<Product> fetchProductById(String id) async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      }

      throw Exception('Product not found');
    } catch (e) {
      throw Exception("Error fetching product: $e");
    }
  }
}
