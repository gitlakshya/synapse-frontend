import 'dart:convert';
import 'dart:html' as html;

class SearchHistoryService {
  static const _key = 'search_history';
  static const int _maxHistory = 10;

  static Future<List<String>> getSearchHistory() async {
    try {
      final historyJson = html.window.localStorage[_key];
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.cast<String>();
      }
    } catch (e) {
      print('Error reading search history: $e');
    }
    return [];
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
      
      html.window.localStorage[_key] = json.encode(history);
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  static Future<void> clearHistory() async {
    try {
      html.window.localStorage.remove(_key);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  static Future<void> removeFromHistory(String searchTerm) async {
    try {
      final history = await getSearchHistory();
      history.remove(searchTerm);
      html.window.localStorage[_key] = json.encode(history);
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }
}