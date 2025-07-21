
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:northside_app/models/sport_data.dart';

class ApiService {
  // The URL where your Python API is deployed
  static const String baseUrl = 'https://api.tgnest.hackclub.app/api';

  Future<List<SportEntry>> fetchSportsData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/sports'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SportEntry.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load sports data');
    }
  }
}
