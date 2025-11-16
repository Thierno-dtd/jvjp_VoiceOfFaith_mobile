import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType {
  image,
  video;

  String get displayName {
    switch (this) {
      case PostType.image:
        return 'Image';
      case PostType.video:
        return 'Vidéo';
    }
  }
}

enum PostCategory {
  pensee,
  pasteur,
  media;

  String get displayName {
    switch (this) {
      case PostCategory.pensee:
        return 'Pensée du jour';
      case PostCategory.pasteur:
        return 'Message du pasteur';
      case PostCategory.media:
        return 'Équipe média';
    }
  }
}

class PostModel {
  final String id;
  final PostType type;
  final PostCategory category;
  final String content;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String authorId;
  final String authorName;
  final String authorRole;
  final DateTime createdAt;
  final int likes;
  final int views;

  PostModel({
    required this.id,
    required this.type,
    required this.category,
    required this.content,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    this.likes = 0,
    this.views = 0,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      type: PostType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PostType.image,
      ),
      category: PostCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => PostCategory.media,
      ),
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorRole: map['authorRole'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'category': category.name,
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'views': views,
    };
  }

  PostModel copyWith({
    String? content,
    int? likes,
    int? views,
  }) {
    return PostModel(
      id: id,
      type: type,
      category: category,
      content: content ?? this.content,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      views: views ?? this.views,
    );
  }
}