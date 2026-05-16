import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductService {
  final String baseUrl = '${ApiConstants.baseUrl}/products';

  // 🧾 Fetch All Products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // 🏷️ Fetch Products by Category ID
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
  try {
    final url = '$baseUrl/category/$categoryId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // ✅ If no products, return empty list gracefully
      if (data.isEmpty) return [];
      
      return data.map((e) => Product.fromJson(e)).toList();
    } 
    
    // ✅ Handle "no products found" gracefully (avoid error)
    if (response.statusCode == 404) {
      return [];
    }

    throw Exception('Failed to load products by category');
  } catch (e) {
    throw Exception('Error fetching products by category: $e');
  }
}

Future<List<Product>> fetchProductsByBrandAndCategory(String category, String brand) async {
  final url = '$baseUrl?category=$category&brand=$brand';
  final res = await http.get(Uri.parse(url));

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }
  return [];
}



  // 🏢 Fetch Products by Brand ID
  Future<List<Product>> fetchProductsByBrand(String brandId) async {
    try {
      final url = '$baseUrl/brand/$brandId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load products by brand');
      }
    } catch (e) {
      throw Exception('Error fetching products by brand: $e');
    }
  }

  // 🔍 Fetch Single Product by ID
  Future<Product> fetchProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
}
