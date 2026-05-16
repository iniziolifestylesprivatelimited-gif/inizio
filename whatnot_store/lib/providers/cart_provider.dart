import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';

class CartProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> items = [];

  /// 🛒 Add product to cart
  Future<void> addToCart(BuildContext context, Product product, int quantity, Variant? variant,) async {
    try {
      isLoading = true;
      notifyListeners();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        error = "You must log in to add items to cart.";
        isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/cart/add');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': product.id,
          'quantity': quantity,
          'variantId': variant?.id,  
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        items = List<Map<String, dynamic>>.from(data['items']);
        error = null;
      } else {
        final decoded = jsonDecode(response.body);
        error = decoded['message'] ?? 'Failed to add to cart';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 📦 Fetch user's cart
  Future<void> getCart(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        error = "User not logged in";
        items = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        items = List<Map<String, dynamic>>.from(data['items'] ?? []);
        error = null;
      } else {
        error = jsonDecode(response.body)['message'] ?? 'Failed to load cart';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ❌ Remove item from cart
  Future<void> removeFromCart(
  BuildContext context,
  String productId,
  String? variantId,
) async {
  try {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final token = authProvider.token;

    if (token == null) return;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/cart/remove',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        'productId': productId,
        'variantId': variantId,
      }),
    );

    if (response.statusCode == 200) {

  final data = jsonDecode(response.body);

  items = List<Map<String, dynamic>>.from(
    data['items'] ?? [],
  );

  notifyListeners();
}

  } catch (e) {
    debugPrint('Error removing item: $e');
  }
}

Future<void> updateQuantity(BuildContext context, String productId, int newQty, String? variantId,) async {
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    final url = Uri.parse('${ApiConstants.baseUrl}/cart/update');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
        'variantId': variantId,
        'quantity': newQty,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      items = List<Map<String, dynamic>>.from(data['items']);
      notifyListeners();
    }
  } catch (e) {
    debugPrint('Error updating quantity: $e');
  }
}



  /// 🧹 Clear the entire cart
  Future<void> clearCart(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) return;

      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      await http.delete(url, headers: {
        'Authorization': 'Bearer $token',
      });

      items.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}
