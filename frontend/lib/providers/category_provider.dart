import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  bool isLoading = false;
  String? errorMessage;

  String? selectedCategoryId; // ✅ Add this

  List<Category> get categories => _categories;

  // ✅ Select category
  void selectCategory(String id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  // 📥 Load Categories
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
}
