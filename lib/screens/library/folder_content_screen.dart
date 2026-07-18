import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/folder_model.dart';
import '../../models/bookmark_model.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/bookmark_card.dart';
import '../workspace/workspace_screen.dart';

class FolderContentScreen extends StatefulWidget {
  final FolderModel folder;
  const FolderContentScreen({super.key, required this.folder});
  @override
  State<FolderContentScreen> createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen> {
  List<BookmarkModel> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadBookmarks(); }

  Future<void> _loadBookmarks() async {
    setState(() => _loading = true);
    final result = await context.read<BookmarkProvider>().fetchByFolder(widget.folder.folderId);
    if (mounted) setState(() { _bookmarks = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.folder.folderName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('${_bookmarks.length} kliping', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF8892A4))),
          ],
        ),
      ),
      body: _loading ? _buildShimmer() : _buildList(),
    );
  }

  Widget _buildList() {
    if (_bookmarks.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.bookmark_border_rounded, color: Color(0xFF4A5568), size: 52), const SizedBox(height: 14),
      Text('Folder ini masih kosong', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF8892A4))),
      const SizedBox(height: 8),
      Text('Simpan artikel dari beranda\nke folder ini', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF4A5568))),
    ]));
    return RefreshIndicator(
      color: const Color(0xFFFF6B6B), backgroundColor: const Color(0xFF141824),
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), itemCount: _bookmarks.length,
        itemBuilder: (_, i) {
          final bookmark = _bookmarks[i];
          return BookmarkCard(
            bookmark: bookmark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkspaceScreen(bookmark: bookmark))).then((_) => _loadBookmarks()),
            onDelete: () async {
              final ok = await context.read<BookmarkProvider>().deleteBookmark(bookmark.bookmarkId);
              if (!context.mounted) return;
              if (ok) {
                setState(() => _bookmarks.removeWhere((b) => b.bookmarkId == bookmark.bookmarkId));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Kliping dihapus', style: GoogleFonts.outfit()),
                  backgroundColor: const Color(0xFFFF6B6B), duration: const Duration(seconds: 2),
                ));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), itemCount: 6,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: const Color(0xFF141824), highlightColor: const Color(0xFF1E2640),
      child: Container(height: 90, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(14))),
    ),
  );
}
