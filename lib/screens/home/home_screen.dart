import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../config/app_constants.dart';
import '../../widgets/news_card.dart';
import '../detail/detail_screen.dart';
import '../library/library_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NewsProvider>().fetchNews());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: IndexedStack(
        index: _navIndex,
        children: const [_NewsTab(), LibraryScreen(), _ProfileTab()],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1220),
        border: Border(top: BorderSide(color: Color(0xFF1E2640), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        backgroundColor: Colors.transparent, elevation: 0,
        selectedItemColor: const Color(0xFFFF6B6B), unselectedItemColor: const Color(0xFF4A5568),
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmarks_outlined), activeIcon: Icon(Icons.bookmarks_rounded), label: 'Kliping'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}

class _NewsTab extends StatefulWidget {
  const _NewsTab();
  @override
  State<_NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<_NewsTab> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          if (_showSearch) _buildSearchBar(),
          _buildCategories(),
          Expanded(child: _buildNewsList()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.newspaper_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('NewsClip', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _showSearch = !_showSearch),
            icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextField(
        controller: _searchCtrl, autofocus: true,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari berita...',
          hintStyle: GoogleFonts.outfit(color: const Color(0xFF8892A4)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8892A4), size: 20),
          filled: true, fillColor: const Color(0xFF141824),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (q) => context.read<NewsProvider>().searchNews(q),
        onChanged: (q) { if (q.isEmpty) context.read<NewsProvider>().clearSearch(); },
      ),
    );
  }

  Widget _buildCategories() {
    return Consumer<NewsProvider>(
      builder: (_, news, __) => SizedBox(
        height: 44,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: AppConstants.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = AppConstants.categories[i];
            final isSelected = news.selectedCategory == cat['value'];
            return GestureDetector(
              onTap: () => context.read<NewsProvider>().setCategory(cat['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF6B6B) : const Color(0xFF141824),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: isSelected ? const Color(0xFFFF6B6B) : const Color(0xFF1E2640), width: 1),
                ),
                child: Text('${cat['emoji']} ${cat['label']}',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF8892A4))),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return Consumer2<NewsProvider, BookmarkProvider>(
      builder: (_, news, bm, __) {
        if (news.isLoading || news.isSearching) return _shimmerList();
        if (news.error != null) return _errorState(news.error!, () => news.fetchNews());
        if (news.articles.isEmpty) return _emptyState();
        return RefreshIndicator(
          color: const Color(0xFFFF6B6B), backgroundColor: const Color(0xFF141824),
          onRefresh: () => news.fetchNews(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), itemCount: news.articles.length,
            itemBuilder: (_, i) {
              final article = news.articles[i];
              return NewsCard(
                article: article,
                isBookmarked: bm.isBookmarked(article.url),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(article: article))),
                onBookmark: () async {
                  if (bm.isBookmarked(article.url)) return;
                  final ok = await bm.saveBookmark(article);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? '\u2705 Artikel dikliping!' : '\u274C Gagal menyimpan', style: GoogleFonts.outfit()),
                    backgroundColor: ok ? const Color(0xFF06D6A0) : const Color(0xFFFF6B6B),
                    duration: const Duration(seconds: 2),
                  ));
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _shimmerList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), itemCount: 5,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: const Color(0xFF141824), highlightColor: const Color(0xFF1E2640),
      child: Container(height: 260, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(16))),
    ),
  );

  Widget _errorState(String msg, VoidCallback retry) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.wifi_off_rounded, color: Color(0xFF8892A4), size: 52), const SizedBox(height: 16),
      Text(msg, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: const Color(0xFF8892A4), fontSize: 14)), const SizedBox(height: 20),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: retry, icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text('Coba Lagi', style: GoogleFonts.outfit()),
      ),
    ]),
  );

  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.article_outlined, color: Color(0xFF4A5568), size: 52), const SizedBox(height: 12),
    Text('Tidak ada berita', style: GoogleFonts.outfit(color: const Color(0xFF8892A4), fontSize: 15)),
  ]));
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Profil', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1E2640), width: 0.5)),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFF6C63FF)]), borderRadius: BorderRadius.circular(18)),
                        child: Center(child: Text(
                          (user?.username.isNotEmpty == true) ? user!.username[0].toUpperCase() : 'U',
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user?.username ?? '-', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '-', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF8892A4))),
                      ])),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFF6B6B), width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), foregroundColor: const Color(0xFFFF6B6B)),
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text('Keluar', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
