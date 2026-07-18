import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/bookmark_provider.dart';
import '../../models/bookmark_model.dart';
import '../../widgets/bookmark_card.dart';
import '../workspace/workspace_screen.dart';

class AllBookmarksScreen extends StatefulWidget {
  const AllBookmarksScreen({super.key});
  @override
  State<AllBookmarksScreen> createState() => _AllBookmarksScreenState();
}

class _AllBookmarksScreenState extends State<AllBookmarksScreen> {
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BookmarkProvider>().fetchAllBookmarks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Semua Kliping', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Column(children: [_buildFilterChips(), Expanded(child: _buildBody())]),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Belum Dibaca', 'Selesai'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: filters.map((f) {
          final selected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFF6B6B) : const Color(0xFF141824),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? const Color(0xFFFF6B6B) : const Color(0xFF1E2640)),
                ),
                child: Text(f, style: GoogleFonts.outfit(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: selected ? Colors.white : const Color(0xFF8892A4))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<BookmarkProvider>(
      builder: (_, bm, __) {
        if (bm.isLoading) return _shimmer();
        if (bm.error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFF8892A4), size: 48), const SizedBox(height: 12),
          Text(bm.error!, style: GoogleFonts.outfit(color: const Color(0xFF8892A4))), const SizedBox(height: 16),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white), onPressed: bm.fetchAllBookmarks, child: Text('Coba Lagi', style: GoogleFonts.outfit())),
        ]));
        final filtered = _applyFilter(bm.bookmarks);
        if (filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.bookmarks_outlined, color: Color(0xFF4A5568), size: 60)),
          const SizedBox(height: 20),
          Text('Belum ada kliping', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Simpan artikel dari beranda\nuntuk mulai membuat kliping', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF8892A4))),
        ]));
        return RefreshIndicator(
          color: const Color(0xFFFF6B6B), backgroundColor: const Color(0xFF141824),
          onRefresh: () => bm.fetchAllBookmarks(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final bookmark = filtered[i];
              return BookmarkCard(
                bookmark: bookmark,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkspaceScreen(bookmark: bookmark))).then((_) => bm.fetchAllBookmarks()),
                onDelete: () async {
                  final ok = await bm.deleteBookmark(bookmark.bookmarkId);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Kliping dihapus' : 'Gagal menghapus', style: GoogleFonts.outfit()),
                    backgroundColor: const Color(0xFFFF6B6B), duration: const Duration(seconds: 2),
                  ));
                },
              );
            },
          ),
        );
      },
    );
  }

  List<BookmarkModel> _applyFilter(List<BookmarkModel> all) {
    if (_filter == 'Belum Dibaca') return all.where((b) => b.readingStatus == 'Belum Dibaca').toList();
    if (_filter == 'Selesai') return all.where((b) => b.readingStatus == 'Selesai').toList();
    return all;
  }

  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF141824), highlightColor: const Color(0xFF1E2640),
        child: Container(height: 90, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(14))),
      ),
    );
  }
}
