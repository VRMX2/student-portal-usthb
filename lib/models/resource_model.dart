import 'package:cloud_firestore/cloud_firestore.dart';

enum ResourceType { pdf, image, other }

class Resource {
  final String id;
  final String title;
  final String moduleId; // Linked to a module
  final String url; // Firebase Storage URL
  final ResourceType type;
  final DateTime uploadDate;
  final String size; // e.g. "2.5 MB"

  Resource({
    required this.id,
    required this.title,
    required this.moduleId,
    required this.url,
    required this.type,
    required this.uploadDate,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'moduleId': moduleId,
      'url': url,
      'type': type.toString().split('.').last,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'size': size,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> data, String id) {
    return Resource(
      id: id,
      title: data['title'] ?? '',
      moduleId: data['moduleId'] ?? '',
      url: data['url'] ?? '',
      type: ResourceType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => ResourceType.other,
      ),
      uploadDate: (data['uploadDate'] as Timestamp).toDate(),
      size: data['size'] ?? '',
    );
  }
}
