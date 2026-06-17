import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/character.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  List<Character> _characters = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _bestScore = await _dbService.getBestHighscore();

    try {
      final characters = await _apiService.getCharacters();
      await _dbService.saveCharacters(characters);
      setState(() {
        _characters = characters;
        _isLoading = false;
      });
    } catch (e) {
      final cached = await _dbService.getCachedCharacters();
      if (cached.isNotEmpty) {
        setState(() {
          _characters = cached;
          _isLoading = false;
          _errorMessage = 'Brak internetu - dane z cache';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Brak internetu i brak danych w cache';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🐉 DRAGON BALL',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'VERSUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    '🏆 Najlepszy wynik: $_bestScore',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.orange)
                else if (_errorMessage != null && _characters.isEmpty)
                  Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Spróbuj ponownie'),
                      )
                    ],
                  )
                else
                  Column(
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
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
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    GameScreen(characters: _characters),
                              ),
                            );
                            _bestScore = await _dbService.getBestHighscore();
                            setState(() {});
                          },
                          child: const Text(
                            'ZAGRAJ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}