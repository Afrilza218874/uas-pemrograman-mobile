import 'package:flutter/foundation.dart';
import '../models/folder_model.dart';
import '../services/api_service.dart';

class FolderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<FolderModel> _folders = [];
  bool _isLoading = false;
  String? _error;

  List<FolderModel> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateToken(String? token) {
    _api.updateToken(token);
    if (token != null) { fetchFolders(); } else { _folders = []; notifyListeners(); }
  }

  Future<void> fetchFolders() async {
    _isLoading = true; _error = null; notifyListeners();
    try { _folders = await _api.getFolders(); } catch (e) { _error = e.toString(); }
    _isLoading = false; notifyListeners();
  }

  Future<bool> createFolder(String name) async {
    try {
      final folder = await _api.createFolder(name);
      _folders.insert(0, folder); notifyListeners(); return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> updateFolder(int folderId, String newName) async {
    try {
      final updated = await _api.updateFolder(folderId, newName);
      final idx = _folders.indexWhere((f) => f.folderId == folderId);
      if (idx != -1) { _folders[idx] = _folders[idx].copyWith(folderName: updated.folderName); notifyListeners(); }
      return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> deleteFolder(int folderId) async {
    try {
      await _api.deleteFolder(folderId);
      _folders.removeWhere((f) => f.folderId == folderId); notifyListeners(); return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  void clearError() { _error = null; notifyListeners(); }
}
