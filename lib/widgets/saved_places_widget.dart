import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import 'login_button_widget.dart';

class SavedPlacesWidget extends StatefulWidget {
  const SavedPlacesWidget({super.key});

  @override
  State<SavedPlacesWidget> createState() => _SavedPlacesWidgetState();
}

class _SavedPlacesWidgetState extends State<SavedPlacesWidget> {
  List<String> _savedTrips = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTrips();
  }

  Future<void> _loadSavedTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final trips = prefs.getStringList('savedTrips') ?? [];
    if (mounted) {
      setState(() => _savedTrips = trips);
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LoginModal(
        onLoginSuccess: () => setState(() => _loadSavedTrips()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final authProvider = context.watch<AuthProvider>();
    final places = appState.savedPlaces;
    final totalCount = places.length + _savedTrips.length;

    return PopupMenuButton(
      icon: Badge(
        label: Text('$totalCount'),
        isLabelVisible: totalCount > 0 && authProvider.isAuthenticated,
        child: const Icon(Icons.bookmark),
      ),
      tooltip: 'Saved Places & Trips',
      onOpened: () {
        if (!authProvider.isAuthenticated) {
          Navigator.pop(context);
          _showLoginDialog(context);
        }
      },
      itemBuilder: (context) {
        if (!authProvider.isAuthenticated) {
          return [
            const PopupMenuItem(
              enabled: false,
              child: Text('Login required', style: TextStyle(color: Colors.grey)),
            ),
          ];
        }
        List<PopupMenuEntry> items = [];
        
        if (places.isEmpty && _savedTrips.isEmpty) {
          items.add(const PopupMenuItem(
            enabled: false,
            child: Text('No saved items', style: TextStyle(color: Colors.grey)),
          ));
          return items;
        }
        
        if (places.isNotEmpty) {
          items.add(const PopupMenuItem(
            enabled: false,
            child: Text('Saved Places', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ));
          
          for (var place in places) {
            items.add(PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.place, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(place)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      Navigator.pop(context);
                      appState.removeSavedPlace(place);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ));
          }
        }
        
        if (_savedTrips.isNotEmpty) {
          if (places.isNotEmpty) {
            items.add(const PopupMenuDivider());
          }
          
          items.add(const PopupMenuItem(
            enabled: false,
            child: Text('Saved Trips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ));
          
          for (var trip in _savedTrips.take(5)) {
            items.add(PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(trip.length > 30 ? '${trip.substring(0, 30)}...' : trip, style: const TextStyle(fontSize: 13))),
                ],
              ),
              onTap: () {},
            ));
          }
        }
        
        return items;
      },
    );
  }
}
