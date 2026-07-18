import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/article_model.dart';

class NewsCard extends StatelessWidget {
  final ArticleModel article;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const NewsCard({super.key, required this.article, required this.isBookmarked, required this.onTap, required this.onBookmark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141824),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E2640).withOpacity(0.6), width: 0.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!, height: 175, width: double.infinity, fit: BoxFit.cover,
                  placeholder: (_, __) => _imagePlaceholder(), errorWidget: (_, __, ___) => _imagePlaceholder(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (article.sourceName != null && article.sourceName!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(article.sourceName!, style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (article.publishedAt != null)
                        Flexible(child: Text(_timeAgo(article.publishedAt!), style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF8892A4)), overflow: TextOverflow.ellipsis)),
                      const Spacer(),
                      GestureDetector(
                        onTap: onBookmark,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isBookmarked ? const Color(0xFFFF6B6B).withOpacity(0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 20, color: isBookmarked ? const Color(0xFFFF6B6B) : const Color(0xFF8892A4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(article.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4)),
                  if (article.description != null && article.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(article.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF8892A4), height: 1.5)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    height: 175, color: const Color(0xFF1A2035),
    child: Center(child: Icon(Icons.article_rounded, color: const Color(0xFF4A5568), size: 40)),
  );

  String _timeAgo(String publishedAt) {
    try { return timeago.format(DateTime.parse(publishedAt).toLocal(), locale: 'id'); } catch (_) { return ''; }
  }
}
