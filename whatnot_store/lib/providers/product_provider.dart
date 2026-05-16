import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _allProducts = []; // 🔹 Store full product list for search
    List<Product> _filteredProducts = [];

bool _isFilterActive = false;
  bool isLoading = false;
  String? errorMessage;

    List<Product> get products =>
      _filteredProducts.isEmpty ? _products : _filteredProducts;
  

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

  void clearProducts() {
  _products = [];
  notifyListeners();
}

// 🔄 CLEAR FILTERS
  void clearFilters() {
    _filteredProducts = [];
    _isFilterActive = false;
    notifyListeners();
  }

void resetToAllProducts() {
  _products = _allProducts;
  notifyListeners();
}


void applySortAndFilter({
  required String sort,
  required double minPrice,
  required double maxPrice,
}) {
  List<Product> temp = List.from(_products);

  // PRICE FILTER
  temp = temp.where((product) {
    final price = product.displayPrice ?? product.basePrice;
    return price >= minPrice && price <= maxPrice;
  }).toList();

  // SORT
  if (sort == "low-high") {
    temp.sort((a, b) =>
        (a.displayPrice ?? a.basePrice)
            .compareTo(b.displayPrice ?? b.basePrice));
  } else if (sort == "high-low") {
    temp.sort((a, b) =>
        (b.displayPrice ?? b.basePrice)
            .compareTo(a.displayPrice ?? a.basePrice));
  }

  _filteredProducts = temp;
  _isFilterActive = true;
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

  // 📦 LOAD BY BRAND + CATEGORY
  Future<void> loadProductsByBrandAndCategory({
    required String categoryId,
    required String brandId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.fetchProductsByBrandAndCategory(
        categoryId,
        brandId,
      );

      // 🔥 RESET FILTERS ON CATEGORY CHANGE
      clearFilters();
    } catch (e) {
      _products = [];
      errorMessage = e.toString();
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
