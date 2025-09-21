import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;

class SmartFeaturesService {
  static const _packingListsKey = 'packing_lists';
  static const _expensesKey = 'group_expenses';
  static const _alertsKey = 'price_alerts';

  // Smart Packing Assistant
  static Future<PackingList> generatePackingList({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> activities,
    required String weatherForecast,
  }) async {
    final duration = endDate.difference(startDate).inDays;
    final items = <PackingItem>[];
    
    // Essential items
    items.addAll(_getEssentialItems());
    
    // Weather-based items
    items.addAll(_getWeatherBasedItems(weatherForecast));
    
    // Activity-based items
    for (final activity in activities) {
      items.addAll(_getActivityBasedItems(activity));
    }
    
    // Duration-based items
    items.addAll(_getDurationBasedItems(duration));
    
    // Destination-specific items
    items.addAll(_getDestinationSpecificItems(destination));
    
    final packingList = PackingList(
      id: 'packing_${DateTime.now().millisecondsSinceEpoch}',
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      items: items,
      createdAt: DateTime.now(),
    );
    
    await _savePackingList(packingList);
    return packingList;
  }

  static List<PackingItem> _getEssentialItems() {
    return [
      PackingItem(name: 'Passport/ID', category: 'Documents', isEssential: true),
      PackingItem(name: 'Phone Charger', category: 'Electronics', isEssential: true),
      PackingItem(name: 'Medications', category: 'Health', isEssential: true),
      PackingItem(name: 'Underwear', category: 'Clothing', isEssential: true),
      PackingItem(name: 'Toothbrush', category: 'Toiletries', isEssential: true),
    ];
  }

  static List<PackingItem> _getWeatherBasedItems(String weather) {
    final items = <PackingItem>[];
    
    if (weather.toLowerCase().contains('rain')) {
      items.addAll([
        PackingItem(name: 'Umbrella', category: 'Weather Protection', isEssential: true),
        PackingItem(name: 'Rain Jacket', category: 'Clothing', isEssential: true),
        PackingItem(name: 'Waterproof Bag', category: 'Accessories', isEssential: false),
      ]);
    }
    
    if (weather.toLowerCase().contains('cold')) {
      items.addAll([
        PackingItem(name: 'Warm Jacket', category: 'Clothing', isEssential: true),
        PackingItem(name: 'Gloves', category: 'Clothing', isEssential: false),
        PackingItem(name: 'Scarf', category: 'Clothing', isEssential: false),
      ]);
    }
    
    if (weather.toLowerCase().contains('sunny')) {
      items.addAll([
        PackingItem(name: 'Sunglasses', category: 'Accessories', isEssential: true),
        PackingItem(name: 'Sunscreen', category: 'Health', isEssential: true),
        PackingItem(name: 'Hat', category: 'Accessories', isEssential: false),
      ]);
    }
    
    return items;
  }

  static List<PackingItem> _getActivityBasedItems(String activity) {
    switch (activity.toLowerCase()) {
      case 'swimming':
        return [
          PackingItem(name: 'Swimwear', category: 'Clothing', isEssential: true),
          PackingItem(name: 'Beach Towel', category: 'Accessories', isEssential: true),
        ];
      case 'hiking':
        return [
          PackingItem(name: 'Hiking Boots', category: 'Footwear', isEssential: true),
          PackingItem(name: 'Backpack', category: 'Accessories', isEssential: true),
          PackingItem(name: 'Water Bottle', category: 'Accessories', isEssential: true),
        ];
      case 'photography':
        return [
          PackingItem(name: 'Camera', category: 'Electronics', isEssential: true),
          PackingItem(name: 'Extra Batteries', category: 'Electronics', isEssential: true),
          PackingItem(name: 'Memory Cards', category: 'Electronics', isEssential: true),
        ];
      default:
        return [];
    }
  }

  static List<PackingItem> _getDurationBasedItems(int days) {
    final items = <PackingItem>[];
    
    if (days > 7) {
      items.addAll([
        PackingItem(name: 'Laundry Detergent', category: 'Toiletries', isEssential: false),
        PackingItem(name: 'Extra Shoes', category: 'Footwear', isEssential: false),
      ]);
    }
    
    if (days > 14) {
      items.addAll([
        PackingItem(name: 'First Aid Kit', category: 'Health', isEssential: true),
        PackingItem(name: 'Sewing Kit', category: 'Accessories', isEssential: false),
      ]);
    }
    
    return items;
  }

