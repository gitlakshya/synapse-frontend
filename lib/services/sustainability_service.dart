import 'package:flutter/material.dart';

class SustainabilityService {
  static SustainabilityScore calculateTripScore({
    required String transportMode,
    required int distance,
    required String accommodationType,
    required int nights,
    required List<String> activities,
  }) {
    double score = 100.0;
    List<String> recommendations = [];
    double carbonFootprint = 0.0;

    // Transport scoring
    switch (transportMode.toLowerCase()) {
      case 'flight':
        score -= 30;
        carbonFootprint += distance * 0.255; // kg CO2 per km
        recommendations.add('Consider train travel for shorter distances');
        break;
      case 'train':
        score -= 5;
        carbonFootprint += distance * 0.041;
        break;
      case 'bus':
        score -= 10;
        carbonFootprint += distance * 0.089;
        break;
      case 'car':
        score -= 20;
        carbonFootprint += distance * 0.171;
        recommendations.add('Consider carpooling or public transport');
        break;
    }

    // Accommodation scoring
    switch (accommodationType.toLowerCase()) {
      case 'eco-resort':
        score += 10;
        break;
      case 'homestay':
        score += 5;
        break;
      case 'luxury-hotel':
        score -= 15;
        recommendations.add('Consider eco-certified accommodations');
        break;
      case 'budget-hotel':
        score -= 5;
        break;
    }

    // Activities scoring
    for (final activity in activities) {
      switch (activity.toLowerCase()) {
        case 'wildlife-sanctuary':
        case 'nature-walk':
        case 'cycling':
          score += 5;
          break;
        case 'water-sports':
        case 'adventure-sports':
          score -= 3;
          break;
        case 'shopping':
          score -= 5;
          recommendations.add('Support local artisans and sustainable products');
          break;
      }
    }

    // Additional recommendations
    if (score < 70) {
      recommendations.add('Offset your carbon footprint through verified programs');
    }
    if (nights > 7) {
      recommendations.add('Longer stays reduce per-day environmental impact');
      score += 5;
    }

    return SustainabilityScore(
      overallScore: score.clamp(0, 100),
      carbonFootprint: carbonFootprint,
      recommendations: recommendations,
      ecoFriendlyAlternatives: _getEcoAlternatives(transportMode, accommodationType),
    );
  }

  static List<EcoAlternative> _getEcoAlternatives(String transport, String accommodation) {
    List<EcoAlternative> alternatives = [];

    if (transport.toLowerCase() == 'flight') {
      alternatives.add(EcoAlternative(
        type: 'Transport',
        suggestion: 'Train Travel',
        impact: 'Reduces CO2 emissions by 80%',
        icon: '🚂',
      ));
    }

    if (accommodation.toLowerCase().contains('hotel')) {
      alternatives.add(EcoAlternative(
        type: 'Accommodation',
        suggestion: 'Eco-certified Resort',
        impact: 'Solar powered, waste reduction',
        icon: '🌱',
      ));
    }

    alternatives.add(EcoAlternative(
      type: 'Activities',
      suggestion: 'Local Cultural Experiences',
      impact: 'Supports local communities',
      icon: '🏛️',
    ));

    return alternatives;
  }

  static List<CarbonOffset> getCarbonOffsetOptions(double carbonFootprint) {
    return [
      CarbonOffset(
        provider: 'Forest Restoration India',
        cost: carbonFootprint * 15, // ₹15 per kg CO2
        description: 'Plant trees in degraded forest areas',
        impact: '${(carbonFootprint * 2).toInt()} trees planted',
      ),
      CarbonOffset(
        provider: 'Renewable Energy Projects',
        cost: carbonFootprint * 12,
        description: 'Support solar and wind energy projects',
        impact: '${carbonFootprint.toInt()} kg CO2 offset',
      ),
      CarbonOffset(
        provider: 'Clean Cooking Stoves',
        cost: carbonFootprint * 10,
        description: 'Provide efficient stoves to rural families',
        impact: 'Reduces emissions for ${(carbonFootprint / 2).toInt()} families',
      ),
    ];
  }
}

class SustainabilityScore {
  final double overallScore;
  final double carbonFootprint;
  final List<String> recommendations;
  final List<EcoAlternative> ecoFriendlyAlternatives;

  SustainabilityScore({
    required this.overallScore,
    required this.carbonFootprint,
    required this.recommendations,
    required this.ecoFriendlyAlternatives,
  });

  String get scoreGrade {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    if (overallScore >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  Color get scoreColor {
    if (overallScore >= 80) return const Color(0xFF4CAF50);
    if (overallScore >= 60) return const Color(0xFF8BC34A);
    if (overallScore >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

class EcoAlternative {
  final String type;
  final String suggestion;
  final String impact;
  final String icon;

  EcoAlternative({
    required this.type,
    required this.suggestion,
    required this.impact,
    required this.icon,
  });
}

class CarbonOffset {
  final String provider;
  final double cost;
  final String description;
  final String impact;

  CarbonOffset({
    required this.provider,
    required this.cost,
    required this.description,
    required this.impact,
  });
}