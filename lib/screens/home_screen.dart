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
  bool _isAnimating = false;

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
      final filtered = characters.where((c) =>
      c.ki.toLowerCase() != 'unknown' && c.ki != '0'
      ).toList();
      await _dbService.saveCharacters(filtered);
      setState(() {
        _characters = filtered;
        _isLoading = false;
      });
    } catch (e) {
      final cached = await _dbService.getCachedCharacters();
      final filtered = cached.where((c) =>
      c.ki.toLowerCase() != 'unknown' && c.ki != '0'
      ).toList();
      if (filtered.isNotEmpty) {
        setState(() {
          _characters = filtered;
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

  Future<void> _onPlayPressed() async {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    // Czekaj na animację
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isAnimating = false);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(characters: _characters),
        ),
      );
      _bestScore = await _dbService.getBestHighscore();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInBack,
                offset: _isAnimating
                    ? const Offset(0, -1.5)
                    : const Offset(0, 0),
                child: SizedBox(
                  height: screenHeight / 2,
                  width: screenWidth,
                  child: Image.asset(
                    'assets/images/piccolo.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Dolny gif - Vegeta - wysuwa się do dołu
              AnimatedSlide(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInBack,
                offset: _isAnimating
                    ? const Offset(0, 1.5)
                    : const Offset(0, 0),
                child: SizedBox(
                  height: screenHeight / 2,
                  width: screenWidth,
                  child: Image.asset(
                    'assets/images/vegeta.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          // Ciemna nakładka żeby tekst był czytelny
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),

          // UI na wierzchu gifów
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/applogo.png',
                      height: 120,
                    ),
                    const SizedBox(height: 8),
                    // Tytuł
                    const Text(
                      'VERSUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.orange,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Highscore
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
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
                    // Loading / Error / Przycisk
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
                              onPressed: _onPlayPressed,
                              child: Text(
                                _isAnimating ? '...' : 'ZAGRAJ',
                                style: const TextStyle(
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
        ],
      ),
    );
  }
}