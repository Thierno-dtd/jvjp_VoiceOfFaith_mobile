import 'package:cloud_firestore/cloud_firestore.dart';

class SermonModel {
  final String id;
  final String title;
  final DateTime date;
  final String imageUrl;
  final String pdfUrl;
  final String uploadedBy;
  final DateTime createdAt;
  final int downloads;

  SermonModel({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.pdfUrl,
    required this.uploadedBy,
    required this.createdAt,
    this.downloads = 0,
  });

  factory SermonModel.fromMap(Map<String, dynamic> map, String id) {
    return SermonModel(
      id: id,
      title: map['title'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      downloads: map['downloads'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'uploadedBy': uploadedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'downloads': downloads,
    };
  }

  SermonModel copyWith({
    String? title,
    int? downloads,
  }) {
    return SermonModel(
      id: id,
      title: title ?? this.title,
      date: date,
      imageUrl: imageUrl,
      pdfUrl: pdfUrl,
      uploadedBy: uploadedBy,
      createdAt: createdAt,
      downloads: downloads ?? this.downloads,
    );
  }
}