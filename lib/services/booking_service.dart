import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  // Amadeus API for flights
  static const String _amadeusApiKey = 'YOUR_AMADEUS_API_KEY';
  static const String _amadeusSecret = 'YOUR_AMADEUS_SECRET';
  static const String _amadeusBaseUrl = 'https://test.api.amadeus.com/v2';
  
  // Booking.com API for hotels
  static const String _bookingApiKey = 'YOUR_BOOKING_API_KEY';
  static const String _bookingBaseUrl = 'https://distribution-xml.booking.com/json/bookings';
  
  static const Duration _timeout = Duration(seconds: 15);

  // Flight Search
  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    int adults = 1,
  }) async {
    try {
      final token = await _getAmadeusToken();
      if (token == null) throw BookingException('Authentication failed');

      final queryParams = {
        'originLocationCode': origin,
        'destinationLocationCode': destination,
        'departureDate': departureDate.toIso8601String().split('T')[0],
        'adults': adults.toString(),
        if (returnDate != null) 'returnDate': returnDate.toIso8601String().split('T')[0],
      };

      final uri = Uri.parse('$_amadeusBaseUrl/shopping/flight-offers').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((flight) => FlightOffer.fromAmadeusJson(flight))
            .toList();
      } else {
        throw BookingException('Flight search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is BookingException) rethrow;
      // Return mock data for demo
      return _getMockFlights(origin, destination, departureDate);
    }
  }

  // Hotel Search
  Future<List<HotelOffer>> searchHotels({
    required String cityCode,
    required DateTime checkIn,
    required DateTime checkOut,
    int adults = 2,
    int rooms = 1,
  }) async {
    try {
      final token = await _getAmadeusToken();
      if (token == null) throw BookingException('Authentication failed');

      final queryParams = {
        'cityCode': cityCode,
        'checkInDate': checkIn.toIso8601String().split('T')[0],
        'checkOutDate': checkOut.toIso8601String().split('T')[0],
        'adults': adults.toString(),
        'roomQuantity': rooms.toString(),
      };

      final uri = Uri.parse('$_amadeusBaseUrl/shopping/hotel-offers').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((hotel) => HotelOffer.fromAmadeusJson(hotel))
            .toList();
      } else {
        throw BookingException('Hotel search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is BookingException) rethrow;
      // Return mock data for demo
      return _getMockHotels(cityCode, checkIn, checkOut);
    }
  }

  Future<String?> _getAmadeusToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://test.api.amadeus.com/v1/security/oauth2/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': _amadeusApiKey,
          'client_secret': _amadeusSecret,
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
    } catch (e) {
      print('Token error: $e');
    }
    return null;
  }

  List<FlightOffer> _getMockFlights(String origin, String destination, DateTime date) {
    return [
      FlightOffer(
        id: 'FL001',
        airline: 'IndiGo',
        flightNumber: '6E 123',
        origin: origin,
        destination: destination,
        departureTime: date.add(const Duration(hours: 8)),
        arrivalTime: date.add(const Duration(hours: 10, minutes: 30)),
        price: 4500,
        currency: 'INR',
        duration: '2h 30m',
        stops: 0,
      ),
      FlightOffer(
        id: 'FL002',
        airline: 'Air India',
        flightNumber: 'AI 456',
        origin: origin,
        destination: destination,
        departureTime: date.add(const Duration(hours: 14)),
        arrivalTime: date.add(const Duration(hours: 16, minutes: 45)),
        price: 5200,
        currency: 'INR',
        duration: '2h 45m',
        stops: 0,
      ),
    ];
  }

  List<HotelOffer> _getMockHotels(String city, DateTime checkIn, DateTime checkOut) {
    final nights = checkOut.difference(checkIn).inDays;
    return [
      HotelOffer(
        id: 'HT001',
        name: 'Grand Palace Hotel',
        rating: 4.5,
        address: 'City Center, $city',
        pricePerNight: 3500,
        totalPrice: 3500.0 * nights,
        currency: 'INR',
        amenities: ['WiFi', 'Pool', 'Spa', 'Restaurant'],
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      ),
      HotelOffer(
        id: 'HT002',
        name: 'Comfort Inn',
        rating: 4.0,
        address: 'Business District, $city',
        pricePerNight: 2200,
        totalPrice: 2200.0 * nights,
        currency: 'INR',
        amenities: ['WiFi', 'Breakfast', 'Gym'],
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa',
      ),
    ];
  }
}

class FlightOffer {
  final String id;
  final String airline;
  final String flightNumber;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final String currency;
  final String duration;
  final int stops;

  FlightOffer({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.currency,
    required this.duration,
    required this.stops,
  });

  factory FlightOffer.fromAmadeusJson(Map<String, dynamic> json) {
    final itinerary = json['itineraries'][0];
    final segment = itinerary['segments'][0];
    
    return FlightOffer(
      id: json['id'],
      airline: segment['carrierCode'],
      flightNumber: '${segment['carrierCode']} ${segment['number']}',
      origin: segment['departure']['iataCode'],
      destination: segment['arrival']['iataCode'],
      departureTime: DateTime.parse(segment['departure']['at']),
      arrivalTime: DateTime.parse(segment['arrival']['at']),
      price: double.parse(json['price']['total']),
      currency: json['price']['currency'],
      duration: itinerary['duration'],
      stops: itinerary['segments'].length - 1,
    );
  }
}

class HotelOffer {
  final String id;
  final String name;
  final double rating;
  final String address;
  final double pricePerNight;
  final double totalPrice;
  final String currency;
  final List<String> amenities;
  final String imageUrl;

  HotelOffer({
    required this.id,
    required this.name,
    required this.rating,
    required this.address,
    required this.pricePerNight,
    required this.totalPrice,
    required this.currency,
    required this.amenities,
    required this.imageUrl,
  });

  factory HotelOffer.fromAmadeusJson(Map<String, dynamic> json) {
    final hotel = json['hotel'];
    final offer = json['offers'][0];
    
    return HotelOffer(
      id: json['id'],
      name: hotel['name'],
      rating: hotel['rating']?.toDouble() ?? 0.0,
      address: hotel['address']['lines'].join(', '),
      pricePerNight: double.parse(offer['price']['total']),
      totalPrice: double.parse(offer['price']['total']),
      currency: offer['price']['currency'],
      amenities: (hotel['amenities'] as List?)?.cast<String>() ?? [],
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
    );
  }
}

class BookingException implements Exception {
  final String message;
  BookingException(this.message);
  
  @override
  String toString() => 'BookingException: $message';
}