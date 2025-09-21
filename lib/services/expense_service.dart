import 'dart:convert';
import 'dart:html' as html;

class ExpenseService {
  static const String _expensesKey = 'trip_expenses';

  Future<List<Expense>> getExpenses(String tripId) async {
    final data = html.window.localStorage['${_expensesKey}_$tripId'];
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Expense.fromJson(json)).toList();
  }

  Future<void> addExpense(String tripId, Expense expense) async {
    final expenses = await getExpenses(tripId);
    expenses.add(expense);
    await _saveExpenses(tripId, expenses);
  }

  Future<void> updateExpense(String tripId, Expense expense) async {
    final expenses = await getExpenses(tripId);
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      await _saveExpenses(tripId, expenses);
    }
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    final expenses = await getExpenses(tripId);
    expenses.removeWhere((e) => e.id == expenseId);
    await _saveExpenses(tripId, expenses);
  }

  Future<void> _saveExpenses(String tripId, List<Expense> expenses) async {
    final jsonList = expenses.map((e) => e.toJson()).toList();
    html.window.localStorage['${_expensesKey}_$tripId'] = json.encode(jsonList);
  }

  Future<ExpenseSummary> getExpenseSummary(String tripId) async {
    final expenses = await getExpenses(tripId);
    
    double total = 0;
    Map<ExpenseCategory, double> categoryTotals = {};
    
    for (final expense in expenses) {
      total += expense.amount;
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return ExpenseSummary(
      totalAmount: total,
      categoryBreakdown: categoryTotals,
      expenseCount: expenses.length,
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? description;
  final String? receipt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.receipt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      category: ExpenseCategory.values[json['category']],
      date: DateTime.parse(json['date']),
      description: json['description'],
      receipt: json['receipt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.index,
      'date': date.toIso8601String(),
      'description': description,
      'receipt': receipt,
    };
  }
}

enum ExpenseCategory {
  accommodation,
  transport,
  food,
  activities,
  shopping,
  other,
}

class ExpenseSummary {
  final double totalAmount;
  final Map<ExpenseCategory, double> categoryBreakdown;
  final int expenseCount;

  ExpenseSummary({
    required this.totalAmount,
    required this.categoryBreakdown,
    required this.expenseCount,
  });
}