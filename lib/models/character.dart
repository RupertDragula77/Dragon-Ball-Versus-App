class Character {
  final int id;
  final String name;
  final String ki;
  final String maxKi;
  final String race;
  final String gender;
  final String description;
  final String image;
  final String affiliation;

  Character({
    required this.id,
    required this.name,
    required this.ki,
    required this.maxKi,
    required this.race,
    required this.gender,
    required this.description,
    required this.image,
    required this.affiliation,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      ki: json['ki'] ?? '0',
      maxKi: json['maxKi'] ?? '0',
      race: json['race'] ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      affiliation: json['affiliation'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ki': ki,
      'maxKi': maxKi,
      'race': race,
      'gender': gender,
      'description': description,
      'image': image,
      'affiliation': affiliation,
    };
  }

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'],
      name: map['name'],
      ki: map['ki'],
      maxKi: map['maxKi'],
      race: map['race'],
      gender: map['gender'],
      description: map['description'],
      image: map['image'],
      affiliation: map['affiliation'],
    );
  }

  // Zamienia ki na liczbę do porównania
  double get kiValue {
    String cleaned = ki
        .toLowerCase()
        .replaceAll(',', '')
        .replaceAll('.', '')
        .trim();

    // Obsługa "unknown"
    if (cleaned == 'unknown' || cleaned == '') return 0;

    // Obsługa słownych wartości
    final multipliers = {
      'googolplex': 1e100,
      'septillion': 1e24,
      'sextillion': 1e21,
      'quintillion': 1e18,
      'quadrillion': 1e15,
      'trillion': 1e12,
      'billion': 1e9,
      'million': 1e6,
    };

    for (var entry in multipliers.entries) {
      if (cleaned.contains(entry.key)) {
        String numPart = cleaned.replaceAll(entry.key, '').trim();
        double? num = double.tryParse(numPart);
        if (num != null) return num * entry.value;
      }
    }

    return double.tryParse(cleaned) ?? 0;
  }
}