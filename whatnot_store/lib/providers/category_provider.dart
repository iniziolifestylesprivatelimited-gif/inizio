import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  bool isLoading = false;
  String? errorMessage;

  String? selectedCategoryId;

  List<Category> get categories => _categories;

  void selectCategory(String id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryService.fetchCategories();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

Future<void> loadCategoriesByBrand(String brandId) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    _categories = await _categoryService.fetchCategoriesByBrand(brandId);
  } catch (e) {
    errorMessage = e.toString();
    _categories = [];
  }

  isLoading = false;
  notifyListeners();
}


  // ⭐ ADD THIS
  String? getCategoryIdByName(String name) {
    try {
      final category = _categories.firstWhere(
        (c) => c.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
      return category.id;
    } catch (e) {
      return null;
    }
  }
}
