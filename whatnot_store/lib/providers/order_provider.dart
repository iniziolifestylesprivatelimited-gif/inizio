import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import 'auth_provider.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> orders = [];

  Map<String, dynamic>? razorpayOrder; // store razorpay order info

  /// 🧾 Place order (Razorpay)
  Future<Map<String, dynamic>?> placeOrder(
    BuildContext context,
    List<Map<String, dynamic>> items,
    double total,
    String addressId,
    String paymentMethod,
) async {
  try {
    isLoading = true;
    notifyListeners();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return null;

    final url = Uri.parse('${ApiConstants.baseUrl}/orders');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items,
        'totalAmount': total,
        'paymentMethod': paymentMethod, // ✅ IMPORTANT
        'addressId': addressId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data; // contains paymentUrl or order
    } else {
      error = data['message'] ?? 'Order failed';
      return null;
    }
  } catch (e) {
    error = e.toString();
    return null;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  /// 📦 Fetch all user orders
  Future<void> fetchOrders(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) return;

      final url = Uri.parse('${ApiConstants.baseUrl}/orders/my');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        orders = List<Map<String, dynamic>>.from(data);
        error = null;
      } else {
        error = jsonDecode(response.body)['message'];
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
