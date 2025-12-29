import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/app_state.dart';
import '../services/places_service.dart';

class AISearchBar extends StatefulWidget {
  const AISearchBar({super.key});

  @override
  State<AISearchBar> createState() => _AISearchBarState();
}

class _AISearchBarState extends State<AISearchBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  
  // Google Places Autocomplete service
  final _placesService = PlacesService();
  
  // Debounce timer to reduce API calls
  Timer? _debounceTimer;
  
  // Store selected city data
  String? _fromPlaceId;
  String? _toPlaceId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _tabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 800;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF007BFF),
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: const Color(0xFF007BFF),
                indicatorWeight: 3,
                tabs: const [Tab(text: 'Flights'), Tab(text: 'Hotels'), Tab(text: 'Holidays'), Tab(text: 'AI Trip Planner')],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmall ? 20 : 32),
              child: Column(
                children: [
                  if (isSmall) ..._buildMobileFields() else ..._buildDesktopFields(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isValid ? () => _navigateToItinerary(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('GENERATE MY TRIP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isValid {
    final appState = context.watch<AppState>();
    return _fromController.text.trim().isNotEmpty &&
           _toController.text.trim().isNotEmpty &&
           appState.startDate != null &&
           appState.endDate != null;
  }

  List<Widget> _buildDesktopFields() {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildAutocompleteField('From', _fromController)),
          const SizedBox(width: 20),
          Expanded(child: _buildAutocompleteField('To', _toController)),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDateField('Start Date', true)),
          const SizedBox(width: 20),
          Expanded(child: _buildDateField('End Date', false)),
          const SizedBox(width: 20),
          Expanded(child: _buildDurationDisplay()),
        ],
      ),
    ];
  }

  List<Widget> _buildMobileFields() {
    return [
      _buildAutocompleteField('From', _fromController),
      const SizedBox(height: 20),
      _buildAutocompleteField('To', _toController),
      const SizedBox(height: 20),
      _buildDateField('Start Date', true),
      const SizedBox(height: 20),
      _buildDateField('End Date', false),
      const SizedBox(height: 20),
      _buildDurationDisplay(),
    ];
  }

  Widget _buildAutocompleteField(String label, TextEditingController controller) {
    final isFrom = controller == _fromController;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              const Text(' *', style: TextStyle(color: Color(0xFFDC3545), fontSize: 14)),
            ],
          ),
        ),
        // Autocomplete widget with Google Places API
        Autocomplete<PlacePrediction>(
          // Fetch city predictions from Google Places API with debounce
          optionsBuilder: (TextEditingValue textEditingValue) async {
            final query = textEditingValue.text.trim();
            
            // Return empty if query is too short
            if (query.length < 2) {
              return const Iterable<PlacePrediction>.empty();
            }
            
            // Cancel previous debounce timer
            _debounceTimer?.cancel();
            
            // Create completer for debounced result
            final completer = Completer<Iterable<PlacePrediction>>();
            
            // Set debounce timer (300ms) to reduce API calls
            _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
              try {
                // Fetch city predictions from Google Places API
                final predictions = await _placesService.getCityPredictions(query);
                completer.complete(predictions);
              } catch (e) {
                completer.complete(const Iterable<PlacePrediction>.empty());
              }
            });
            
            return completer.future;
          },
          // Display city name and country in dropdown
          displayStringForOption: (PlacePrediction prediction) => prediction.description,
          // Handle city selection
          onSelected: (PlacePrediction prediction) {
            // Store selected city name and place_id
            controller.text = prediction.mainText;
            if (isFrom) {
              _fromPlaceId = prediction.placeId;
            } else {
              _toPlaceId = prediction.placeId;
            }
            final appState = context.read<AppState>();
            label == 'From' ? appState.setFrom(prediction.mainText) : appState.setTo(prediction.mainText);
          },
          // Build text field
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            // Sync with main controller
            if (textEditingController.text != controller.text) {
              textEditingController.value = textEditingController.value.copyWith(
                text: controller.text,
                selection: TextSelection.collapsed(offset: controller.text.length),
              );
            }
            
            // Sync text changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (textEditingController.text != controller.text) {
                controller.text = textEditingController.text;
              }
            });
            
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                controller.text = value;
                final appState = context.read<AppState>();
                label == 'From' ? appState.setFrom(value) : appState.setTo(value);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF007BFF), size: 20),
                suffixIcon: textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          // Clear input and stored data
                          textEditingController.clear();
                          controller.clear();
                          if (isFrom) {
                            _fromPlaceId = null;
                          } else {
                            _toPlaceId = null;
                          }
                          final appState = context.read<AppState>();
                          label == 'From' ? appState.setFrom('') : appState.setTo('');
                        },
                      )
                    : null,
                hintText: 'Enter $label',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            );
          },
          // Custom dropdown builder for better styling
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  width: 400,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: options.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final prediction = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.location_city, color: Color(0xFF007BFF), size: 20),
                        title: Text(
                          prediction.mainText,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          prediction.secondaryText,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        onTap: () => onSelected(prediction),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateField(String label, bool isStart) {
    final appState = context.watch<AppState>();
    final date = isStart ? appState.startDate : appState.endDate;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              const Text(' *', style: TextStyle(color: Color(0xFFDC3545), fontSize: 14)),
            ],
          ),
        ),
        InkWell(
          onTap: () => _selectDate(isStart),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF007BFF), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? '${date.day}/${date.month}/${date.year}' : 'Select',
                    style: TextStyle(color: date != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDisplay() {
    final appState = context.watch<AppState>();
    final duration = appState.tripDuration;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text('Trip Duration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Auto-calculated from dates',
                child: Icon(Icons.help_outline, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF007BFF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event, color: Color(0xFF007BFF), size: 18),
              const SizedBox(width: 12),
              Text(
                duration > 0 ? '$duration ${duration == 1 ? "day" : "days"}' : 'Select dates',
                style: TextStyle(
                  color: duration > 0 ? const Color(0xFF007BFF) : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final appState = context.read<AppState>();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (appState.startDate ?? DateTime.now()),
      firstDate: isStart ? DateTime.now() : (appState.startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (isStart) {
        appState.setStartDate(picked);
        if (appState.endDate != null && appState.endDate!.isBefore(picked)) {
          // Clear end date if it's before new start date
        }
      } else {
        appState.setEndDate(picked);
      }
    }
  }

  void _navigateToItinerary(BuildContext context) {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields'), backgroundColor: Color(0xFFDC3545)),
      );
      return;
    }
    Navigator.pushNamed(context, '/itinerary');
  }
}
