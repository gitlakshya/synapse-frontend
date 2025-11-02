import 'package:flutter/material.dart';
import 'dart:async';
import 'ai_loading.dart';
import '../utils/responsive.dart';
import '../services/places_service.dart';
import '../l10n/app_localizations.dart';

class HeroSearchWidget extends StatefulWidget {
  const HeroSearchWidget({super.key});

  @override
  State<HeroSearchWidget> createState() => _HeroSearchWidgetState();
}

class _HeroSearchWidgetState extends State<HeroSearchWidget> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;
  
  // Google Places Autocomplete service
  final _placesService = PlacesService();
  
  // Debounce timer to reduce API calls
  Timer? _debounceTimer;
  
  // Store selected city data
  String? _fromPlaceId;
  String? _toPlaceId;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  int get _tripDuration {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  bool get _isValid {
    return _fromController.text.trim().isNotEmpty &&
           _toController.text.trim().isNotEmpty &&
           _tripDuration >= 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).translate('ai_trip_planner'),
                  style: const TextStyle(
                    color: Color(0xFF007BFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildAutocompleteField(AppLocalizations.of(context).translate('from'), _fromController, Icons.location_on)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildAutocompleteField(AppLocalizations.of(context).translate('to'), _toController, Icons.location_on)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildAutocompleteField(AppLocalizations.of(context).translate('from'), _fromController, Icons.location_on),
                        const SizedBox(height: 20),
                        _buildAutocompleteField(AppLocalizations.of(context).translate('to'), _toController, Icons.location_on),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDateField(AppLocalizations.of(context).translate('start_date'), _startDate, () => _selectDate(true))),
                        const SizedBox(width: 20),
                        Expanded(child: _buildDateField(AppLocalizations.of(context).translate('end_date'), _endDate, () => _selectDate(false))),
                        const SizedBox(width: 20),
                        Expanded(child: _buildDurationDisplay()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildDateField(AppLocalizations.of(context).translate('start_date'), _startDate, () => _selectDate(true)),
                        const SizedBox(height: 20),
                        _buildDateField(AppLocalizations.of(context).translate('end_date'), _endDate, () => _selectDate(false)),
                        const SizedBox(height: 20),
                        _buildDurationDisplay(),
                      ],
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: !_isGenerating ? () => _generateTrip(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isGenerating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(AppLocalizations.of(context).translate('generate_my_trip').toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  /// Build autocomplete field with Google Places API integration
  /// Fetches city-level predictions as user types with debounce
  Widget _buildAutocompleteField(String label, TextEditingController controller, IconData icon) {
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
            
            // Sync text changes without adding duplicate listeners
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (textEditingController.text != controller.text) {
                controller.text = textEditingController.text;
              }
            });
            
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFF007BFF), size: 20),
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
                        },
                      )
                    : null,
                hintText: AppLocalizations.of(context).translate('select_city'),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
                ),
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

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
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
          onTap: onTap,
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
                    date != null ? '${date.day}/${date.month}/${date.year}' : AppLocalizations.of(context).translate('select_date'),
                    style: TextStyle(
                      color: date != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 15,
                    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(AppLocalizations.of(context).translate('trip_duration'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(width: 4),
              Tooltip(
                message: AppLocalizations.of(context).translate('auto_calculated'),
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
                _tripDuration > 0 ? '$_tripDuration ${AppLocalizations.of(context).translate('days')}' : AppLocalizations.of(context).translate('select_date'),
                style: TextStyle(
                  color: _tripDuration > 0 ? const Color(0xFF007BFF) : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      firstDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _generateTrip(BuildContext context) async {
    if (_isGenerating) return;

    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields before generating your trip.'),
          backgroundColor: Color(0xFFDC3545),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AILoadingWidget(message: 'Preparing your trip customization...'),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        '/generate',
        arguments: {
          'from': _fromController.text,
          'to': _toController.text,
          'startDate': _startDate,
          'endDate': _endDate,
          'duration': _tripDuration,
        },
      );
      setState(() => _isGenerating = false);
    }
  }
}
