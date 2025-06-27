class News {
  final int id;
  final String title;
  final String content;
  final int authorId;
  final List<String> externalLinks;
  final List<int> imageIds;
  final DateTime createdAt;
  final bool isPublished;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.externalLinks,
    required this.imageIds,
    required this.createdAt,
    required this.isPublished,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      authorId: json['author_id'],
      externalLinks: List<String>.from(json['external_links'] ?? []),
      imageIds: List<int>.from(json['image_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      isPublished: json['is_published'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_id': authorId,
      'external_links': externalLinks,
      'image_ids': imageIds,
      'created_at': createdAt.toIso8601String(),
      'is_published': isPublished,
    };
  }

  News copyWith({
    int? id,
    String? title,
    String? content,
    int? authorId,
    List<String>? externalLinks,
    List<int>? imageIds,
    DateTime? createdAt,
    bool? isPublished,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      externalLinks: externalLinks ?? this.externalLinks,
      imageIds: imageIds ?? this.imageIds,
      createdAt: createdAt ?? this.createdAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}