  static List<PackingItem> _getDestinationSpecificItems(String destination) {
    final items = <PackingItem>[];
    
    if (destination.toLowerCase().contains('beach')) {
      items.addAll([
        PackingItem(name: 'Flip Flops', category: 'Footwear', isEssential: true),
        PackingItem(name: 'Beach Bag', category: 'Accessories', isEssential: false),
      ]);
    }
    
    if (destination.toLowerCase().contains('mountain')) {
      items.addAll([
        PackingItem(name: 'Warm Layers', category: 'Clothing', isEssential: true),
        PackingItem(name: 'Altitude Sickness Medicine', category: 'Health', isEssential: false),
      ]);
    }
    
    return items;
  }

  // Expense Splitting
  static Future<GroupExpense> createGroupExpense({
    required String tripId,
    required String description,
    required double amount,
    required String paidBy,
    required List<String> participants,
    required String category,
  }) async {
    final expense = GroupExpense(
      id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      participants: participants,
      category: category,
      createdAt: DateTime.now(),
      splits: _calculateEqualSplit(amount, participants),
    );
    
    await _saveGroupExpense(expense);
    return expense;
  }

  static Map<String, double> _calculateEqualSplit(double amount, List<String> participants) {
    final splitAmount = amount / participants.length;
    return Map.fromIterable(participants, value: (_) => splitAmount);
  }

