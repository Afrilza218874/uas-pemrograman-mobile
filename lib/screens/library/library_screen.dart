import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/folder_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/folder_card.dart';
import 'folder_content_screen.dart';
import 'all_bookmarks_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<FolderProvider>().fetchFolders());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildAllKlipingBanner(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildAllKlipingBanner() {
    return Consumer<BookmarkProvider>(
      builder: (_, bm, __) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllBookmarksScreen())).then((_) => bm.fetchAllBookmarks()),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF141824), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E2640), width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bookmarks_rounded, color: Color(0xFFFF6B6B), size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Semua Kliping', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('${bm.bookmarks.length} artikel tersimpan', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF8892A4))),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF4A5568), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text('Kliping Saya', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showCreateFolderDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]), borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 16), const SizedBox(width: 4),
                Text('Folder Baru', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<FolderProvider>(
      builder: (_, fp, __) {
        if (fp.isLoading) return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B6B))));
        if (fp.error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFF8892A4), size: 48), const SizedBox(height: 12),
          Text(fp.error!, style: GoogleFonts.outfit(color: const Color(0xFF8892A4))), const SizedBox(height: 16),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white), onPressed: fp.fetchFolders, child: Text('Coba Lagi', style: GoogleFonts.outfit())),
        ]));
        if (fp.folders.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.folder_open_rounded, color: Color(0xFF4A5568), size: 60)),
          const SizedBox(height: 20),
          Text('Belum ada folder', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Buat folder untuk mengelompokkan\nkliping berita Anda', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF8892A4))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => _showCreateFolderDialog(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('Buat Folder Pertama', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ]));
        return RefreshIndicator(
          color: const Color(0xFFFF6B6B), backgroundColor: const Color(0xFF141824),
          onRefresh: () => fp.fetchFolders(),
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.9),
            itemCount: fp.folders.length,
            itemBuilder: (_, i) {
              final folder = fp.folders[i];
              return FolderCard(
                folder: folder, colorIndex: i,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FolderContentScreen(folder: folder))).then((_) => fp.fetchFolders()),
                onEdit: () => _showRenameFolderDialog(context, folder.folderId, folder.folderName),
                onDelete: () => _confirmDeleteFolder(context, folder.folderId, folder.folderName),
              );
            },
          ),
        );
      },
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Buat Folder Baru', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(controller: ctrl, autofocus: true, style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(hintText: 'Nama folder...', hintStyle: GoogleFonts.outfit(color: const Color(0xFF8892A4)),
            filled: true, fillColor: const Color(0xFF0D1220), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.outfit(color: const Color(0xFF8892A4)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white),
            onPressed: () async {
              final name = ctrl.text.trim(); if (name.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await context.read<FolderProvider>().createFolder(name);
              if (!context.mounted) return;
              _showSnack(ok ? 'Folder "$name" dibuat!' : 'Gagal membuat folder', ok);
            },
            child: Text('Buat', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  void _showRenameFolderDialog(BuildContext context, int folderId, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ganti Nama Folder', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(controller: ctrl, autofocus: true, style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(filled: true, fillColor: const Color(0xFF0D1220), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.outfit(color: const Color(0xFF8892A4)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4), foregroundColor: Colors.white),
            onPressed: () async {
              final name = ctrl.text.trim(); if (name.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await context.read<FolderProvider>().updateFolder(folderId, name);
              if (!context.mounted) return;
              _showSnack(ok ? 'Folder berhasil diubah' : 'Gagal mengubah folder', ok);
            },
            child: Text('Simpan', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext context, int folderId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Folder?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Folder "$name" akan dihapus. Kliping di dalamnya tidak akan ikut terhapus.', style: GoogleFonts.outfit(color: const Color(0xFF8892A4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.outfit(color: const Color(0xFF8892A4)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context.read<FolderProvider>().deleteFolder(folderId);
              if (!context.mounted) return;
              _showSnack(ok ? 'Folder dihapus' : 'Gagal menghapus', ok);
            },
            child: Text('Hapus', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.outfit()),
      backgroundColor: success ? const Color(0xFF06D6A0) : const Color(0xFFFF6B6B),
      duration: const Duration(seconds: 2),
    ));
  }
}
