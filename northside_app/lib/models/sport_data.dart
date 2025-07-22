// lib/models/sport_data.dart

class SportEntry {
  final String sport;
  final String season;
  final String gender;
  
  const SportEntry({
    required this.sport,
    required this.season,
    required this.gender,
  });
  
  factory SportEntry.fromMap(Map<String, dynamic> map) {
    return SportEntry(
      sport: map['sport'] ?? '',
      season: map['season'] ?? '',
      gender: map['gender'] ?? '',
    );
  }
}

class SportsData {
  // Hardcoded sports data based on user requirements
  static const List<Map<String, String>> _hardcodedSports = [
    {'sport': 'swimming', 'season': 'fall', 'gender': 'girls'},
    {'sport': 'swimming', 'season': 'winter', 'gender': 'boys'},
    {'sport': 'tennis', 'season': 'fall', 'gender': 'girls'},
    {'sport': 'tennis', 'season': 'spring', 'gender': 'boys'},
    {'sport': 'flag-football', 'season': 'fall', 'gender': 'girls'},
    {'sport': 'softball', 'season': 'fall', 'gender': 'boys'},
    {'sport': 'softball', 'season': 'spring', 'gender': 'girls'},
    {'sport': 'basketball', 'season': 'winter', 'gender': 'girls'},
    {'sport': 'basketball', 'season': 'winter', 'gender': 'boys'},
    {'sport': 'track-and-field-indoor', 'season': 'winter', 'gender': 'girls'},
    {'sport': 'track-and-field-indoor', 'season': 'winter', 'gender': 'boys'},
    {'sport': 'track-and-field-outdoor', 'season': 'spring', 'gender': 'girls'},
    {'sport': 'track-and-field-outdoor', 'season': 'spring', 'gender': 'boys'},
    {'sport': 'soccer', 'season': 'spring', 'gender': 'girls'},
    {'sport': 'soccer', 'season': 'fall', 'gender': 'boys'},
    {'sport': 'volleyball', 'season': 'fall', 'gender': 'girls'},
    {'sport': 'volleyball', 'season': 'spring', 'gender': 'boys'},
    {'sport': 'water-polo', 'season': 'spring', 'gender': 'girls'},
    {'sport': 'water-polo', 'season': 'spring', 'gender': 'boys'},
    {'sport': 'cross-country', 'season': 'fall', 'gender': 'girls'},
    {'sport': 'cross-country', 'season': 'fall', 'gender': 'boys'},
    {'sport': 'wrestling', 'season': 'winter', 'gender': 'boys'},
    {'sport': 'bowling', 'season': 'winter', 'gender': 'girls'},
    {'sport': 'bowling', 'season': 'winter', 'gender': 'boys'},
    {'sport': 'golf', 'season': 'fall', 'gender': 'girls'},
    {'sport': 'golf', 'season': 'fall', 'gender': 'boys'},
    {'sport': 'lacrosse', 'season': 'spring', 'gender': 'girls'},
    {'sport': 'lacrosse', 'season': 'spring', 'gender': 'boys'},
    {'sport': 'baseball', 'season': 'spring', 'gender': 'boys'},
    {'sport': 'badminton', 'season': 'spring', 'gender': 'girls'},
  ];

  // Get all sports entries
  static List<SportEntry> getAllSports() {
    return _hardcodedSports.map((sport) => SportEntry.fromMap(sport)).toList();
  }

  // Get sports for a specific season
  static List<SportEntry> getSportsBySeason(String season) {
    return getAllSports()
        .where((sport) => sport.season.toLowerCase() == season.toLowerCase())
        .toList();
  }

  // Get sports for a specific gender
  static List<SportEntry> getSportsByGender(String gender) {
    return getAllSports()
        .where((sport) => sport.gender.toLowerCase() == gender.toLowerCase())
        .toList();
  }

  // Get sports for a specific season and gender
  static List<SportEntry> getSportsBySeasonAndGender(String season, String gender) {
    return getAllSports()
        .where((sport) => 
            sport.season.toLowerCase() == season.toLowerCase() &&
            sport.gender.toLowerCase() == gender.toLowerCase())
        .toList();
  }

