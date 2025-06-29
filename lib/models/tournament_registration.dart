class TournamentRegistration {
  final int registrationId;
  final int tournamentId;
  final String tournamentName;
  final int userId;
  final String userName;
  final DateTime registrationDate;

  TournamentRegistration({
    required this.registrationId,
    required this.tournamentId,
    required this.tournamentName,
    required this.userId,
    required this.userName,
    required this.registrationDate,
  });

  factory TournamentRegistration.fromJson(Map<String, dynamic> json) {
    return TournamentRegistration(
      registrationId: json['registrationId'],
      tournamentId: json['tournamentId'],
      tournamentName: json['tournamentName'] ?? '',
      userId: json['userId'],
      userName: json['userName'] ?? '',
      registrationDate: DateTime.parse(json['registrationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'tournamentId': tournamentId,
      'userId': userId,
    };
    
    print('TournamentRegistration to JSON: $json');
    return json;
  }

  @override
  String toString() {
    return 'TournamentRegistration(id: $registrationId, tournament: $tournamentName, user: $userName, date: $registrationDate)';
  }
}