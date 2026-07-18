import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'providers/folder_provider.dart';
import 'providers/bookmark_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Indonesian locale untuk timeago
  timeago.setLocaleMessages('id', timeago.IdMessages());

  // Status bar transparan
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D1220),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const NewsClipApp());
}

class NewsClipApp extends StatelessWidget {
  const NewsClipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FolderProvider>(
          create: (_) => FolderProvider(),
          update: (_, auth, folder) {
            folder!.updateToken(auth.token);
            return folder;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, BookmarkProvider>(
          create: (_) => BookmarkProvider(),
          update: (_, auth, bookmark) {
            bookmark!.updateToken(auth.token);
            return bookmark;
          },
        ),
      ],
      child: MaterialApp(
        title: 'NewsClip',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF6B6B),
        secondary: Color(0xFF4ECDC4),
        surface: Color(0xFF141824),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0E1A),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A2035),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
