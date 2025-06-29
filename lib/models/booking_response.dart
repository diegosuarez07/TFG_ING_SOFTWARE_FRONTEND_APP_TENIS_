class BookingResponse {
  final int bookingId;
  final int userId;
  final int timeslotId;
  final String bookingDate;
  final String status;
  final String date;
  final String startTime;
  final String endTime;
  final String courtName;
  final String courtNumber;

  BookingResponse({
    required this.bookingId,
    required this.userId,
    required this.timeslotId,
    required this.bookingDate,
    required this.status,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.courtName,
    required this.courtNumber,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      bookingId: json['bookingId'],
      userId: json['userId'],
      timeslotId: json['timeslotId'],
      bookingDate: json['bookingDate'],
      status: json['status'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      courtName: json['courtName'],
      courtNumber: json['courtNumber'],
    );
  }
}