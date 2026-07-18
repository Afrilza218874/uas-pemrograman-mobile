import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bookmark_model.dart';

class BookmarkCard extends StatelessWidget {
  final BookmarkModel bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookmarkCard({super.key, required this.bookmark, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('bm_${bookmark.bookmarkId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(14)),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_rounded, color: Colors.white, size: 22), SizedBox(height: 4),
          Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141824), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E2640).withOpacity(0.6), width: 0.5),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (bookmark.imageUrl != null && bookmark.imageUrl!.isNotEmpty)
                    ? CachedNetworkImage(imageUrl: bookmark.imageUrl!, width: 70, height: 70, fit: BoxFit.cover, errorWidget: (_, __, ___) => _thumb())
                    : _thumb(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (bookmark.sourceName != null && bookmark.sourceName!.isNotEmpty)
                          Flexible(child: Text(bookmark.sourceName!, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600))),
                        const Spacer(),
                        _statusBadge(),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(bookmark.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4)),
                    if (bookmark.myNotes != null && bookmark.myNotes!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(children: [
                        const Icon(Icons.notes_rounded, size: 12, color: Color(0xFF4ECDC4)), const SizedBox(width: 4),
                        Expanded(child: Text(bookmark.myNotes!, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF4ECDC4)))),
                      ]),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF4A5568), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb() => Container(width: 70, height: 70, color: const Color(0xFF1A2035),
    child: const Icon(Icons.article_rounded, color: Color(0xFF4A5568), size: 28));

  Widget _statusBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bookmark.isRead ? const Color(0xFF06D6A0).withOpacity(0.14) : const Color(0xFFFFBE0B).withOpacity(0.14),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(bookmark.isRead ? '✓ Selesai' : 'Belum',
      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600,
        color: bookmark.isRead ? const Color(0xFF06D6A0) : const Color(0xFFFFBE0B))),
  );

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Kliping?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Artikel ini akan dihapus dari kliping Anda.', style: GoogleFonts.outfit(color: const Color(0xFF8892A4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: GoogleFonts.outfit(color: const Color(0xFF8892A4)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }
}
