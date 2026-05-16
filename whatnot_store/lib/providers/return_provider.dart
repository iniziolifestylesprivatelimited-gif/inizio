import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'auth_provider.dart';
import 'package:provider/provider.dart';

class ReturnProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> returnsList = [];

  /// 📌 Create Return Request
  Future<bool> createReturnRequest(
      BuildContext context, String orderId, List<Map<String, dynamic>> items) async {
    try {
      isLoading = true;
      notifyListeners();

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;

      final url = Uri.parse("${ApiConstants.baseUrl}/returns");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "orderId": orderId,
          "items": items,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        error = null;
        return true;
      } else {
        error = data["message"] ?? "Return request failed";
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 📌 Get User Returns
  Future<void> fetchMyReturns(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;

      final url = Uri.parse("${ApiConstants.baseUrl}/returns/my");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        returnsList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        error = null;
      } else {
        error = "Failed to load returns";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

 Map<String, dynamic>? getReturnForOrder(String orderId) {
  for (var r in returnsList) {
    if (r["order"]["_id"] == orderId) {
      return r;
    }
  }
  return null;
}


}
