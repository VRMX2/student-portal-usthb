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
}
