// NewsClip — App Constants
// PENTING: Ganti backendBaseUrl dengan URL Vercel Anda!

class AppConstants {
  // ====== NEWS API ======
  static const String newsApiKey = '5463d07d858d421dbc963d74e52dfe9c';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';

  // ====== BACKEND API ======
  // URL Vercel yang aktif (hasil deploy dengan suffix -beryl)
  static const String backendBaseUrl =
      'https://uas-pemrograman-mobile-beryl.vercel.app';

  // ====== LOCAL STORAGE KEYS ======
  static const String tokenKey = 'newsclip_auth_token';

  // ====== NEWS CONFIG ======
  static const int newsPageSize = 20;

  // ====== CATEGORIES ======
  static const List<Map<String, String>> categories = [
    {'label': 'Semua', 'value': 'general', 'emoji': '\u{1F30D}'},
    {'label': 'Bisnis', 'value': 'business', 'emoji': '\u{1F4BC}'},
    {'label': 'Teknologi', 'value': 'technology', 'emoji': '\u{1F4BB}'},
    {'label': 'Kesehatan', 'value': 'health', 'emoji': '\u{1F3E5}'},
    {'label': 'Olahraga', 'value': 'sports', 'emoji': '\u26BD'},
    {'label': 'Sains', 'value': 'science', 'emoji': '\u{1F52C}'},
    {'label': 'Hiburan', 'value': 'entertainment', 'emoji': '\u{1F3AC}'},
  ];
}
