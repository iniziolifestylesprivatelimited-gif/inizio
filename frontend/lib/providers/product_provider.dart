import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _allProducts = []; // 🔹 Store full product list for search

  bool isLoading = false;
  String? errorMessage;

  List<Product> get products => _products;

  // 📦 Load All Products
  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      _allProducts = await _productService.fetchProducts();  
      _products = _allProducts; // ✅ show all initially
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 📦 Load Products by Category
  Future<void> loadProductsByCategory(String categoryId) async {
    isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.fetchProductsByCategory(categoryId);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadProductsByBrandAndCategory({
    required String categoryId,
    required String brandId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.fetchProductsByBrandAndCategory(
        categoryId,
        brandId,
      );
    } catch (_) {
      _products = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // 🏢 Load Products by Brand
  Future<void> loadProductsByBrand(String brandId) async {
    isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.fetchProductsByBrand(brandId);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 🔍 Local Search
  void searchProducts(String query) {
    if (query.isEmpty) {
      _products = _allProducts; // reset
    } else {
      _products = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
