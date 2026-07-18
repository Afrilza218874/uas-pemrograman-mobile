import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/article_model.dart';
import '../../models/folder_model.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/folder_provider.dart';

class DetailScreen extends StatelessWidget {
  final ArticleModel article;
  const DetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
      floatingActionButton: _buildSaveFAB(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260, pinned: true,
      backgroundColor: const Color(0xFF0A0E1A),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18), onPressed: () => Navigator.pop(context)),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white, size: 20), onPressed: () => _openInBrowser(article.url)),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: article.urlToImage != null
            ? CachedNetworkImage(imageUrl: article.urlToImage!, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF141824)),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFF141824)))
            : Container(color: const Color(0xFF141824), child: const Icon(Icons.article_rounded, color: Color(0xFF4A5568), size: 60)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (article.sourceName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(article.sourceName!, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
              ],
              if (article.publishedAt != null)
                Flexible(child: Text(_formatDate(article.publishedAt!), style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF8892A4)))),
            ],
          ),
          const SizedBox(height: 14),
          Text(article.title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.35)),
          const SizedBox(height: 12),
          if (article.author != null && article.author!.isNotEmpty)
            Row(children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF8892A4)), const SizedBox(width: 6),
              Flexible(child: Text(article.author!, style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF8892A4)), overflow: TextOverflow.ellipsis)),
            ]),
          const SizedBox(height: 20),
          Container(height: 0.5, color: const Color(0xFF1E2640)),
          const SizedBox(height: 20),
          if (article.description != null && article.description!.isNotEmpty) ...[
            Text(article.description!, style: GoogleFonts.outfit(fontSize: 15, color: const Color(0xFFCDD5DF), height: 1.7)),
            const SizedBox(height: 20),
          ],
          if (article.content != null && article.content!.isNotEmpty) ...[
            Text(_trimContent(article.content!), style: GoogleFonts.outfit(fontSize: 15, color: const Color(0xFFCDD5DF), height: 1.7)),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1E2640)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), foregroundColor: const Color(0xFF8892A4)),
              onPressed: () => _openInBrowser(article.url),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text('Baca artikel lengkap', style: GoogleFonts.outfit()),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSaveFAB(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (_, bm, __) {
        final saved = bm.isBookmarked(article.url);
        return FloatingActionButton.extended(
          onPressed: saved ? null : () => _showSaveSheet(context),
          backgroundColor: saved ? const Color(0xFF1E2640) : const Color(0xFFFF6B6B),
          foregroundColor: saved ? const Color(0xFF8892A4) : Colors.white,
          icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 20),
          label: Text(saved ? 'Sudah Dikliping' : 'Simpan Kliping', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        );
      },
    );
  }

  void _showSaveSheet(BuildContext context) {
    final folders = context.read<FolderProvider>().folders;
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF141824),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => _SaveToFolderSheet(
        folders: folders,
        onSave: (folderId) async {
          Navigator.pop(ctx);
          final bm = context.read<BookmarkProvider>();
          final ok = await bm.saveBookmark(article, folderId: folderId);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok ? '\u2705 Artikel berhasil dikliping!' : '\u274C Gagal menyimpan', style: GoogleFonts.outfit()),
            backgroundColor: ok ? const Color(0xFF06D6A0) : const Color(0xFFFF6B6B),
            duration: const Duration(seconds: 2),
          ));
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try { return DateFormat('d MMMM yyyy \u2022 HH:mm', 'id_ID').format(DateTime.parse(dateStr).toLocal()); } catch (_) { return dateStr; }
  }

  String _trimContent(String content) {
    final idx = content.indexOf('[+');
    return idx != -1 ? content.substring(0, idx).trim() : content;
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SaveToFolderSheet extends StatelessWidget {
  final List<FolderModel> folders;
  final void Function(int? folderId) onSave;
  const _SaveToFolderSheet({required this.folders, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFF4A5568), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Simpan ke Folder', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1E2640), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.bookmark_add_outlined, color: Color(0xFFFF6B6B), size: 20)),
            title: Text('Simpan tanpa folder', style: GoogleFonts.outfit(color: Colors.white)),
            subtitle: Text('Langsung ke semua kliping', style: GoogleFonts.outfit(color: const Color(0xFF8892A4), fontSize: 12)),
            onTap: () => onSave(null),
          ),
          if (folders.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Align(alignment: Alignment.centerLeft, child: Text('Pilih folder', style: GoogleFonts.outfit(color: const Color(0xFF8892A4), fontSize: 12))),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true, itemCount: folders.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.folder_rounded, color: Color(0xFF4ECDC4)),
                  title: Text(folders[i].folderName, style: GoogleFonts.outfit(color: Colors.white)),
                  subtitle: Text('${folders[i].bookmarkCount} kliping', style: GoogleFonts.outfit(color: const Color(0xFF8892A4), fontSize: 12)),
                  onTap: () => onSave(folders[i].folderId),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
