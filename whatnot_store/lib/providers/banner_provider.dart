import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../services/banner_service.dart';

class BannerProvider extends ChangeNotifier {
  final BannerService _bannerService = BannerService();

  List<BannerModel> _banners = [];
  bool isLoading = false;
  String? errorMessage;

  List<BannerModel> get banners => _banners;

  // 📥 Load Banners
  Future<void> loadBanners() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _banners = await _bannerService.fetchBanners();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
