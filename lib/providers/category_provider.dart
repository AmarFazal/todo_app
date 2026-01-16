import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../database/database_helper.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _categories = await _db.getAllCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _db.createCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _db.updateCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _db.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

