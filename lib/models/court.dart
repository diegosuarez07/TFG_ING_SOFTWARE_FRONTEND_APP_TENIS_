class Court {
  final int courtId;
  final int courtNumber;
  final String courtName;
  final String surfaceType;
  final String status;

  Court({
    required this.courtId,
    required this.courtNumber,
    required this.courtName,
    required this.surfaceType,
    required this.status,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      courtId: json['courtId'],
      courtNumber: json['courtNumber'],
      courtName: json['courtName'],
      surfaceType: json['surfaceType'],
      status: json['status'],
    );
  }
}