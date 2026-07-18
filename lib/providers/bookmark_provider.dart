import 'package:flutter/foundation.dart';
import '../models/bookmark_model.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  List<BookmarkModel> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateToken(String? token) {
    _api.updateToken(token);
    if (token != null) { fetchAllBookmarks(); } else { _bookmarks = []; notifyListeners(); }
  }

  bool isBookmarked(String articleUrl) => _bookmarks.any((b) => b.articleUrl == articleUrl);

  BookmarkModel? getBookmarkByUrl(String articleUrl) {
    try { return _bookmarks.firstWhere((b) => b.articleUrl == articleUrl); } catch (_) { return null; }
  }

  Future<void> fetchAllBookmarks() async {
    _isLoading = true; _error = null; notifyListeners();
    try { _bookmarks = await _api.getBookmarks(); } catch (e) { _error = e.toString(); }
    _isLoading = false; notifyListeners();
  }

  Future<List<BookmarkModel>> fetchByFolder(int folderId) async {
    try { return await _api.getBookmarks(folderId: folderId); }
    catch (e) { _error = e.toString(); notifyListeners(); return []; }
  }

  Future<bool> saveBookmark(ArticleModel article, {int? folderId}) async {
    try {
      final bookmark = await _api.createBookmark(
        title: article.title, articleUrl: article.url, author: article.author,
        sourceName: article.sourceName, imageUrl: article.urlToImage,
        publishedDate: article.publishedAt, description: article.description,
        folderId: folderId,
      );
      _bookmarks.insert(0, bookmark); notifyListeners(); return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> updateBookmark(int bookmarkId, {
    String? myNotes, int? folderId, String? readingStatus, bool clearFolder = false,
  }) async {
    try {
      final updated = await _api.updateBookmark(
        bookmarkId, myNotes: myNotes, folderId: folderId,
        readingStatus: readingStatus, clearFolder: clearFolder,
      );
      final idx = _bookmarks.indexWhere((b) => b.bookmarkId == bookmarkId);
      if (idx != -1) { _bookmarks[idx] = updated; notifyListeners(); }
      return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> deleteBookmark(int bookmarkId) async {
    try {
      await _api.deleteBookmark(bookmarkId);
      _bookmarks.removeWhere((b) => b.bookmarkId == bookmarkId); notifyListeners(); return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  void clearError() { _error = null; notifyListeners(); }
}
