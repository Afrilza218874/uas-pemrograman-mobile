import 'package:dio/dio.dart';
import '../config/app_constants.dart';
import '../models/article_model.dart';

class NewsService {
  late final Dio _dio;

  NewsService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.backendBaseUrl, // Gunakan Vercel backend sebagai proxy
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  /// Ambil berita terpopuler berdasarkan kategori
  Future<List<ArticleModel>> fetchTopHeadlines({
    String category = 'general',
    String language = 'en',
    int pageSize = AppConstants.newsPageSize,
  }) async {
    try {
      final response = await _dio.get('/api/news', queryParameters: {
        'endpoint': 'top-headlines', // Diteruskan ke Vercel proxy
        'category': category,
        'language': language,
        'pageSize': pageSize,
        'apiKey': AppConstants.newsApiKey,
      });

      final articles = (response.data['articles'] as List)
          .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
          .where((a) => a.isValid)
          .toList();

      return articles;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cari berita berdasarkan kata kunci
  Future<List<ArticleModel>> searchNews(
    String query, {
    int pageSize = AppConstants.newsPageSize,
  }) async {
    try {
      final response = await _dio.get('/api/news', queryParameters: {
        'endpoint': 'everything', // Diteruskan ke Vercel proxy
        'q': query,
        'language': 'en',
        'sortBy': 'publishedAt',
        'pageSize': pageSize,
        'apiKey': AppConstants.newsApiKey,
      });

      final articles = (response.data['articles'] as List)
          .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
          .where((a) => a.isValid)
          .toList();

      return articles;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung. Periksa koneksi internet Anda.';
    }
    final msg = e.response?.data?['message'];
    if (msg is String) return msg;
    return 'Gagal memuat berita. Coba lagi.';
  }
}
