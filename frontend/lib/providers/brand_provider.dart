import 'package:flutter/material.dart';
import '../models/brand_model.dart';
import '../services/brand_service.dart';

class BrandProvider extends ChangeNotifier {
  final BrandService _brandService = BrandService();

  List<Brand> _brands = [];
  bool isLoading = false;
  String? errorMessage;

  List<Brand> get brands => _brands;

  // 📥 Fetch Brands
  Future<void> loadBrands() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _brands = await _brandService.fetchBrands();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadBrandsByCategory(String categoryId) async {
  isLoading = true;
  errorMessage = null;
  _brands = []; // ✅ Clear old brands
  notifyListeners();

  try {
    _brands = await _brandService.fetchBrandsByCategory(categoryId);
  } catch (e) {
    errorMessage = e.toString();
  }

  isLoading = false;
  notifyListeners();
}


}
