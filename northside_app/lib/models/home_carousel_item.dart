// lib/models/home_carousel_item.dart

import 'article.dart';
import 'bulletin_post.dart';
import '../core/utils/logger.dart';

class HomeCarouselItem {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String date;
  final String? time;
  final String? sport;
  final String? gender;
  final String? level;
  final String? name;
  final String? opponent;
  final bool? home;
  final String? location;
  final String type; // "Announcement", "Event", or "Athletics"
  final DateTime createdAt;

  const HomeCarouselItem({
    required this.id,
    required this.title,
    this.description,
    this.content,
    required this.date,
    this.time,
    this.sport,
    this.gender,
    this.level,
    this.name,
    this.opponent,
    this.home,
    this.location,
    required this.type,
    required this.createdAt,
  });

  factory HomeCarouselItem.fromJson(Map<String, dynamic> json) {
    DateTime parseCreatedAt() {
      try {
        final createdAtField = json['createdAt'];
        if (createdAtField is Map && createdAtField.containsKey('\$date')) {
          // MongoDB timestamp format: {"$date": 1751022383799}
          final timestamp = createdAtField['\$date'];
          if (timestamp is int) {
            return DateTime.fromMillisecondsSinceEpoch(timestamp);
          }
        } else if (createdAtField is String) {
          // String format
          return DateTime.parse(createdAtField);
        }
        return DateTime.now();
      } catch (e) {
        AppLogger.warning('Error parsing createdAt', e);
        return DateTime.now();
      }
    }

    // Determine type based on presence of certain fields
    String determineType() {
      if (json.containsKey('sport') || json.containsKey('opponent')) {
        return 'Athletics';
      } else if (json.containsKey('start_date') || json.containsKey('end_date')) {
        return 'Announcement';
      } else {
        return 'Event';
      }
    }

    return HomeCarouselItem(
      id: json['_id']?['\$oid'] ?? json['\$oid'] ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      content: json['content']?.toString(),
      date: json['date']?.toString() ?? json['start_date']?.toString() ?? '',
      time: json['time']?.toString(),
      sport: json['sport']?.toString(),
      gender: json['gender']?.toString(),
      level: json['level']?.toString(),
      name: json['name']?.toString(),
      opponent: json['opponent']?.toString(),
      home: json['home'],
      location: json['location']?.toString(),
      type: determineType(),
      createdAt: parseCreatedAt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'date': date,
      'time': time,
      'sport': sport,
      'gender': gender,
      'level': level,
      'name': name,
      'opponent': opponent,
      'home': home,
      'location': location,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to Article for compatibility with existing UI
  Article toArticle() {
    String subtitle = _generateSubtitle();
    String imagePath = _getImagePath();
    String articleContent = _generateContent();

    return Article(
      title: title,
      subtitle: subtitle,
      imagePath: imagePath,
      content: articleContent,
    );
  }

  // Convert to BulletinPost for compatibility with existing UI
  BulletinPost toBulletinPost() {
    String subtitle = _generateSubtitle();
    String imagePath = _getImagePath();
    String bulletinContent = _generateContent();
    DateTime eventDate = _parseDate();

    return BulletinPost(
      title: title,
      subtitle: subtitle,
      date: eventDate,
      content: bulletinContent,
      imagePath: imagePath,
    );
  }

  String _generateSubtitle() {
    switch (type) {
      case 'Athletics':
        List<String> parts = [];
        if (sport != null) parts.add(sport!);
        if (opponent != null) {
          parts.add('vs ${opponent!}');
        }
        if (date.isNotEmpty) parts.add(date);
        if (time != null) parts.add(time!);
        return parts.join(' • ');
      case 'Announcement':
        return date;
      case 'Event':
        List<String> parts = [];
        if (date.isNotEmpty) parts.add(date);
        if (time != null) parts.add(time!);
        return parts.join(' • ');
      default:
        return date;
    }
  }

  String _getImagePath() {
    switch (type) {
      case 'Athletics':
        return 'assets/images/flexes_icon.png';
      case 'Announcement':
        return 'assets/images/icon.png';
      case 'Event':
        return 'assets/images/grades_icon.png';
      default:
        return 'assets/images/icon.png';
    }
  }

  String _generateContent() {
    List<String> contentParts = [];
    
    if (description != null && description!.isNotEmpty) {
      contentParts.add(description!);
    }
    
    if (content != null && content!.isNotEmpty) {
      contentParts.add(content!);
    }

    switch (type) {
      case 'Athletics':
        if (sport != null) contentParts.add('Sport: $sport');
        if (opponent != null) contentParts.add('Opponent: $opponent');
        if (location != null) contentParts.add('Location: $location');
        if (home != null) {
          contentParts.add(home! ? 'Home Game' : 'Away Game');
        }
        break;
      case 'Event':
        if (location != null) contentParts.add('Location: $location');
        break;
    }
    
    if (contentParts.isEmpty) {
      contentParts.add('Details will be available soon.');
    }
    
    return contentParts.join('\n\n');
  }

  DateTime _parseDate() {
    try {
      // Try parsing different date formats
      if (date.contains('/')) {
        // MM/dd/yyyy format
        final parts = date.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
      } else if (date.contains('-')) {
        // yyyy-mm-dd format
        return DateTime.parse(date);
      } else {
        // Try parsing as is
        return DateTime.parse(date);
      }
    } catch (e) {
      AppLogger.warning('Error parsing date: $date', e);
    }
    return DateTime.now();
  }
}
