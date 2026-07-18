class BookmarkModel {
  final int bookmarkId;
  final int userId;
  final int? folderId;
  final String title;
  final String? author;
  final String? sourceName;
  final String? imageUrl;
  final String articleUrl;
  final String? publishedDate;
  final String? description;
  final String? myNotes;
  final String readingStatus;
  final String? savedAt;
  final String? folderName;

  BookmarkModel({
    required this.bookmarkId,
    required this.userId,
    this.folderId,
    required this.title,
    this.author,
    this.sourceName,
    this.imageUrl,
    required this.articleUrl,
    this.publishedDate,
    this.description,
    this.myNotes,
    this.readingStatus = 'Belum Dibaca',
    this.savedAt,
    this.folderName,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      bookmarkId: json['bookmark_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      folderId: json['folder_id'] as int?,
      title: json['title'] as String? ?? '',
      author: json['author'] as String?,
      sourceName: json['source_name'] as String?,
      imageUrl: json['image_url'] as String?,
      articleUrl: json['article_url'] as String? ?? '',
      publishedDate: json['published_date'] as String?,
      description: json['description'] as String?,
      myNotes: json['my_notes'] as String?,
      readingStatus: json['reading_status'] as String? ?? 'Belum Dibaca',
      savedAt: json['saved_at'] as String?,
      folderName: json['folder_name'] as String?,
    );
  }

  bool get isRead => readingStatus == 'Selesai';

  BookmarkModel copyWith({
    int? folderId,
    String? myNotes,
    String? readingStatus,
    String? folderName,
  }) {
    return BookmarkModel(
      bookmarkId: bookmarkId,
      userId: userId,
      folderId: folderId ?? this.folderId,
      title: title,
      author: author,
      sourceName: sourceName,
      imageUrl: imageUrl,
      articleUrl: articleUrl,
      publishedDate: publishedDate,
      description: description,
      myNotes: myNotes ?? this.myNotes,
      readingStatus: readingStatus ?? this.readingStatus,
      savedAt: savedAt,
      folderName: folderName ?? this.folderName,
    );
  }
}
