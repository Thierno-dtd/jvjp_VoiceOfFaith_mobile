import 'package:cloud_firestore/cloud_firestore.dart';

enum AudioCategory {
  emission,
  podcast,
  teaching;

  String get displayName {
    switch (this) {
      case AudioCategory.emission:
        return 'Émission';
      case AudioCategory.podcast:
        return 'Podcast';
      case AudioCategory.teaching:
        return 'Enseignement';
    }
  }
}

class AudioModel {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String? thumbnailUrl;
  final int duration; // en secondes
  final String uploadedBy;
  final String uploadedByName;
  final DateTime createdAt;
  final int downloads;
  final int plays;
  final AudioCategory category;

  AudioModel({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.createdAt,
    this.downloads = 0,
    this.plays = 0,
    required this.category,
  });

  factory AudioModel.fromMap(Map<String, dynamic> map, String id) {
    return AudioModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'] ?? 0,
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedByName: map['uploadedByName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      downloads: map['downloads'] ?? 0,
      plays: map['plays'] ?? 0,
      category: AudioCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AudioCategory.emission,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'downloads': downloads,
      'plays': plays,
      'category': category.name,
    };
  }

  AudioModel copyWith({
    String? title,
    String? description,
    int? downloads,
    int? plays,
  }) {
    return AudioModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      uploadedBy: uploadedBy,
      uploadedByName: uploadedByName,
      createdAt: createdAt,
      downloads: downloads ?? this.downloads,
      plays: plays ?? this.plays,
      category: category,
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }
}