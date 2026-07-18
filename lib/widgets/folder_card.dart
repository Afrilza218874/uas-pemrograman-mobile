import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/folder_model.dart';

class FolderCard extends StatelessWidget {
  final FolderModel folder;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FolderCard({super.key, required this.folder, required this.colorIndex, required this.onTap, required this.onEdit, required this.onDelete});

  static const _gradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)], [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
    [Color(0xFF6C63FF), Color(0xFF9D97FF)], [Color(0xFFFFBE0B), Color(0xFFFF9800)],
    [Color(0xFF06D6A0), Color(0xFF1BC98E)], [Color(0xFFF72585), Color(0xFFB5179E)],
    [Color(0xFF4895EF), Color(0xFF4361EE)], [Color(0xFFE76F51), Color(0xFFF4A261)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[colorIndex % _gradients.length];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: grad[0].withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Stack(
          children: [
            Positioned(right: -8, bottom: -8, child: Icon(Icons.folder_rounded, size: 80, color: Colors.white.withOpacity(0.08))),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 18)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showOptions(context),
                        child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 16)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(folder.folderName, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
                  const SizedBox(height: 4),
                  Text('${folder.bookmarkCount} kliping', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withOpacity(0.75))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF141824),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFF4A5568), borderRadius: BorderRadius.circular(2))),
              Text(folder.folderName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              ListTile(leading: const Icon(Icons.edit_rounded, color: Color(0xFF4ECDC4)), title: Text('Ganti Nama Folder', style: GoogleFonts.outfit(color: Colors.white)), onTap: () { Navigator.pop(ctx); onEdit(); }),
              ListTile(leading: const Icon(Icons.delete_rounded, color: Color(0xFFFF6B6B)), title: Text('Hapus Folder', style: GoogleFonts.outfit(color: const Color(0xFFFF6B6B))), onTap: () { Navigator.pop(ctx); onDelete(); }),
            ],
          ),
        ),
      ),
    );
  }
}