  // Get unique sports names (formatted for display)
  static List<String> getUniqueSportsNames() {
    final Set<String> uniqueSports = {};
    for (final sport in getAllSports()) {
      uniqueSports.add(_formatSportName(sport.sport));
    }
    final List<String> sportsList = uniqueSports.toList();
    sportsList.sort();
    return sportsList;
  }

  // Get unique sports names for a specific gender (formatted for display)
  static List<String> getUniqueSportsNamesByGender(String gender) {
    final Set<String> uniqueSports = {};
    for (final sport in getSportsByGender(gender)) {
      uniqueSports.add(_formatSportName(sport.sport));
    }
    final List<String> sportsList = uniqueSports.toList();
    sportsList.sort();
    return sportsList;
  }

  // Get the current season based on the current date
  static String getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;
    
    // Fall: August - November (8-11)
    // Winter: December - February (12, 1, 2)
    // Spring: March - July (3-7)
    
    if (month >= 8 && month <= 11) {
      return 'fall';
    } else if (month == 12 || month <= 2) {
      return 'winter';
    } else {
      return 'spring';
    }
  }

  // Get top 4 sports for current season (2 girls, 2 boys)
  static List<SportEntry> getTopSportsForCurrentSeason() {
    final currentSeason = getCurrentSeason();
    final seasonSports = getSportsBySeason(currentSeason);
    
    final girlsSports = seasonSports.where((sport) => sport.gender == 'girls').toList();
    final boysSports = seasonSports.where((sport) => sport.gender == 'boys').toList();
    
    final List<SportEntry> topSports = [];
    final Set<String> addedSports = {}; // Track sports to avoid duplicates
    
    // Add girls sports first (for left side of grid)
    for (final sport in girlsSports) {
      final displayName = _formatSportName(sport.sport);
      if (!addedSports.contains(displayName) && topSports.where((s) => s.gender == 'girls').length < 2) {
        topSports.add(sport);
        addedSports.add(displayName);
      }
    }
    
    // Add boys sports (for right side of grid)  
    for (final sport in boysSports) {
      final displayName = _formatSportName(sport.sport);
      if (!addedSports.contains(displayName) && topSports.where((s) => s.gender == 'boys').length < 2) {
        topSports.add(sport);
        addedSports.add(displayName);
      }
    }
    
    return topSports;
  }

  // Format sport name for display (capitalize and replace hyphens)
  static String _formatSportName(String sport) {
    // Special cases for proper formatting
    if (sport == 'track-and-field-indoor') {
      return 'Indoor Track & Field';
    }
    if (sport == 'track-and-field-outdoor') {
      return 'Outdoor Track & Field';
    }
    if (sport == 'cross-country') {
      return 'Cross Country';
    }
    
    return sport
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? 
            word[0].toUpperCase() + word.substring(1).toLowerCase() : word)
        .join(' ');
  }

  // Convert back to backend format (track sports lowercase, others uppercase)
  static String formatSportForBackend(String sport) {
    final normalized = sport.toLowerCase().trim();
    
    // Handle track sports - they use lowercase with hyphens
    if (normalized == 'indoor track & field' || normalized == 'indoor track and field') {
      return 'track-and-field-indoor';
    }
    if (normalized == 'outdoor track & field' || normalized == 'outdoor track and field') {
      return 'track-and-field-outdoor';
    }
    if (normalized == 'cross country') {
      return 'cross-country';
    }
    
    // For non-track sports, convert to UPPERCASE (as backend expects)
    // Basketball -> BASKETBALL, Flag Football -> FLAG FOOTBALL, etc.
    return sport.toUpperCase().replaceAll('-', ' ').replaceAll('&', 'AND');
  }

  // Get display sport name from backend format
  static String getDisplaySportName(String backendSport) {
    return _formatSportName(backendSport);
  }

  // Get display sport name in ALL CAPS for athletics titles
  static String getDisplaySportNameCaps(String backendSport) {
    final displayName = _formatSportName(backendSport);
    return displayName.toUpperCase();
  }

  // Check if a sport exists for a given gender and season
  static bool sportExists(String sport, String gender, String season) {
    final normalizedSport = formatSportForBackend(sport);
    return getAllSports().any((s) => 
        s.sport == normalizedSport &&
        s.gender.toLowerCase() == gender.toLowerCase() &&
        s.season.toLowerCase() == season.toLowerCase());
  }
}
