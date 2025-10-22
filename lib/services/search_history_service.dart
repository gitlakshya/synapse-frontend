import 'dart:convert';
import 'package:web/web.dart' as web;

class SearchHistoryService {
  static const String _key = 'search_history';
  static const int _maxHistory = 10;

  static Future<List<String>> getSearchHistory() async {
    try {
      final historyJson = web.window.localStorage.getItem(_key);
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        return historyList.map((item) => item as String).toList();
      }
      return [];
    } catch (e) {
      print('Error loading search history: $e');
      return [];
    }
  }

  static Future<void> addToHistory(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    
    try {
      final history = await getSearchHistory();
      history.remove(searchTerm); // Remove if exists
      history.insert(0, searchTerm); // Add to beginning
      
      // Keep only recent searches
      if (history.length > _maxHistory) {
        history.removeRange(_maxHistory, history.length);
      }
      
      web.window.localStorage.setItem(_key, jsonEncode(history));
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  static Future<void> clearHistory() async {
    try {
      web.window.localStorage.removeItem(_key);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  static Future<void> removeFromHistory(String searchTerm) async {
    try {
      final history = await getSearchHistory();
      history.remove(searchTerm);
      web.window.localStorage.setItem(_key, jsonEncode(history));
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }

  static Future<List<String>> getSuggestions(String query) async {
    final history = await getSearchHistory();
    return history
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }
}
