import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../models/hotel.dart';
import '../models/booking.dart';
import '../utils/cache_manager.dart';
import '../utils/destination_images.dart';

class MockDataProvider extends ChangeNotifier {
  String? _selectedItineraryId;
  final List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, String>> heroSlides() {
    return [
      {'title': 'Explore Goa', 'subtitle': 'Sun, sand, and endless beaches', 'imageUrl': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=1200', 'destination': 'Goa'},
      {'title': 'Unwind in Kerala', 'subtitle': 'Backwaters and serene landscapes', 'imageUrl': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=1200', 'destination': 'Kerala'},
      {'title': 'Royal Rajasthan', 'subtitle': 'Land of Kings and Palaces', 'imageUrl': 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=1200', 'destination': 'Rajasthan'},
      {'title': 'Vibrant Mumbai', 'subtitle': 'The city that never sleeps', 'imageUrl': 'https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?w=1200', 'destination': 'Mumbai'},
      {'title': 'Historic Delhi', 'subtitle': 'Capital of incredible India', 'imageUrl': 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=1200', 'destination': 'Delhi'},
      {'title': 'Himachal Pradesh', 'subtitle': 'Adventure in the Himalayas', 'imageUrl': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=1200', 'destination': 'Himachal'},
      {'title': 'Serene Uttarakhand', 'subtitle': 'Land of Gods and Mountains', 'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200', 'destination': 'Uttarakhand'},
      {'title': 'Exotic Andaman', 'subtitle': 'Tropical paradise islands', 'imageUrl': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200', 'destination': 'Andaman'},
      {'title': 'Majestic Ladakh', 'subtitle': 'Land of High Passes', 'imageUrl': 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=1200', 'destination': 'Ladakh'},
      {'title': 'Tamil Nadu', 'subtitle': 'Temples and rich culture', 'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200', 'destination': 'Tamil Nadu'},
      {'title': 'Karnataka', 'subtitle': 'Garden city and heritage', 'imageUrl': 'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=1200', 'destination': 'Karnataka'},
      {'title': 'Historic Agra', 'subtitle': 'Home of the Taj Mahal', 'imageUrl': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=1200', 'destination': 'Agra'},
      {'title': 'Assam', 'subtitle': 'Tea gardens and nightlife', 'imageUrl': 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=1200', 'destination': 'Assam'},
    ];
  }

  /// Generate mock itineraries with destination-specific images
  /// Uses DestinationImages utility to ensure correct image mapping
  /// Each trip card displays an image relevant to the destination
  List<Itinerary> mockItineraries() {
    final fromCities = ['Bangalore', 'Chennai', 'Hyderabad', 'Pune', 'Kolkata', 'Ahmedabad', 'Jaipur', 'Lucknow', 'Chandigarh', 'Indore', 'Bhopal', 'Patna', 'Surat'];
    return [
      Itinerary(
        id: 'itin_1',
        destination: 'Goa',
        days: 5,
        totalCost: 25000,
        imageUrl: DestinationImages.getDestinationImage('Goa'),
        rating: 4.9,
        fromCity: fromCities[0],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Beach Day',
            activities: [
              Activity(
                id: 'act_1',
                title: 'Baga Beach',
                time: '9:00 AM',
                cost: 0,
                rating: 4.5,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
                lat: 15.5557,
                lng: 73.7516,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_2',
        destination: 'Kerala',
        days: 6,
        totalCost: 30000,
        imageUrl: DestinationImages.getDestinationImage('Kerala'),
        rating: 4.9,
        fromCity: fromCities[1],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Backwaters Tour',
            activities: [
              Activity(
                id: 'act_3',
                title: 'Alleppey Houseboat',
                time: '10:00 AM',
                cost: 5000,
                rating: 4.9,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?w=400',
                lat: 9.4981,
                lng: 76.3388,
              ),
            ],
          ),
        ],
      ),
      // Hyderabad → Rajasthan trip with correct Rajasthan image (Hawa Mahal)
      Itinerary(
        id: 'itin_3',
        destination: 'Rajasthan',
        days: 5,
        totalCost: 22000,
        imageUrl: DestinationImages.getDestinationImage('Rajasthan'),
        rating: 4.8,
        fromCity: fromCities[2],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Palace Tour',
            activities: [
              Activity(
                id: 'act_4',
                title: 'City Palace',
                time: '9:00 AM',
                cost: 600,
                rating: 4.8,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&q=80',
                lat: 24.5761,
                lng: 73.6833,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_4',
        destination: 'Kashmir',
        days: 6,
        totalCost: 32000,
        imageUrl: DestinationImages.getDestinationImage('Kashmir'),
        rating: 4.9,
        fromCity: fromCities[3],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Dal Lake & Shikara Ride',
            activities: [
              Activity(
                id: 'act_5',
                title: 'Dal Lake',
                time: '9:00 AM',
                cost: 500,
                rating: 4.9,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                lat: 34.0836,
                lng: 74.7973,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_5',
        destination: 'Delhi',
        days: 3,
        totalCost: 18000,
        imageUrl: DestinationImages.getDestinationImage('Delhi'),
        rating: 4.7,
        fromCity: fromCities[4],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Historical Tour',
            activities: [
              Activity(
                id: 'act_6',
                title: 'Red Fort',
                time: '9:00 AM',
                cost: 500,
                rating: 4.8,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400',
                lat: 28.6562,
                lng: 77.2410,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_6',
        destination: 'Himachal',
        days: 5,
        totalCost: 20000,
        imageUrl: DestinationImages.getDestinationImage('Himachal'),
        rating: 4.8,
        fromCity: fromCities[5],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Mountain Adventure',
            activities: [
              Activity(
                id: 'act_7',
                title: 'Rohtang Pass',
                time: '8:00 AM',
                cost: 1500,
                rating: 4.8,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=400',
                lat: 32.2432,
                lng: 77.1892,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_7',
        destination: 'Uttarakhand',
        days: 4,
        totalCost: 16000,
        imageUrl: DestinationImages.getDestinationImage('Uttarakhand'),
        rating: 4.8,
        fromCity: fromCities[6],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'River Rafting',
            activities: [
              Activity(
                id: 'act_8',
                title: 'White Water Rafting',
                time: '8:00 AM',
                cost: 1500,
                rating: 4.9,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
                lat: 30.0869,
                lng: 78.2676,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_8',
        destination: 'Andaman',
        days: 5,
        totalCost: 35000,
        imageUrl: DestinationImages.getDestinationImage('Andaman'),
        rating: 4.9,
        fromCity: fromCities[7],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Beach & Snorkeling',
            activities: [
              Activity(
                id: 'act_9',
                title: 'Radhanagar Beach',
                time: '10:00 AM',
                cost: 0,
                rating: 5.0,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
                lat: 11.9416,
                lng: 92.9093,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_9',
        destination: 'Ladakh',
        days: 6,
        totalCost: 28000,
        imageUrl: DestinationImages.getDestinationImage('Ladakh'),
        rating: 4.9,
        fromCity: fromCities[8],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'High Altitude Adventure',
            activities: [
              Activity(
                id: 'act_10',
                title: 'Pangong Lake',
                time: '8:00 AM',
                cost: 2000,
                rating: 5.0,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                lat: 33.7782,
                lng: 78.6569,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_10',
        destination: 'Tamil Nadu',
        days: 4,
        totalCost: 18000,
        imageUrl: DestinationImages.getDestinationImage('Tamil Nadu'),
        rating: 4.7,
        fromCity: fromCities[9],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Temple Tour',
            activities: [
              Activity(
                id: 'act_11',
                title: 'Meenakshi Temple',
                time: '9:00 AM',
                cost: 500,
                rating: 4.8,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=400',
                lat: 9.9195,
                lng: 78.1193,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_11',
        destination: 'Karnataka',
        days: 4,
        totalCost: 19000,
        imageUrl: DestinationImages.getDestinationImage('Karnataka'),
        rating: 4.7,
        fromCity: fromCities[10],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Palace Tour',
            activities: [
              Activity(
                id: 'act_12',
                title: 'Mysore Palace',
                time: '10:00 AM',
                cost: 500,
                rating: 4.8,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=400',
                lat: 12.3051,
                lng: 76.6551,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_12',
        destination: 'Agra',
        days: 2,
        totalCost: 10000,
        imageUrl: DestinationImages.getDestinationImage('Agra'),
        rating: 4.9,
        fromCity: fromCities[11],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Taj Mahal Visit',
            activities: [
              Activity(
                id: 'act_13',
                title: 'Taj Mahal',
                time: '6:00 AM',
                cost: 1000,
                rating: 5.0,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=400',
                lat: 27.1751,
                lng: 78.0421,
              ),
            ],
          ),
        ],
      ),
      Itinerary(
        id: 'itin_13',
        destination: 'Assam',
        days: 4,
        totalCost: 17000,
        imageUrl: DestinationImages.getDestinationImage('Assam'),
        rating: 4.7,
        fromCity: fromCities[12],
        dayPlans: [
          DayPlan(
            day: 1,
            title: 'Tea Gardens & Nightlife',
            activities: [
              Activity(
                id: 'act_14',
                title: 'Tea Estate Tour',
                time: '9:00 AM',
                cost: 800,
                rating: 4.7,
                type: 'attraction',
                imageUrl: 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=400',
                lat: 26.2006,
                lng: 92.9376,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Mock hotel data for all major destinations
  /// To replace with live API: Call your hotel booking API endpoint
  /// Example: final response = await http.get('https://api.example.com/hotels?city=$destination');
  List<Hotel> mockHotels(String destination) {
    final hotelsByCity = {
      'Goa': [
        Hotel(id: 'hotel_1', name: 'Taj Exotica', destination: 'Goa', pricePerNight: 12000, rating: 4.8, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Beach Access', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_2', name: 'The Leela Goa', destination: 'Goa', pricePerNight: 10500, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Beach View', 'Pool', 'WiFi', 'Breakfast']),
        Hotel(id: 'hotel_3', name: 'Grand Hyatt Goa', destination: 'Goa', pricePerNight: 9500, rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Pool', 'Gym', 'Restaurant', 'WiFi']),
      ],
      'Kerala': [
        Hotel(id: 'hotel_4', name: 'Kumarakom Lake Resort', destination: 'Kerala', pricePerNight: 10000, rating: 4.9, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Lake View', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_5', name: 'Vivanta by Taj', destination: 'Kerala', pricePerNight: 8500, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Backwater View', 'Pool', 'WiFi', 'Spa']),
        Hotel(id: 'hotel_6', name: 'Coconut Lagoon', destination: 'Kerala', pricePerNight: 7500, rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Heritage Property', 'Pool', 'Restaurant']),
      ],
      'Rajasthan': [
        Hotel(id: 'hotel_7', name: 'Taj Lake Palace', destination: 'Rajasthan', pricePerNight: 15000, rating: 4.9, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Lake View', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_8', name: 'The Oberoi Udaivilas', destination: 'Rajasthan', pricePerNight: 18000, rating: 5.0, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Palace View', 'Pool', 'Spa', 'WiFi']),
        Hotel(id: 'hotel_9', name: 'Rambagh Palace', destination: 'Rajasthan', pricePerNight: 14000, rating: 4.8, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Heritage', 'Pool', 'Restaurant', 'WiFi']),
      ],
      'Mumbai': [
        Hotel(id: 'hotel_10', name: 'Taj Mahal Palace', destination: 'Mumbai', pricePerNight: 18000, rating: 4.9, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Sea View', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_11', name: 'The Oberoi Mumbai', destination: 'Mumbai', pricePerNight: 16000, rating: 4.8, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['City View', 'Pool', 'Gym', 'WiFi']),
        Hotel(id: 'hotel_12', name: 'Trident Nariman Point', destination: 'Mumbai', pricePerNight: 12000, rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Business Center', 'Pool', 'Restaurant']),
      ],
      'Delhi': [
        Hotel(id: 'hotel_13', name: 'The Imperial', destination: 'Delhi', pricePerNight: 14000, rating: 4.8, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Heritage', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_14', name: 'The Leela Palace', destination: 'Delhi', pricePerNight: 16000, rating: 4.9, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Luxury', 'Pool', 'Spa', 'WiFi']),
        Hotel(id: 'hotel_15', name: 'Taj Palace', destination: 'Delhi', pricePerNight: 12000, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Garden View', 'Pool', 'Restaurant']),
      ],
      'Himachal': [
        Hotel(id: 'hotel_16', name: 'The Himalayan', destination: 'Himachal', pricePerNight: 8000, rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80', amenities: ['Mountain View', 'Restaurant', 'WiFi']),
        Hotel(id: 'hotel_17', name: 'Wildflower Hall', destination: 'Himachal', pricePerNight: 12000, rating: 4.8, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Valley View', 'Spa', 'Restaurant', 'WiFi']),
        Hotel(id: 'hotel_18', name: 'The Oberoi Cecil', destination: 'Himachal', pricePerNight: 10000, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Heritage', 'Restaurant', 'WiFi']),
      ],
      'Bangalore': [
        Hotel(id: 'hotel_19', name: 'The Oberoi Bangalore', destination: 'Bangalore', pricePerNight: 11000, rating: 4.8, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['City View', 'Pool', 'Spa', 'WiFi']),
        Hotel(id: 'hotel_20', name: 'Taj West End', destination: 'Bangalore', pricePerNight: 10000, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Garden', 'Pool', 'Restaurant', 'WiFi']),
        Hotel(id: 'hotel_21', name: 'ITC Gardenia', destination: 'Bangalore', pricePerNight: 9000, rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Business Center', 'Pool', 'Gym']),
      ],
      'Jaipur': [
        Hotel(id: 'hotel_22', name: 'Rambagh Palace', destination: 'Jaipur', pricePerNight: 15000, rating: 4.9, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Palace', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_23', name: 'The Oberoi Rajvilas', destination: 'Jaipur', pricePerNight: 17000, rating: 5.0, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Luxury', 'Pool', 'Spa', 'WiFi']),
        Hotel(id: 'hotel_24', name: 'Fairmont Jaipur', destination: 'Jaipur', pricePerNight: 12000, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Pool', 'Spa', 'Restaurant', 'WiFi']),
      ],
      'Agra': [
        Hotel(id: 'hotel_25', name: 'The Oberoi Amarvilas', destination: 'Agra', pricePerNight: 20000, rating: 5.0, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Taj View', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_26', name: 'ITC Mughal', destination: 'Agra', pricePerNight: 12000, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Garden', 'Pool', 'Spa', 'WiFi']),
        Hotel(id: 'hotel_27', name: 'Taj Hotel & Convention Centre', destination: 'Agra', pricePerNight: 9000, rating: 4.5, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Pool', 'Restaurant', 'WiFi']),
      ],
      'Hyderabad': [
        Hotel(id: 'hotel_28', name: 'Taj Falaknuma Palace', destination: 'Hyderabad', pricePerNight: 25000, rating: 5.0, imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80', amenities: ['Palace', 'Pool', 'Spa', 'Restaurant']),
        Hotel(id: 'hotel_29', name: 'ITC Kohenur', destination: 'Hyderabad', pricePerNight: 11000, rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80', amenities: ['Luxury', 'Pool', 'Spa', 'WiFi']),
        Hotel(id: 'hotel_30', name: 'Trident Hyderabad', destination: 'Hyderabad', pricePerNight: 8500, rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80', amenities: ['Business Center', 'Pool', 'Restaurant']),
      ],
    };

    return hotelsByCity[destination] ?? [];
  }

  Future<BookingResult> simulateBooking(BookingRequest req) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    
    final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final booking = Booking(
      id: bookingId,
      itineraryId: req.itineraryId,
      userName: req.userName,
      email: req.email,
      amount: req.amount,
      timestamp: DateTime.now(),
    );
    
    _bookings.add(booking);
    _isLoading = false;
    notifyListeners();
    
    return BookingResult(
      success: true,
      bookingId: bookingId,
      message: 'Booking confirmed successfully!',
      timestamp: DateTime.now(),
    );
  }

  Future<List<Hotel>> fetchHotels(String destination) async {
    final cacheKey = 'hotels_$destination';
    final cached = CacheManager().get<List<Hotel>>(cacheKey);
    
    if (cached != null) {
      return cached;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final hotels = mockHotels(destination);
      CacheManager().set(cacheKey, hotels, const Duration(minutes: 10));
      _isLoading = false;
      notifyListeners();
      return hotels;
    } catch (e) {
      _error = 'Failed to load hotels';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Itinerary>> fetchItineraries() async {
    const cacheKey = 'itineraries';
    final cached = CacheManager().get<List<Itinerary>>(cacheKey);
    
    if (cached != null) {
      return cached;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final itineraries = mockItineraries();
      CacheManager().set(cacheKey, itineraries, const Duration(minutes: 30));
      _isLoading = false;
      notifyListeners();
      return itineraries;
    } catch (e) {
      _error = 'Failed to load itineraries';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void selectItinerary(String itineraryId) {
    _selectedItineraryId = itineraryId;
    notifyListeners();
  }

  Itinerary? getSelectedItinerary() {
    if (_selectedItineraryId == null) return null;
    try {
      return mockItineraries().firstWhere((i) => i.id == _selectedItineraryId);
    } catch (e) {
      return null;
    }
  }

  void saveBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  List<Booking> getBookings() => List.unmodifiable(_bookings);

  void clearSelection() {
    _selectedItineraryId = null;
    notifyListeners();
  }
}