  static Future<ExpenseSummary> getExpenseSummary(String tripId) async {
    final expenses = await _getGroupExpenses(tripId);
    final summary = <String, double>{};
    final categoryTotals = <String, double>{};
    
    for (final expense in expenses) {
      // Calculate who owes what
      for (final participant in expense.participants) {
        if (participant != expense.paidBy) {
          final owedAmount = expense.splits[participant] ?? 0;
          summary[participant] = (summary[participant] ?? 0) - owedAmount;
          summary[expense.paidBy] = (summary[expense.paidBy] ?? 0) + owedAmount;
        }
      }
      
      // Category totals
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return ExpenseSummary(
      tripId: tripId,
      balances: summary,
      categoryTotals: categoryTotals,
      totalExpenses: expenses.fold(0, (sum, expense) => sum + expense.amount),
    );
  }

  // Price Alerts
  static Future<void> createPriceAlert({
    required String destination,
    required double targetPrice,
    required String userEmail,
  }) async {
    final alert = PriceAlert(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      destination: destination,
      targetPrice: targetPrice,
      userEmail: userEmail,
      isActive: true,
      createdAt: DateTime.now(),
    );
    
    await _savePriceAlert(alert);
  }

  static Future<List<PriceAlert>> getUserPriceAlerts(String userEmail) async {
    final alerts = await _getAllPriceAlerts();
    return alerts.where((alert) => alert.userEmail == userEmail && alert.isActive).toList();
  }

  // Cultural Sensitivity
  static CulturalInfo getCulturalInfo(String destination) {
    final culturalData = {
      'india': CulturalInfo(
        destination: 'India',
        customs: [
          'Remove shoes before entering homes and temples',
          'Use right hand for eating and greeting',
          'Dress modestly, especially in religious places',
        ],
        etiquette: [
          'Namaste is a common greeting',
          'Bargaining is expected in markets',
          'Tipping is customary in restaurants (10-15%)',
        ],
        taboos: [
          'Avoid pointing feet towards people or religious objects',
          'Don\'t touch someone\'s head',
          'Public displays of affection are discouraged',
        ],
        dressCode: 'Conservative clothing recommended, especially for religious sites',
        language: 'Hindi and English are widely spoken',
      ),
    };
    
    return culturalData[destination.toLowerCase()] ?? CulturalInfo.defaultInfo();
  }

  // Helper methods for storage
  static Future<void> _savePackingList(PackingList packingList) async {
    final lists = await _getPackingLists();
    lists.add(packingList);
    html.window.localStorage[_packingListsKey] = json.encode(lists.map((l) => l.toJson()).toList());
  }

  static Future<List<PackingList>> _getPackingLists() async {
    try {
      final listsJson = html.window.localStorage[_packingListsKey];
      if (listsJson != null) {
        final List<dynamic> listsList = json.decode(listsJson);
        return listsList.map((l) => PackingList.fromJson(l)).toList();
      }
    } catch (e) {
      print('Error reading packing lists: $e');
    }
    return [];
  }

  static Future<void> _saveGroupExpense(GroupExpense expense) async {
    final expenses = await _getAllGroupExpenses();
    expenses.add(expense);
    html.window.localStorage[_expensesKey] = json.encode(expenses.map((e) => e.toJson()).toList());
  }

  static Future<List<GroupExpense>> _getAllGroupExpenses() async {
    try {
      final expensesJson = html.window.localStorage[_expensesKey];
      if (expensesJson != null) {
        final List<dynamic> expensesList = json.decode(expensesJson);
        return expensesList.map((e) => GroupExpense.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error reading expenses: $e');
    }
    return [];
  }

  static Future<List<GroupExpense>> _getGroupExpenses(String tripId) async {
    final allExpenses = await _getAllGroupExpenses();
    return allExpenses.where((expense) => expense.tripId == tripId).toList();
  }

  static Future<void> _savePriceAlert(PriceAlert alert) async {
    final alerts = await _getAllPriceAlerts();
    alerts.add(alert);
    html.window.localStorage[_alertsKey] = json.encode(alerts.map((a) => a.toJson()).toList());
  }

  static Future<List<PriceAlert>> _getAllPriceAlerts() async {
    try {
      final alertsJson = html.window.localStorage[_alertsKey];
      if (alertsJson != null) {
        final List<dynamic> alertsList = json.decode(alertsJson);
        return alertsList.map((a) => PriceAlert.fromJson(a)).toList();
      }
    } catch (e) {
      print('Error reading alerts: $e');
    }
    return [];
  }
}

class PackingList {
  final String id;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<PackingItem> items;
  final DateTime createdAt;

  PackingList({
    required this.id,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.items,
    required this.createdAt,
  });

  factory PackingList.fromJson(Map<String, dynamic> json) {
    return PackingList(
      id: json['id'],
      destination: json['destination'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      items: (json['items'] as List).map((i) => PackingItem.fromJson(i)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PackingItem {
  final String name;
  final String category;
  final bool isEssential;
  bool isPacked;

  PackingItem({
    required this.name,
    required this.category,
    required this.isEssential,
    this.isPacked = false,
  });

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      name: json['name'],
      category: json['category'],
      isEssential: json['isEssential'],
      isPacked: json['isPacked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'isEssential': isEssential,
      'isPacked': isPacked,
    };
  }
}

class GroupExpense {
  final String id;
  final String tripId;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> participants;
  final String category;
  final DateTime createdAt;
  final Map<String, double> splits;

  GroupExpense({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.participants,
    required this.category,
    required this.createdAt,
    required this.splits,
  });

  factory GroupExpense.fromJson(Map<String, dynamic> json) {
    return GroupExpense(
      id: json['id'],
      tripId: json['tripId'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      paidBy: json['paidBy'],
      participants: List<String>.from(json['participants']),
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      splits: Map<String, double>.from(json['splits']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'participants': participants,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'splits': splits,
    };
  }
}

class ExpenseSummary {
  final String tripId;
  final Map<String, double> balances;
  final Map<String, double> categoryTotals;
  final double totalExpenses;

  ExpenseSummary({
    required this.tripId,
    required this.balances,
    required this.categoryTotals,
    required this.totalExpenses,
  });
}

class PriceAlert {
  final String id;
  final String destination;
  final double targetPrice;
  final String userEmail;
  bool isActive;
  final DateTime createdAt;

  PriceAlert({
    required this.id,
    required this.destination,
    required this.targetPrice,
    required this.userEmail,
    required this.isActive,
    required this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'],
      destination: json['destination'],
      targetPrice: json['targetPrice'].toDouble(),
      userEmail: json['userEmail'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'targetPrice': targetPrice,
      'userEmail': userEmail,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CulturalInfo {
  final String destination;
  final List<String> customs;
  final List<String> etiquette;
  final List<String> taboos;
  final String dressCode;
  final String language;

  CulturalInfo({
    required this.destination,
    required this.customs,
    required this.etiquette,
    required this.taboos,
    required this.dressCode,
    required this.language,
  });

  factory CulturalInfo.defaultInfo() {
    return CulturalInfo(
      destination: 'General',
      customs: ['Respect local traditions'],
      etiquette: ['Be polite and courteous'],
      taboos: ['Avoid offensive behavior'],
      dressCode: 'Dress appropriately for the culture',
      language: 'Learn basic local phrases',
    );
  }
}