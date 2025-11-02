class BookingRequest {
  final String itineraryId;
  final String userName;
  final String email;
  final String phone;
  final String paymentMethod;
  final double amount;

  BookingRequest({
    required this.itineraryId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.paymentMethod,
    required this.amount,
  });
}

class BookingResult {
  final bool success;
  final String bookingId;
  final String message;
  final DateTime timestamp;

  BookingResult({
    required this.success,
    required this.bookingId,
    required this.message,
    required this.timestamp,
  });
}

class Booking {
  final String id;
  final String itineraryId;
  final String userName;
  final String email;
  final double amount;
  final DateTime timestamp;

  Booking({
    required this.id,
    required this.itineraryId,
    required this.userName,
    required this.email,
    required this.amount,
    required this.timestamp,
  });
}
