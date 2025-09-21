// User and authentication models
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final UserProfile profile;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.profile,
    required this.createdAt,
    required this.lastLoginAt,
  });
}

class UserProfile {
  final String travelStyle;
  final List<String> dietaryRestrictions;
  final List<String> accessibilityNeeds;
  final String preferredCurrency;
  final List<String> favoriteDestinations;
  final Map<String, double> activityPreferences;
  final List<String> languages;
  final NotificationSettings notifications;

  UserProfile({
    this.travelStyle = 'balanced',
    this.dietaryRestrictions = const [],
    this.accessibilityNeeds = const [],
    this.preferredCurrency = 'INR',
    this.favoriteDestinations = const [],
    this.activityPreferences = const {},
    this.languages = const ['English'],
    required this.notifications,
  });
}

class NotificationSettings {
  final bool priceAlerts;
  final bool weatherUpdates;
  final bool itineraryReminders;
  final bool socialUpdates;
  final bool marketingEmails;

  NotificationSettings({
    this.priceAlerts = true,
    this.weatherUpdates = true,
    this.itineraryReminders = true,
    this.socialUpdates = false,
    this.marketingEmails = false,
  });
}

class SavedTrip {
  final String id;
  final String userId;
  final String title;
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final double budget;
  final List<String> themes;
  final int people;
  final bool isFavorite;
  final bool isShared;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> collaborators;
  final TripStatus status;

  SavedTrip({
    required this.id,
    required this.userId,
    required this.title,
    required this.destination,
    this.startDate,
    this.endDate,
    required this.budget,
    required this.themes,
    required this.people,
    this.isFavorite = false,
    this.isShared = false,
    required this.createdAt,
    required this.updatedAt,
    this.collaborators = const [],
    this.status = TripStatus.planning,
  });
}

enum TripStatus { planning, booked, ongoing, completed, cancelled }

class UserBehavior {
  final String userId;
  final Map<String, int> destinationViews;
  final Map<String, int> activityClicks;
  final Map<String, double> themePreferences;
  final List<String> searchHistory;
  final Map<String, int> bookingHistory;
  final DateTime lastUpdated;

  UserBehavior({
    required this.userId,
    this.destinationViews = const {},
    this.activityClicks = const {},
    this.themePreferences = const {},
    this.searchHistory = const [],
    this.bookingHistory = const {},
    required this.lastUpdated,
  });
}

class PriceAlert {
  final String id;
  final String userId;
  final String destination;
  final String type;
  final double targetPrice;
  final double currentPrice;
  final bool isActive;
  final DateTime createdAt;

  PriceAlert({
    required this.id,
    required this.userId,
    required this.destination,
    required this.type,
    required this.targetPrice,
    required this.currentPrice,
    this.isActive = true,
    required this.createdAt,
  });
}

class ExpenseTracker {
  final String tripId;
  final Map<String, double> plannedBudget;
  final Map<String, double> actualExpenses;
  final List<Expense> expenses;
  final DateTime lastUpdated;

  ExpenseTracker({
    required this.tripId,
    required this.plannedBudget,
    this.actualExpenses = const {},
    this.expenses = const [],
    required this.lastUpdated,
  });
}

class Expense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String? receipt;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.receipt,
  });
}