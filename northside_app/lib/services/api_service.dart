

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:northside_app/models/sport_data.dart';


class ApiService {
  // The URL where your Python API is deployed (from .env)
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  Future<List<SportEntry>> fetchSportsData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/sports'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SportEntry.fromMap(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found.');
      } else if (response.statusCode == 500) {
        throw Exception('The server had an error. Please try again later.');
      } else {
        throw Exception('Failed to load sports data: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
