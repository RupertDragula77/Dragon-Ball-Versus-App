import 'package:flutter/material.dart';
import 'dart:math';
import '../models/character.dart';
import '../services/database_service.dart';
import 'character_detail_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Character> characters;

  const GameScreen({super.key, required this.characters});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final DatabaseService _dbService = DatabaseService();
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
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildCharacterCard(_character1, 0)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: _buildCharacterCard(_character2, 1)),
              ],
            ),
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
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CharacterDetailScreen(character: character),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13),
                ),
                child: Image.network(
                  character.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                character.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Ki: ${character.ki}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_answered && _selectedIndex == index)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(
                  _wasCorrect ? Icons.check_circle : Icons.cancel,
                  color: _wasCorrect ? Colors.green : Colors.red,
                  size: 32,
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