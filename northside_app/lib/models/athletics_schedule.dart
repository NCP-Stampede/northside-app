// lib/models/athletics_schedule.dart
import '../core/utils/logger.dart';
import 'sport_data.dart';

import '../presentation/athletics/sport_detail_page.dart';
import 'article.dart';
import 'bulletin_post.dart';

class AthleticsSchedule {
  final String id;
  final String? name;  // Optional event name
  final String date;
  final String time;
  final String sport;
  final String gender;
  final String level;
  final String opponent;
  final String location;
  final bool home;
  final DateTime createdAt;

  const AthleticsSchedule({
    required this.id,
    this.name,  // Optional event name
    required this.date,
    required this.time,
    required this.sport,
    required this.gender,
    required this.level,
    required this.opponent,
    required this.location,
    required this.home,
    required this.createdAt,
  });

  factory AthleticsSchedule.fromJson(Map<String, dynamic> json) {
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
        AppLogger.warning('Error parsing createdAt: $e');
        return DateTime.now();
      }
    }

    return AthleticsSchedule(
      id: json['\$oid'] ?? json['_id']?['\$oid'] ?? '',
      name: json['name'],  // Optional event name
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      sport: (json['sport'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      opponent: (json['opponent'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      home: json['home'] ?? false,
      createdAt: parseCreatedAt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,  // Include optional event name
      'date': date,
      'time': time,
      'sport': sport,
      'gender': gender,
      'level': level,
      'opponent': opponent,
      'location': location,
      'home': home,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to GameSchedule for UI compatibility (sport_detail_page.dart)
  GameSchedule toGameSchedule() {
    // Use event name if available, otherwise create a team name from gender and level
    final eventName = name?.isNotEmpty == true 
        ? name! 
        : '${gender.toUpperCase()} ${level.toUpperCase()}';
        
    return GameSchedule(
      date: date,
      time: time,
      event: eventName,
      opponent: opponent,
      location: location,
      score: '', // Score not available in schedule, only for completed games
      result: '', // Result not available in schedule, only for completed games
    );
  }

  // Convert to Article for events display
  Article toArticle() {
    final teamName = '${gender.toUpperCase()} ${level.toUpperCase()}';
    
    // Format sport name for display in ALL CAPS (cross-country -> CROSS COUNTRY)
    final displaySport = SportsData.getDisplaySportNameCaps(sport);
    
    // Use event name for title if available, otherwise format based on home/away
    String articleTitle;
    if (name?.isNotEmpty == true) {
      articleTitle = name!;
    } else {
      // For away games, show "[SPORT] at [location]", for home games show "[SPORT] vs [opponent]"
      if (home) {
        articleTitle = '$displaySport vs $opponent';
      } else {
        articleTitle = '$displaySport at $location';
      }
    }
        
    return Article(
      title: articleTitle,
      subtitle: _buildArticleSubtitle(),
      content: '$teamName ${home ? "vs" : "at"} $opponent at $location on $date at $time.',
      imagePath: 'assets/images/flexes_icon.png', // Use flexes icon for athletics games
    );
  }

  // Helper method to build article subtitle based on event date
  String _buildArticleSubtitle() {
    try {
      final eventDate = _parseEventDateForArticle();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
      
      // If it's today, show time only
      if (eventDay.isAtSameMomentAs(today)) {
        return 'Today at $time';
      }
      
      // If it's in the future, show both days away and time
      final daysDifference = eventDay.difference(today).inDays;
      if (daysDifference > 0) {
        final daysText = daysDifference == 1 ? '1 day away' : '$daysDifference days away';
        return '$daysText at $time';
      }
      
      // If it's in the past, show time (fallback)
      return time;
    } catch (e) {
      // If date parsing fails, fallback to time
      return time;
    }
  }

  // Helper method to parse event date for articles
  DateTime _parseEventDateForArticle() {
    if (date.isEmpty) return createdAt;

    try {
      // Try to parse formats like "6/27/2025"
      if (date.contains('/')) {
        final parts = date.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          return DateTime(year, month, day);
        }
      }

      // Try parsing "Aug 26 2025" format
      if (date.contains(' ') && !date.contains('/') && !date.contains('-')) {
        final parts = date.split(' ');
        if (parts.length == 3) {
          final monthStr = parts[0];
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          final monthMap = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
          };
          
          final month = monthMap[monthStr] ?? 1;
          return DateTime(year, month, day);
        }
      }

      // Try parsing track sports format: "Mon, Aug 18" or "Wed, Apr 2"
      if (date.contains(',') && date.contains(' ')) {
        final parts = date.split(', ');
        if (parts.length == 2) {
          final datePart = parts[1].trim();
          final dateComponents = datePart.split(' ');
          if (dateComponents.length == 2) {
            final monthStr = dateComponents[0];
            final day = int.tryParse(dateComponents[1]) ?? 1;
            final currentYear = DateTime.now().year;
            
            // Map month abbreviations to numbers
            final monthMap = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
              'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            };
            
            final month = monthMap[monthStr] ?? 1;
            
            // Determine year - if month is before current month, assume next year
            final now = DateTime.now();
            int year = currentYear;
            if (month < now.month || (month == now.month && day < now.day)) {
              year = currentYear + 1;
            }
            
            return DateTime(year, month, day);
          }
        }
      }

      return DateTime.parse(date);
    } catch (e) {
      return createdAt;
    }
  }

  // Convert to BulletinPost for bulletin display
  BulletinPost toBulletinPost() {
    DateTime parseEventDate() {
      try {
        if (date.isEmpty) return createdAt;

        // Try to parse formats like "6/27/2025"
        if (date.contains('/')) {
          final parts = date.split('/');
          if (parts.length == 3) {
            final month = int.tryParse(parts[0]) ?? 1;
            int day = int.tryParse(parts[1]) ?? 1;
            int year = int.tryParse(parts[2]) ?? DateTime.now().year;

            // Validate ranges (now using standard 1-12 format)
            if (month < 1 || month > 12) {
              AppLogger.warning('Invalid month in athletics date: $date');
              return createdAt;
            }
            if (day < 1) day = 1;
            if (day > 31) day = 31;

            return DateTime(year, month, day);
          }
        }

        // Try parsing "Aug 26 2025" format (athletics schedule format)
        if (date.contains(' ') && !date.contains('/') && !date.contains('-')) {
          final parts = date.split(' ');
          if (parts.length == 3) {
            final monthStr = parts[0];
            final day = int.tryParse(parts[1]) ?? 1;
            final year = int.tryParse(parts[2]) ?? DateTime.now().year;
            
            // Map month abbreviations to numbers
            final monthMap = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
              'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            };
            
            final month = monthMap[monthStr] ?? 1;
            return DateTime(year, month, day);
          }
        }

        // Try parsing track sports format: "Mon, Aug 18" or "Wed, Apr 2"
        if (date.contains(',') && date.contains(' ')) {
          final parts = date.split(', ');
          if (parts.length == 2) {
            final datePart = parts[1].trim();
            final dateComponents = datePart.split(' ');
            if (dateComponents.length == 2) {
              final monthStr = dateComponents[0];
              final day = int.tryParse(dateComponents[1]) ?? 1;
              final currentYear = DateTime.now().year;
              
              // Map month abbreviations to numbers
              final monthMap = {
                'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
              };
              
              final month = monthMap[monthStr] ?? 1;
              
              // Determine year - if month is before current month, assume next year
              final now = DateTime.now();
              int year = currentYear;
              if (month < now.month || (month == now.month && day < now.day)) {
                year = currentYear + 1;
              }
              
              return DateTime(year, month, day);
            }
          }
        }

        // Fallback to trying DateTime.parse
        return DateTime.parse(date);
      } catch (e) {
        AppLogger.warning('Error parsing athletics schedule date "$date": $e');
        return createdAt;
      }
    }

    // Format sport name for display in ALL CAPS (cross-country -> CROSS COUNTRY)  
    final displaySport = SportsData.getDisplaySportNameCaps(sport);

    // Format title based on name availability and home/away
    String bulletinTitle;
    if (name?.isNotEmpty == true) {
      bulletinTitle = name!;
    } else {
      // For away games, show "[SPORT] at [location]", for home games show "[SPORT] vs [opponent]"
      if (home) {
        bulletinTitle = '$displaySport vs $opponent';
      } else {
        bulletinTitle = '$displaySport at $location';
      }
    }

    return BulletinPost(
      title: bulletinTitle,
      subtitle: _buildSubtitle(parseEventDate()),
      date: parseEventDate(),
      content: '${gender.toUpperCase()} ${level.toUpperCase()} ${home ? "vs" : "at"} $opponent at $location on $date at $time.',
      imagePath: 'assets/images/flexes_icon.png', // Use flexes icon for athletics events
      isPinned: false,
    );
  }

  // Helper method to build subtitle based on event date
  String _buildSubtitle(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    
    // If it's today, show time only
    if (eventDay.isAtSameMomentAs(today)) {
      return time;
    }
    
    // If it's in the future, show days away only
    final daysDifference = eventDay.difference(today).inDays;
    if (daysDifference > 0) {
      return daysDifference == 1 ? '1 day away' : '$daysDifference days away';
    }
    
    // If it's in the past, show time (fallback)
    return time;
  }
}
