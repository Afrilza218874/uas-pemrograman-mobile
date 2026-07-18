import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _service = NewsService();
  List<ArticleModel> _articles = [];
  String _selectedCategory = 'general';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  List<ArticleModel> get articles => _articles;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  Future<void> fetchNews({String? category}) async {
    if (category != null) _selectedCategory = category;
    _searchQuery = '';
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _articles = await _service.fetchTopHeadlines(category: _selectedCategory);
    } catch (e) { _error = e.toString(); }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) return fetchNews();
    _searchQuery = query;
    _isSearching = true;
    _error = null;
    notifyListeners();
    try {
      _articles = await _service.searchNews(query.trim());
    } catch (e) { _error = e.toString(); }
    _isSearching = false;
    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory == category && _searchQuery.isEmpty) return;
    fetchNews(category: category);
  }

  void clearSearch() { if (_searchQuery.isNotEmpty) fetchNews(); }
}
