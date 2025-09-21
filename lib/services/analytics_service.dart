import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;

class AnalyticsService {
  static const _analyticsKey = 'travel_analytics';

  static Future<TravelAnalytics> getTravelAnalytics() async {
    try {
      final analyticsJson = html.window.localStorage[_analyticsKey];
      if (analyticsJson != null) {
        return TravelAnalytics.fromJson(json.decode(analyticsJson));
      }
    } catch (e) {
      print('Error reading analytics: $e');
    }
    return TravelAnalytics.empty();
  }

  static Future<void> trackTrip(TripData trip) async {
    final analytics = await getTravelAnalytics();
    analytics.trips.add(trip);
    analytics.totalSpent += trip.totalCost;
    analytics.totalTrips++;
    
    html.window.localStorage[_analyticsKey] = json.encode(analytics.toJson());
  }

  static Future<PriceAnalytics> getPriceAnalytics(String destination) async {
    // Mock predictive analytics
    final random = Random();
    final basePrice = 15000 + random.nextInt(20000);
    
    return PriceAnalytics(
      destination: destination,
      currentPrice: basePrice.toDouble(),
      predictedPrice: basePrice * (0.85 + random.nextDouble() * 0.3),
      priceHistory: List.generate(30, (index) => 
        PricePoint(
          date: DateTime.now().subtract(Duration(days: 29 - index)),
          price: basePrice * (0.8 + random.nextDouble() * 0.4),
        )
      ),
      bestTimeToBook: DateTime.now().add(Duration(days: 7 + random.nextInt(14))),
      confidence: 0.75 + random.nextDouble() * 0.2,
    );
  }

  static Future<CarbonFootprint> calculateCarbonFootprint(TripData trip) async {
    double totalEmissions = 0;
    
    // Calculate transport emissions
    switch (trip.transportMode) {
      case 'flight':
        totalEmissions += trip.distance * 0.255; // kg CO2 per km
        break;
      case 'train':
        totalEmissions += trip.distance * 0.041;
        break;
      case 'bus':
        totalEmissions += trip.distance * 0.089;
        break;
      case 'car':
        totalEmissions += trip.distance * 0.171;
        break;
    }
    
    // Add accommodation emissions
    totalEmissions += trip.nights * 30; // kg CO2 per night
    
    // Add activity emissions
    totalEmissions += trip.activities.length * 5; // kg CO2 per activity
    
    return CarbonFootprint(
      totalEmissions: totalEmissions,
      transportEmissions: totalEmissions * 0.7,
      accommodationEmissions: totalEmissions * 0.2,
      activityEmissions: totalEmissions * 0.1,
      offsetCost: totalEmissions * 0.02, // $0.02 per kg CO2
      recommendations: _getCarbonRecommendations(trip),
    );
  }

  static List<String> _getCarbonRecommendations(TripData trip) {
    final recommendations = <String>[];
    
    if (trip.transportMode == 'flight') {
      recommendations.add('Consider train travel to reduce emissions by 85%');
    }
    
    if (trip.nights > 7) {
      recommendations.add('Choose eco-certified accommodations');
    }
    
    recommendations.add('Offset your carbon footprint for ₹${(trip.distance * 0.255 * 0.02 * 75).toInt()}');
    
    return recommendations;
  }

  static Future<BudgetAnalytics> getBudgetAnalytics() async {
    final analytics = await getTravelAnalytics();
    
    if (analytics.trips.isEmpty) {
      return BudgetAnalytics.empty();
    }
    
    final totalSpent = analytics.trips.fold(0.0, (sum, trip) => sum + trip.totalCost);
    final avgTripCost = totalSpent / analytics.trips.length;
    
    final categorySpending = <String, double>{};
    for (final trip in analytics.trips) {
      categorySpending['accommodation'] = (categorySpending['accommodation'] ?? 0) + trip.accommodationCost;
      categorySpending['transport'] = (categorySpending['transport'] ?? 0) + trip.transportCost;
      categorySpending['food'] = (categorySpending['food'] ?? 0) + trip.foodCost;
      categorySpending['activities'] = (categorySpending['activities'] ?? 0) + trip.activitiesCost;
    }
    
    return BudgetAnalytics(
      totalSpent: totalSpent,
      averageTripCost: avgTripCost,
      categoryBreakdown: categorySpending,
      monthlySpending: _calculateMonthlySpending(analytics.trips),
      savingsOpportunities: _identifySavingsOpportunities(analytics.trips),
    );
  }

  static Map<String, double> _calculateMonthlySpending(List<TripData> trips) {
    final monthlySpending = <String, double>{};
    
    for (final trip in trips) {
      final monthKey = '${trip.startDate.year}-${trip.startDate.month.toString().padLeft(2, '0')}';
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + trip.totalCost;
    }
    
    return monthlySpending;
  }

