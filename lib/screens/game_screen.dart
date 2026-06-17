import 'package:flutter/material.dart';
import 'dart:math';
import '../models/character.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import 'character_detail_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Character> characters;

  const GameScreen({super.key, required this.characters});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();
  final Random _random = Random();

  late Character _character1;
  late Character _character2;

  int _streak = 0;
  bool _gameOver = false;
  bool _answered = false;
  int? _selectedIndex;
  bool _wasCorrect = false;

  @override
  void initState() {
    super.initState();
    _pickNewCharacters();
  }

  void _pickNewCharacters() {
    final shuffled = List<Character>.from(widget.characters)..shuffle(_random);
    _character1 = shuffled[0];
    _character2 = shuffled[1];
    _answered = false;
    _selectedIndex = null;
  }

  void _onChoose(int index) async {
    if (_answered) return;

    final chosen = index == 0 ? _character1 : _character2;
    final other = index == 0 ? _character2 : _character1;
    final isCorrect = chosen.kiValue >= other.kiValue;

    setState(() {
      _answered = true;
      _selectedIndex = index;
      _wasCorrect = isCorrect;
    });

    if (isCorrect) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _streak++;
        _pickNewCharacters();
      });
    } else {
      await _dbService.saveHighscore(_streak);
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _gameOver = true;
      });
    }
  }

  void _goToDetail(Character character) async {
    // Drugie zapytanie REST - pobierz szczegóły po ID
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    try {
      final detailed = await _apiService.getCharacterById(character.id);
      Navigator.pop(context); // zamknij loading
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterDetailScreen(character: detailed),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // zamknij loading
      // Jeśli błąd - użyj danych które już mamy
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterDetailScreen(character: character),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _buildGameOver();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Streak: $_streak 🔥',
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Kto jest silniejszy?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Postać 1 - GÓRA
          Expanded(
            child: _buildCharacterCard(_character1, 0),
          ),
          // VS w środku
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Postać 2 - DÓŁ
          Expanded(
            child: _buildCharacterCard(_character2, 1),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(Character character, int index) {
    Color borderColor = Colors.white24;
    if (_answered && _selectedIndex == index) {
      borderColor = _wasCorrect ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () => _onChoose(index),
      onLongPress: () => _goToDetail(character),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Row(
          children: [
            // Zdjęcie po lewej
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(13),
              ),
              child: SizedBox(
                width: 120,
                height: double.infinity,
                child: Image.network(
                  character.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            // Info po prawej
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.race,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    if (_answered) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Ki: ${character.ki}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'przytrzymaj aby zobaczyć szczegóły',
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Ikona wyniku
            if (_answered && _selectedIndex == index)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  _wasCorrect ? Icons.check_circle : Icons.cancel,
                  color: _wasCorrect ? Colors.green : Colors.red,
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '💀 GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Twój wynik: $_streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _streak = 0;
                      _gameOver = false;
                      _pickNewCharacters();
                    });
                  },
                  child: const Text(
                    'ZAGRAJ PONOWNIE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'MENU GŁÓWNE',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}