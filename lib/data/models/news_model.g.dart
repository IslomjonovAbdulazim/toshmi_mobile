// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsModel _$NewsModelFromJson(Map<String, dynamic> json) => NewsModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  authorId: (json['author_id'] as num?)?.toInt(),
  externalLinks: (json['external_links'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  imageIds: (json['image_ids'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  isPublished: json['is_published'] as bool,
);

Map<String, dynamic> _$NewsModelToJson(NewsModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'author_id': instance.authorId,
  'external_links': instance.externalLinks,
  'image_ids': instance.imageIds,
  'created_at': instance.createdAt.toIso8601String(),
  'is_published': instance.isPublished,
};

NewsRequest _$NewsRequestFromJson(Map<String, dynamic> json) => NewsRequest(
  title: json['title'] as String,
  content: json['content'] as String,
  externalLinks: (json['external_links'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isPublished: json['is_published'] as bool,
);

Map<String, dynamic> _$NewsRequestToJson(NewsRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'external_links': instance.externalLinks,
      'is_published': instance.isPublished,
    };
