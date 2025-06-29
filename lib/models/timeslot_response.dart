class TimeslotResponse {
  final int timeslotId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String courtName;

  TimeslotResponse({
    required this.timeslotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.courtName
  });

  factory TimeslotResponse.fromJson(Map<String, dynamic> json) {
    return TimeslotResponse(
      timeslotId: json['timeslotId'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      courtName: json['courtName']
    );
  }
}