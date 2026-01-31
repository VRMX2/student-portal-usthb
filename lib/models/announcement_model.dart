class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String author; // e.g., "Administration", "Dept. Informatique"
  final String? imageUrl;
  final String? targetAudience; // e.g., "All", "L3", "Informatique"

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.author,
    this.imageUrl,
    this.targetAudience,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'author': author,
      'imageUrl': imageUrl,
      'targetAudience': targetAudience,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> data, String id) {
    return Announcement(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: DateTime.parse(data['date']),
      author: data['author'] ?? '',
      imageUrl: data['imageUrl'],
      targetAudience: data['targetAudience'],
    );
  }
}
