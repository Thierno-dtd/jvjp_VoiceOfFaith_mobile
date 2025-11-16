import 'package:cloud_firestore/cloud_firestore.dart';

class DailySummary {
  final int day;
  final DateTime date;
  final String title;
  final String summary;
  final String? youtubeUrl;

  DailySummary({
    required this.day,
    required this.date,
    required this.title,
    required this.summary,
    this.youtubeUrl,
  });

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    return DailySummary(
      day: map['day'] ?? 1,
      date: (map['date'] as Timestamp).toDate(),
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      youtubeUrl: map['youtubeUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'date': Timestamp.fromDate(date),
      'title': title,
      'summary': summary,
      'youtubeUrl': youtubeUrl,
    };
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final String location;
  final List<DailySummary> dailySummaries;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.location,
    required this.dailySummaries,
    required this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      dailySummaries: (map['dailySummaries'] as List<dynamic>?)
              ?.map((e) => DailySummary.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'imageUrl': imageUrl,
      'location': location,
      'dailySummaries': dailySummaries.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }
}