  static List<SavingsOpportunity> _identifySavingsOpportunities(List<TripData> trips) {
    final opportunities = <SavingsOpportunity>[];
    
    if (trips.length >= 3) {
      final avgAccommodationCost = trips.fold(0.0, (sum, trip) => sum + trip.accommodationCost) / trips.length;
      if (avgAccommodationCost > 5000) {
        opportunities.add(SavingsOpportunity(
          category: 'Accommodation',
          description: 'Consider budget hotels or homestays',
          potentialSavings: avgAccommodationCost * 0.3,
        ));
      }
      
      final avgTransportCost = trips.fold(0.0, (sum, trip) => sum + trip.transportCost) / trips.length;
      if (avgTransportCost > 8000) {
        opportunities.add(SavingsOpportunity(
          category: 'Transport',
          description: 'Book flights in advance or use trains',
          potentialSavings: avgTransportCost * 0.25,
        ));
      }
    }
    
    return opportunities;
  }
}

class TravelAnalytics {
  final List<TripData> trips;
  double totalSpent;
  int totalTrips;
  final DateTime lastUpdated;

  TravelAnalytics({
    required this.trips,
    required this.totalSpent,
    required this.totalTrips,
    required this.lastUpdated,
  });

  factory TravelAnalytics.empty() {
    return TravelAnalytics(
      trips: [],
      totalSpent: 0,
      totalTrips: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory TravelAnalytics.fromJson(Map<String, dynamic> json) {
    return TravelAnalytics(
      trips: (json['trips'] as List).map((t) => TripData.fromJson(t)).toList(),
      totalSpent: json['totalSpent'].toDouble(),
      totalTrips: json['totalTrips'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trips': trips.map((t) => t.toJson()).toList(),
      'totalSpent': totalSpent,
      'totalTrips': totalTrips,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class TripData {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final double accommodationCost;
  final double transportCost;
  final double foodCost;
  final double activitiesCost;
  final String transportMode;
  final double distance;
  final int nights;
  final List<String> activities;

  TripData({
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    required this.accommodationCost,
    required this.transportCost,
    required this.foodCost,
    required this.activitiesCost,
    required this.transportMode,
    required this.distance,
    required this.nights,
    required this.activities,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      destination: json['destination'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalCost: json['totalCost'].toDouble(),
      accommodationCost: json['accommodationCost'].toDouble(),
      transportCost: json['transportCost'].toDouble(),
      foodCost: json['foodCost'].toDouble(),
      activitiesCost: json['activitiesCost'].toDouble(),
      transportMode: json['transportMode'],
      distance: json['distance'].toDouble(),
      nights: json['nights'],
      activities: List<String>.from(json['activities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCost': totalCost,
      'accommodationCost': accommodationCost,
      'transportCost': transportCost,
      'foodCost': foodCost,
      'activitiesCost': activitiesCost,
      'transportMode': transportMode,
      'distance': distance,
      'nights': nights,
      'activities': activities,
    };
  }
}

class PriceAnalytics {
  final String destination;
  final double currentPrice;
  final double predictedPrice;
  final List<PricePoint> priceHistory;
  final DateTime bestTimeToBook;
  final double confidence;

  PriceAnalytics({
    required this.destination,
    required this.currentPrice,
    required this.predictedPrice,
    required this.priceHistory,
    required this.bestTimeToBook,
    required this.confidence,
  });
}

class PricePoint {
  final DateTime date;
  final double price;

  PricePoint({required this.date, required this.price});
}

class CarbonFootprint {
  final double totalEmissions;
  final double transportEmissions;
  final double accommodationEmissions;
  final double activityEmissions;
  final double offsetCost;
  final List<String> recommendations;

  CarbonFootprint({
    required this.totalEmissions,
    required this.transportEmissions,
    required this.accommodationEmissions,
    required this.activityEmissions,
    required this.offsetCost,
    required this.recommendations,
  });
}

class BudgetAnalytics {
  final double totalSpent;
  final double averageTripCost;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> monthlySpending;
  final List<SavingsOpportunity> savingsOpportunities;

  BudgetAnalytics({
    required this.totalSpent,
    required this.averageTripCost,
    required this.categoryBreakdown,
    required this.monthlySpending,
    required this.savingsOpportunities,
  });

  factory BudgetAnalytics.empty() {
    return BudgetAnalytics(
      totalSpent: 0,
      averageTripCost: 0,
      categoryBreakdown: {},
      monthlySpending: {},
      savingsOpportunities: [],
    );
  }
}

class SavingsOpportunity {
  final String category;
  final String description;
  final double potentialSavings;

  SavingsOpportunity({
    required this.category,
    required this.description,
    required this.potentialSavings,
  });
}