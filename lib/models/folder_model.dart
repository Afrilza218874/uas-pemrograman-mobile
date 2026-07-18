class FolderModel {
  final int folderId;
  final int userId;
  final String folderName;
  final String? createdAt;
  final int bookmarkCount;

  FolderModel({
    required this.folderId,
    required this.userId,
    required this.folderName,
    this.createdAt,
    this.bookmarkCount = 0,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      folderId: json['folder_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      folderName: json['folder_name'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      bookmarkCount: json['bookmark_count'] as int? ?? 0,
    );
  }

  FolderModel copyWith({String? folderName, int? bookmarkCount}) {
    return FolderModel(
      folderId: folderId,
      userId: userId,
      folderName: folderName ?? this.folderName,
      createdAt: createdAt,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
    );
  }
}
