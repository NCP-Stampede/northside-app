// lib/controllers/home_carousel_controller.dart

import 'package:get/get.dart';
import '../api.dart';
import '../models/home_carousel_item.dart';
import '../models/article.dart';
import '../core/utils/logger.dart';

class HomeCarouselController extends GetxController {
  // Observable list of home carousel items
  final RxList<HomeCarouselItem> _carouselItems = <HomeCarouselItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  List<HomeCarouselItem> get carouselItems => _carouselItems;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadHomeCarouselData();
  }

  // Load home carousel data from API
  Future<void> loadHomeCarouselData() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      AppLogger.info('Loading home carousel data from API');
      
      final items = await ApiService.getHomeCarousel();
      _carouselItems.value = items;
      
      AppLogger.info('Successfully loaded ${items.length} home carousel items');
    } catch (e) {
      _error.value = e.toString();
      AppLogger.error('Failed to load home carousel data', e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadHomeCarouselData();
  }

  // Get carousel items as Articles for compatibility with existing UI
  List<Article> getCarouselAsArticles() {
    return _carouselItems.map((item) => item.toArticle()).toList();
  }

  // Get a specific carousel item by index
  HomeCarouselItem? getItemAt(int index) {
    if (index >= 0 && index < _carouselItems.length) {
      return _carouselItems[index];
    }
    return null;
  }

  // Check if carousel has items
  bool get hasItems => _carouselItems.isNotEmpty;

  // Get items count
  int get itemsCount => _carouselItems.length;
}
