import 'package:dio/dio.dart';
import '../config/app_constants.dart';
import '../models/user_model.dart';
import '../models/folder_model.dart';
import '../models/bookmark_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.backendBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  void updateToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<UserModel> register(String username, String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/register', data: {
        'username': username, 'email': email, 'password': password,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data, token: data['token'] as String);
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/login', data: {
        'email': email, 'password': password,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data, token: data['token'] as String);
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<UserModel> getMe(String token) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final res = await _dio.get('/api/auth/me');
      final data = res.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data, token: token);
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<List<FolderModel>> getFolders() async {
    try {
      final res = await _dio.get('/api/folders');
      final list = res.data['data'] as List;
      return list.map((j) => FolderModel.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<FolderModel> createFolder(String folderName) async {
    try {
      final res = await _dio.post('/api/folders', data: {'folder_name': folderName});
      return FolderModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<FolderModel> updateFolder(int folderId, String folderName) async {
    try {
      final res = await _dio.put('/api/folders/$folderId', data: {'folder_name': folderName});
      return FolderModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<void> deleteFolder(int folderId) async {
    try {
      await _dio.delete('/api/folders/$folderId');
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<List<BookmarkModel>> getBookmarks({int? folderId}) async {
    try {
      final params = folderId != null ? {'folder_id': folderId} : null;
      final res = await _dio.get('/api/bookmarks', queryParameters: params);
      final list = res.data['data'] as List;
      return list.map((j) => BookmarkModel.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<BookmarkModel> createBookmark({
    required String title,
    required String articleUrl,
    String? author, String? sourceName, String? imageUrl,
    String? publishedDate, String? description, String? myNotes,
    int? folderId, String readingStatus = 'Belum Dibaca',
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title, 'article_url': articleUrl, 'reading_status': readingStatus,
      };
      if (author != null) body['author'] = author;
      if (sourceName != null) body['source_name'] = sourceName;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (publishedDate != null) body['published_date'] = publishedDate;
      if (description != null) body['description'] = description;
      if (myNotes != null) body['my_notes'] = myNotes;
      if (folderId != null) body['folder_id'] = folderId;
      final res = await _dio.post('/api/bookmarks', data: body);
      return BookmarkModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<BookmarkModel> updateBookmark(int bookmarkId, {
    String? myNotes, int? folderId, String? readingStatus, bool clearFolder = false,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (myNotes != null) body['my_notes'] = myNotes;
      if (clearFolder) { body['folder_id'] = null; } else if (folderId != null) { body['folder_id'] = folderId; }
      if (readingStatus != null) body['reading_status'] = readingStatus;
      final res = await _dio.put('/api/bookmarks/$bookmarkId', data: body);
      return BookmarkModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { throw _handleError(e); }
  }

  Future<void> deleteBookmark(int bookmarkId) async {
    try {
      await _dio.delete('/api/bookmarks/$bookmarkId');
    } on DioException catch (e) { throw _handleError(e); }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) return data['message'] as String;
      switch (e.response!.statusCode) {
        case 401: return 'Sesi habis. Silakan login kembali.';
        case 404: return 'Data tidak ditemukan.';
        case 409: return 'Data sudah ada.';
        case 500: return 'Terjadi kesalahan pada server.';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
