class Tournament {
  final int? tournamentId;
  final String name;
  final String category;
  final DateTime registrationStartDate;
  final DateTime registrationEndDate;
  final DateTime tournamentStartDate;
  final DateTime tournamentEndDate;
  final int maxPlayers;
  final int createdBy;

  Tournament({
    this.tournamentId,
    required this.name,
    required this.category,
    required this.registrationStartDate,
    required this.registrationEndDate,
    required this.tournamentStartDate,
    required this.tournamentEndDate,
    required this.maxPlayers,
    required this.createdBy,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    print('Parsing tournament JSON: $json');
    
    try {
      return Tournament(
        tournamentId: json['tournamentId'] ?? json['id'],
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        registrationStartDate: DateTime.parse(json['registrationStartDate']),
        registrationEndDate: DateTime.parse(json['registrationEndDate']),
        tournamentStartDate: DateTime.parse(json['tournamentStartDate']),
        tournamentEndDate: DateTime.parse(json['tournamentEndDate']),
        maxPlayers: json['maxPlayers'] ?? json['maxPlayers'] ?? 0,
        createdBy: json['createdBy'] ?? 0,
      );
    } catch (e) {
      print('Error parsing tournament JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'category': category,
      'registrationStartDate': registrationStartDate.toIso8601String().split('T')[0],
      'registrationEndDate': registrationEndDate.toIso8601String().split('T')[0],
      'tournamentStartDate': tournamentStartDate.toIso8601String().split('T')[0],
      'tournamentEndDate': tournamentEndDate.toIso8601String().split('T')[0],
      'maxPlayers': maxPlayers,
      'createdBy': createdBy,
    };
    
    print('Tournament to JSON: $json');
    return json;
  }

  @override
  String toString() {
    return 'Tournament(id: $tournamentId, name: $name, category: $category, maxPlayers: $maxPlayers)';
  }
} 