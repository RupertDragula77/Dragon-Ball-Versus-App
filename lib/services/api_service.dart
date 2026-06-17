import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class ApiService {
  static const String baseUrl = 'https://dragonball-api.com/api';

  // Zapytanie 1: Lista postaci
  Future<List<Character>> getCharacters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/characters?limit=100'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'];
      return items.map((json) => Character.fromJson(json)).toList();
    } else {
      throw Exception('Błąd pobierania postaci: ${response.statusCode}');
    }
  }

  // Zapytanie 2: Szczegóły postaci
  Future<Character> getCharacterById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/characters/$id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Character.fromJson(data);
    } else {
      throw Exception('Błąd pobierania postaci $id: ${response.statusCode}');
    }
  }
}