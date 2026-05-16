import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ledger_model.dart';
import '../services/ledger_service.dart';
import 'auth_provider.dart';

class LedgerProvider with ChangeNotifier {
  bool isLoading = false;
  List<LedgerModel> ledgers = [];
  String? error;

  final _service = LedgerService();

  Future<void> fetchLedgers(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      if (token == null) return;

      final response = await _service.fetchMyLedgers(token);

      ledgers = response.map<LedgerModel>((e) => LedgerModel.fromJson(e)).toList();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
