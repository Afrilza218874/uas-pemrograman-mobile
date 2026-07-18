import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/bookmark_model.dart';
import '../../models/folder_model.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/folder_provider.dart';

class WorkspaceScreen extends StatefulWidget {
  final BookmarkModel bookmark;
  const WorkspaceScreen({super.key, required this.bookmark});
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late TextEditingController _notesCtrl;
  late String _readingStatus;
  int? _selectedFolderId;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.bookmark.myNotes ?? '');
    _readingStatus = widget.bookmark.readingStatus;
    _selectedFolderId = widget.bookmark.folderId;
    _notesCtrl.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final ok = await context.read<BookmarkProvider>().updateBookmark(
      widget.bookmark.bookmarkId,
      myNotes: _notesCtrl.text.trim(),
      folderId: _selectedFolderId,
      readingStatus: _readingStatus,
      clearFolder: _selectedFolderId == null,
    );
    if (!mounted) return;
    setState(() { _isSaving = false; _hasChanges = false; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? '\u2705 Catatan disimpan!' : '\u274C Gagal menyimpan', style: GoogleFonts.outfit()),
      backgroundColor: ok ? const Color(0xFF06D6A0) : const Color(0xFFFF6B6B),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final folders = context.watch<FolderProvider>().folders;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Editor Catatan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF8892A4)), onPressed: () => _openUrl(widget.bookmark.articleUrl)),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B6B))))
                : Text('Simpan', style: GoogleFonts.outfit(color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArticleHeader(),
            const SizedBox(height: 24),
            _buildSectionLabel('Status Membaca'),
            const SizedBox(height: 10),
            _buildReadingStatusToggle(),
            const SizedBox(height: 24),
            _buildSectionLabel('Folder'),
            const SizedBox(height: 10),
            _buildFolderSelector(folders),
            const SizedBox(height: 24),
            _buildSectionLabel('Catatan & Opini Pribadi'),
            const SizedBox(height: 10),
            _buildNotesEditor(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141824), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2640).withOpacity(0.6), width: 0.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (widget.bookmark.imageUrl != null && widget.bookmark.imageUrl!.isNotEmpty)
                ? CachedNetworkImage(imageUrl: widget.bookmark.imageUrl!, width: 70, height: 70, fit: BoxFit.cover, errorWidget: (_, __, ___) => _thumb())
                : _thumb(),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.bookmark.sourceName != null)
              Text(widget.bookmark.sourceName!, style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(widget.bookmark.title, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4)),
          ])),
        ],
      ),
    );
  }

  Widget _buildReadingStatusToggle() {
    final isRead = _readingStatus == 'Selesai';
    return Row(children: [
      _statusChip(label: '\u{1F4D6} Belum Dibaca', selected: !isRead,
        onTap: () => setState(() { _readingStatus = 'Belum Dibaca'; _hasChanges = true; })),
      const SizedBox(width: 10),
      _statusChip(label: '\u2705 Selesai Dibaca', selected: isRead, selectedColor: const Color(0xFF06D6A0),
        onTap: () => setState(() { _readingStatus = 'Selesai'; _hasChanges = true; })),
    ]);
  }

  Widget _statusChip({required String label, required bool selected, Color selectedColor = const Color(0xFFFF6B6B), required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor.withOpacity(0.15) : const Color(0xFF141824),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? selectedColor : const Color(0xFF1E2640), width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? selectedColor : const Color(0xFF8892A4))),
      ),
    );
  }

  Widget _buildFolderSelector(List<FolderModel> folders) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E2640))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true, value: _selectedFolderId,
          dropdownColor: const Color(0xFF1A2035),
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          items: [
            DropdownMenuItem<int?>(value: null, child: Text('Tanpa folder', style: GoogleFonts.outfit(color: const Color(0xFF8892A4)))),
            ...folders.map((f) => DropdownMenuItem<int?>(value: f.folderId,
              child: Row(children: [
                const Icon(Icons.folder_rounded, color: Color(0xFF4ECDC4), size: 16), const SizedBox(width: 8),
                Text(f.folderName),
              ]))),
          ],
          onChanged: (val) => setState(() { _selectedFolderId = val; _hasChanges = true; }),
        ),
      ),
    );
  }

  Widget _buildNotesEditor() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E2640))),
      child: TextField(
        controller: _notesCtrl, maxLines: 12,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, height: 1.7),
        decoration: InputDecoration(
          hintText: 'Tulis opini, analisis, atau catatan pribadi tentang artikel ini...',
          hintStyle: GoogleFonts.outfit(color: const Color(0xFF4A5568), fontSize: 14),
          border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _thumb() => Container(width: 70, height: 70, color: const Color(0xFF1A2035), child: const Icon(Icons.article_rounded, color: Color(0xFF4A5568), size: 28));

  Widget _buildSectionLabel(String label) => Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8892A4), letterSpacing: 0.5));

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
