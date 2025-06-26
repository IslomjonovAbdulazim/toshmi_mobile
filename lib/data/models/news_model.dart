import 'package:json_annotation/json_annotation.dart';

part 'news_model.g.dart';

@JsonSerializable()
class NewsModel {
  final int id;
  final String title;
  final String content;
  @JsonKey(name: 'author_id')
  final int? authorId;
  @JsonKey(name: 'external_links')
  final List<String> externalLinks;
  @JsonKey(name: 'image_ids')
  final List<int> imageIds;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'is_published')
  final bool isPublished;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.authorId,
    required this.externalLinks,
    required this.imageIds,
    required this.createdAt,
    required this.isPublished,
  });

  // Check if news has images
  bool get hasImages => imageIds.isNotEmpty;

  // Check if news has external links
  bool get hasExternalLinks => externalLinks.isNotEmpty;

  // Get content preview (first 100 characters)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }

  // Get content summary (first 200 characters)
  String get contentSummary {
    if (content.length <= 200) return content;
    return '${content.substring(0, 197)}...';
  }

  // Get reading time estimate (words per minute = 200)
  int get readingTimeMinutes {
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  // Get reading time text
  String get readingTimeText {
    final minutes = readingTimeMinutes;
    if (minutes == 1) return '1 daqiqa';
    return '$minutes daqiqa';
  }

  // Get formatted creation date
  String get formattedDate {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = createdAt.day;
    final month = months[createdAt.month];
    final year = createdAt.year;

    return '$day $month $year';
  }

  // Get short formatted date
  String get shortFormattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;

    return '$day.$month.$year';
  }

  // Get time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks hafta oldin';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months oy oldin';
    } else {
      final years = difference.inDays ~/ 365;
      return '$years yil oldin';
    }
  }

  // Check if news is new (within last 24 hours)
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  // Check if news is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newsDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return today.isAtSameMomentAs(newsDay);
  }

  // Check if news is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final newsDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return newsDay.isAfter(startDay.subtract(const Duration(days: 1))) &&
        newsDay.isBefore(startDay.add(const Duration(days: 7)));
  }

  // Get publication status text
  String get publicationStatus => isPublished ? 'Nashr etilgan' : 'Loyiha';

  // Get publication status color
  String get publicationStatusColor => isPublished ? '#4CAF50' : '#FF9800';

  // Get news category based on content (simple keyword detection)
  String get category {
    final lowerContent = content.toLowerCase();
    final lowerTitle = title.toLowerCase();
    final text = '$lowerTitle $lowerContent';

    if (text.contains('imtihon') || text.contains('exam')) return 'Imtihonlar';
    if (text.contains('tadbirlar') || text.contains('event') || text.contains('tadbir')) return 'Tadbirlar';
    if (text.contains('o\'qituvchi') || text.contains('ustoz') || text.contains('teacher')) return 'O\'qituvchilar';
    if (text.contains('talaba') || text.contains('student')) return 'Talabalar';
    if (text.contains('yangilik') || text.contains('news')) return 'Yangiliklar';
    if (text.contains('e\'lon') || text.contains('announcement')) return 'E\'lonlar';

    return 'Umumiy';
  }

  // Get category icon
  String get categoryIcon {
    switch (category) {
      case 'Imtihonlar':
        return '📋';
      case 'Tadbirlar':
        return '🎉';
      case 'O\'qituvchilar':
        return '👨‍🏫';
      case 'Talabalar':
        return '👨‍🎓';
      case 'Yangiliklar':
        return '📰';
      case 'E\'lonlar':
        return '📢';
      default:
        return '📝';
    }
  }

  // Get first image ID (for preview)
  int? get firstImageId => imageIds.isNotEmpty ? imageIds.first : null;

  // Get importance level based on keywords
  int get importanceLevel {
    final lowerContent = content.toLowerCase();
    final lowerTitle = title.toLowerCase();
    final text = '$lowerTitle $lowerContent';

    if (text.contains('muhim') || text.contains('important') || text.contains('urgent')) return 3;
    if (text.contains('imtihon') || text.contains('exam') || text.contains('test')) return 2;
    if (text.contains('yangi') || text.contains('new') || text.contains('tadbirlar')) return 1;

    return 0;
  }

  // Get word count
  int get wordCount => content.split(' ').length;

  // Check if news is long
  bool get isLongArticle => wordCount > 500;

  // JSON serialization
  factory NewsModel.fromJson(Map<String, dynamic> json) => _$NewsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NewsModelToJson(this);

  // Copy with method
  NewsModel copyWith({
    int? id,
    String? title,
    String? content,
    int? authorId,
    List<String>? externalLinks,
    List<int>? imageIds,
    DateTime? createdAt,
    bool? isPublished,
  }) {
    return NewsModel(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NewsModel(id: $id, title: $title, category: $category, published: $isPublished, timeAgo: $timeAgo)';
  }
}

// News request model for admin endpoint
@JsonSerializable()
class NewsRequest {
  final String title;
  final String content;
  @JsonKey(name: 'external_links')
  final List<String> externalLinks;
  @JsonKey(name: 'is_published')
  final bool isPublished;

  const NewsRequest({
    required this.title,
    required this.content,
    required this.externalLinks,
    required this.isPublished,
  });

  // JSON serialization
  factory NewsRequest.fromJson(Map<String, dynamic> json) => _$NewsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$NewsRequestToJson(this);

  @override
  String toString() {
    return 'NewsRequest(title: $title, published: $isPublished, links: ${externalLinks.length})';
  }
}