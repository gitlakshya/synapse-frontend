import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AISearchBar extends StatefulWidget {
  const AISearchBar({super.key});

  @override
  State<AISearchBar> createState() => _AISearchBarState();
}

class _AISearchBarState extends State<AISearchBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _cities = ['Mumbai', 'Delhi', 'Bangalore', 'Kolkata', 'Chennai', 'Hyderabad', 'Pune', 'Ahmedabad', 'Jaipur', 'Goa', 'Manali', 'Kerala', 'Udaipur', 'Varanasi', 'Agra'];

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
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
            return _cities.where((city) => city.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (selection) {
            controller.text = selection;
            final appState = context.read<AppState>();
            label == 'From' ? appState.setFrom(selection) : appState.setTo(selection);
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            if (textController.text != controller.text) {
              textController.text = controller.text;
            }
            return TextField(
              controller: textController,
              focusNode: focusNode,
              onChanged: (value) {
                controller.text = value;
                final appState = context.read<AppState>();
                label == 'From' ? appState.setFrom(value) : appState.setTo(value);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF007BFF), size: 20),
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
