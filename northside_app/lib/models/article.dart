// lib/models/article.dart

class Article {
  const Article({
    required this.title,
    required this.subtitle,
    required this.date, // NEW: The date of the announcement
    this.isPinned = false, // NEW: To identify pinned items
    this.imagePath,
    required this.content,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final bool isPinned;
  final String? imagePath;
  final String content;
}
