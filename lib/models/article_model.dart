class ArticleModel {
  final String? sourceName;
  final String? sourceId;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  ArticleModel({
    this.sourceName,
    this.sourceId,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;
    return ArticleModel(
      sourceName: source?['name'] as String?,
      sourceId: source?['id'] as String?,
      author: json['author'] as String?,
      title: (json['title'] as String?)?.replaceAll(' - [Removed]', '') ??
          'No Title',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
      content: json['content'] as String?,
    );
  }

  bool get isValid =>
      title != '[Removed]' && title.isNotEmpty && url.isNotEmpty;
}
