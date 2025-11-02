import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/app_bar_widget.dart';
import 'itinerary_result_page.dart';
import '../l10n/app_localizations.dart';
import '../services/api_middleware.dart';
import 'package:intl/intl.dart';

class ItinerarySetupPage extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const ItinerarySetupPage({super.key, required this.tripData});

  @override
  State<ItinerarySetupPage> createState() => _ItinerarySetupPageState();
}

class _ItinerarySetupPageState extends State<ItinerarySetupPage> {
  // Total budget cap (maximum allowed)
  double _totalBudgetCap = 80000;
  final double _maxBudgetCap = 100000;
  final double _minBudgetCap = 5000;
  
  // Individual category budgets
  double _travelBudget = 30000;
  double _foodBudget = 15000;
  double _accommodationBudget = 20000;
  double _activitiesBudget = 10000;
  double _othersBudget = 5000;
  int _peopleCount = 2;
  
  final Map<String, double> _themeWeights = {
    'Nature': 50,
    'Nightlife': 50,
    'Adventure': 50,
    'Leisure': 50,
    'Heritage': 50,
    'Culture': 50,
    'Food': 50,
    'Shopping': 50,
    'Unexplored': 50,
  };
  
  final TextEditingController _preferencesController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _preferencesController.dispose();
    super.dispose();
  }

  // Calculate sum of all category budgets
  double get _totalBudget => _travelBudget + _foodBudget + _accommodationBudget + _activitiesBudget + _othersBudget;
  
  // Calculate remaining budget available for allocation
  double get _remainingBudget => _totalBudgetCap - _totalBudget;
  
  // Check if budget limit is reached
  bool get _isBudgetLimitReached => _totalBudget >= _totalBudgetCap;
  
  double get _totalThemeWeight => _themeWeights.values.fold(0.0, (sum, val) => sum + val);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    
    return Scaffold(
      appBar: SharedAppBar(title: AppLocalizations.of(context).translate('customize_trip')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedSection(0, _buildTripSummary()),
                const SizedBox(height: 32),
                if (isMobile || isTablet) ...[
                  _buildAnimatedSection(1, _buildBudgetSection()),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(2, _buildThemesSection()),
                ] else
                  _buildAnimatedSection(1, IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildBudgetSection()),
                        const SizedBox(width: 32),
                        Expanded(child: _buildThemesSection()),
                      ],
                    ),
                  )),
                const SizedBox(height: 32),
                if (isMobile || isTablet) ...[
                  _buildAnimatedSection(3, _buildPeopleSection()),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(4, _buildRequirementsSection()),
                ] else
                  _buildAnimatedSection(3, IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildPeopleSection()),
                        const SizedBox(width: 32),
                        Expanded(child: _buildRequirementsSection()),
                      ],
                    ),
                  )),
                const SizedBox(height: 40),
                _buildAnimatedSection(5, _buildGenerateButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTripSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF007BFF).withOpacity(0.1), const Color(0xFF0056B3).withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).translate('trip_overview'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, AppLocalizations.of(context).translate('from'), widget.tripData['from']),
          _buildInfoRow(Icons.location_on, AppLocalizations.of(context).translate('to'), widget.tripData['to']),
          _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context).translate('duration'), '${widget.tripData['duration']} ${AppLocalizations.of(context).translate('days')}'),
          _buildInfoRow(Icons.date_range, AppLocalizations.of(context).translate('dates'), '${_formatDate(widget.tripData['startDate'])} - ${_formatDate(widget.tripData['endDate'])}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF007BFF)),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildBudgetSection() {
    return Container(
      height: 1200,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Color(0xFF007BFF), size: 24),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).translate('budget'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 24),
          // Total Budget Cap Slider - sets the maximum limit for all categories
          _buildTotalBudgetSlider(),
          const SizedBox(height: 20),
          // Current allocation display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isBudgetLimitReached 
                  ? const Color(0xFFFF9800).withOpacity(0.1)
                  : const Color(0xFF007BFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isBudgetLimitReached 
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF007BFF).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).translate('allocated'), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                    Text('₹${_totalBudget.toInt()}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _isBudgetLimitReached ? const Color(0xFFFF9800) : const Color(0xFF007BFF))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppLocalizations.of(context).translate('remaining'), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                    Text('₹${_remainingBudget.toInt()}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _remainingBudget > 0 ? const Color(0xFF4CAF50) : const Color(0xFFDC3545))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Category budget sliders - interdependent with total budget cap
          _buildCategorySlider(AppLocalizations.of(context).translate('travel'), _travelBudget, (val) => _updateCategoryBudget('travel', val), const Color(0xFF007BFF)),
          const SizedBox(height: 20),
          _buildCategorySlider(AppLocalizations.of(context).translate('food'), _foodBudget, (val) => _updateCategoryBudget('food', val), const Color(0xFFFF9800)),
          const SizedBox(height: 20),
          _buildCategorySlider(AppLocalizations.of(context).translate('accommodation'), _accommodationBudget, (val) => _updateCategoryBudget('accommodation', val), const Color(0xFF9C27B0)),
          const SizedBox(height: 20),
          _buildCategorySlider(AppLocalizations.of(context).translate('activities'), _activitiesBudget, (val) => _updateCategoryBudget('activities', val), const Color(0xFF00BCD4)),
          const SizedBox(height: 20),
          _buildCategorySlider(AppLocalizations.of(context).translate('others'), _othersBudget, (val) => _updateCategoryBudget('others', val), const Color(0xFF4CAF50)),
          const SizedBox(height: 28),
          _buildBudgetBreakdownBar(),
          // Warning when budget limit is reached
          if (_isBudgetLimitReached) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF9800)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).translate('budget_limit_reached'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFFFF9800), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Total Budget Cap Slider - sets the maximum limit for all category budgets
  Widget _buildTotalBudgetSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(AppLocalizations.of(context).translate('total_budget_cap'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: AppLocalizations.of(context).translate('max_budget_tooltip'),
                    child: Icon(Icons.help_outline, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
              Text('₹${_totalBudgetCap.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF007BFF))),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF007BFF),
            inactiveTrackColor: const Color(0xFF007BFF).withOpacity(0.2),
            thumbColor: const Color(0xFF007BFF),
            overlayColor: const Color(0xFF007BFF).withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 6,
          ),
          child: Slider(
            value: _totalBudgetCap.clamp(_minBudgetCap, _maxBudgetCap),
            min: _minBudgetCap,
            max: _maxBudgetCap,
            divisions: 190,
            onChanged: (val) {
              setState(() {
                _totalBudgetCap = val;
                // If new cap is less than current allocation, proportionally reduce categories
                if (_totalBudget > _totalBudgetCap) {
                  _proportionallyReduceBudgets();
                }
              });
            },
          ),
        ),
      ],
    );
  }
  
  /// Category Budget Slider - interdependent with total budget cap
  /// Prevents exceeding the total budget limit
  Widget _buildCategorySlider(String label, double value, Function(double) onChanged, Color color) {
    // Calculate maximum allowed value for this category
    // = current value + remaining budget
    final maxAllowed = (value + _remainingBudget).clamp(0.0, _totalBudgetCap);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
              Text('₹${value.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 6,
            // Disable thumb if budget limit reached and trying to increase
            disabledThumbColor: color.withOpacity(0.5),
            disabledActiveTrackColor: color.withOpacity(0.3),
            disabledInactiveTrackColor: color.withOpacity(0.1),
          ),
          child: Slider(
            value: value.clamp(0.0, maxAllowed),
            min: 0,
            max: 100000,
            divisions: 200,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
  
  /// Update category budget with interdependent logic
  /// Ensures total budget never exceeds the cap
  void _updateCategoryBudget(String category, double newValue) {
    setState(() {
      // Get current value of this category
      double currentValue;
      switch (category) {
        case 'travel':
          currentValue = _travelBudget;
          break;
        case 'food':
          currentValue = _foodBudget;
          break;
        case 'accommodation':
          currentValue = _accommodationBudget;
          break;
        case 'activities':
          currentValue = _activitiesBudget;
          break;
        case 'others':
          currentValue = _othersBudget;
          break;
        default:
          return;
      }
      
      // Calculate what the new total would be
      final difference = newValue - currentValue;
      final newTotal = _totalBudget + difference;
      
      // Only allow change if it doesn't exceed the cap
      if (newTotal <= _totalBudgetCap) {
        switch (category) {
          case 'travel':
            _travelBudget = newValue;
            break;
          case 'food':
            _foodBudget = newValue;
            break;
          case 'accommodation':
            _accommodationBudget = newValue;
            break;
          case 'activities':
            _activitiesBudget = newValue;
            break;
          case 'others':
            _othersBudget = newValue;
            break;
        }
      } else {
        // If trying to exceed, set to maximum allowed
        final maxAllowed = currentValue + _remainingBudget;
        switch (category) {
          case 'travel':
            _travelBudget = maxAllowed;
            break;
          case 'food':
            _foodBudget = maxAllowed;
            break;
          case 'accommodation':
            _accommodationBudget = maxAllowed;
            break;
          case 'activities':
            _activitiesBudget = maxAllowed;
            break;
          case 'others':
            _othersBudget = maxAllowed;
            break;
        }
      }
    });
  }
  
  /// Proportionally reduce all category budgets when total cap is decreased
  /// Maintains the same ratio between categories
  void _proportionallyReduceBudgets() {
    if (_totalBudget <= _totalBudgetCap) return;
    
    // Calculate reduction ratio
    final ratio = _totalBudgetCap / _totalBudget;
    
    // Apply ratio to all categories
    _travelBudget = (_travelBudget * ratio).clamp(0.0, _totalBudgetCap);
    _foodBudget = (_foodBudget * ratio).clamp(0.0, _totalBudgetCap);
    _accommodationBudget = (_accommodationBudget * ratio).clamp(0.0, _totalBudgetCap);
    _activitiesBudget = (_activitiesBudget * ratio).clamp(0.0, _totalBudgetCap);
    _othersBudget = (_othersBudget * ratio).clamp(0.0, _totalBudgetCap);
  }

  Widget _buildBudgetBreakdownBar() {
    // Prevent division by zero when total budget is 0
    if (_totalBudget <= 0) {
      return const SizedBox.shrink();
    }
    
    final travelPercent = _travelBudget / _totalBudget;
    final foodPercent = _foodBudget / _totalBudget;
    final accommodationPercent = _accommodationBudget / _totalBudget;
    final activitiesPercent = _activitiesBudget / _totalBudget;
    final othersPercent = _othersBudget / _totalBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).translate('budget_breakdown'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Expanded(flex: (travelPercent * 100).toInt(), child: Container(height: 32, color: const Color(0xFF007BFF))),
              Expanded(flex: (foodPercent * 100).toInt(), child: Container(height: 32, color: const Color(0xFFFF9800))),
              Expanded(flex: (accommodationPercent * 100).toInt(), child: Container(height: 32, color: const Color(0xFF9C27B0))),
              Expanded(flex: (activitiesPercent * 100).toInt(), child: Container(height: 32, color: const Color(0xFF00BCD4))),
              Expanded(flex: (othersPercent * 100).toInt(), child: Container(height: 32, color: const Color(0xFF4CAF50))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendItem(AppLocalizations.of(context).translate('travel'), const Color(0xFF007BFF), '${(travelPercent * 100).toInt()}%'),
            _buildLegendItem(AppLocalizations.of(context).translate('food'), const Color(0xFFFF9800), '${(foodPercent * 100).toInt()}%'),
            _buildLegendItem(AppLocalizations.of(context).translate('accommodation'), const Color(0xFF9C27B0), '${(accommodationPercent * 100).toInt()}%'),
            _buildLegendItem(AppLocalizations.of(context).translate('activities'), const Color(0xFF00BCD4), '${(activitiesPercent * 100).toInt()}%'),
            _buildLegendItem(AppLocalizations.of(context).translate('others'), const Color(0xFF4CAF50), '${(othersPercent * 100).toInt()}%'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String percent) {
    return Row(
      children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text('$label ($percent)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildPeopleSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: Color(0xFF007BFF), size: 24),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).translate('number_of_people'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _peopleCount > 1 ? () => setState(() => _peopleCount--) : null,
                icon: const Icon(Icons.remove_circle),
                iconSize: 44,
                color: const Color(0xFF007BFF),
                disabledColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              Container(
                width: 110,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF).withOpacity(0.08),
                  border: Border.all(color: const Color(0xFF007BFF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_peopleCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF007BFF)),
                ),
              ),
              IconButton(
                onPressed: _peopleCount < 10 ? () => setState(() => _peopleCount++) : null,
                icon: const Icon(Icons.add_circle),
                iconSize: 44,
                color: const Color(0xFF007BFF),
                disabledColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF007BFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 20, color: Color(0xFF007BFF)),
                const SizedBox(width: 10),
                Text(
                  '${AppLocalizations.of(context).translate('estimated_cost_per_person')}: ₹${(_totalBudget / _peopleCount).toInt()}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesSection() {
    return Container(
      height: 1200,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: Color(0xFF007BFF), size: 24),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).translate('themes'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).translate('adjust_theme_weights'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
          const SizedBox(height: 20),
          // Theme sliders with even spacing
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _themeWeights.keys.map((theme) => _buildThemeSlider(theme)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Theme slider without limit enforcement
  Widget _buildThemeSlider(String theme) {
    final icons = {
      'Nature': Icons.nature,
      'Nightlife': Icons.nightlife,
      'Adventure': Icons.terrain,
      'Leisure': Icons.spa,
      'Heritage': Icons.account_balance,
      'Culture': Icons.theater_comedy,
      'Food': Icons.restaurant,
      'Shopping': Icons.shopping_bag,
      'Unexplored': Icons.explore,
    };
    
    final colors = {
      'Nature': const Color(0xFF66BB6A),
      'Nightlife': const Color(0xFFFFB74D),
      'Adventure': const Color(0xFFFF7043),
      'Leisure': const Color(0xFF26C6DA),
      'Heritage': const Color(0xFFAB47BC),
      'Culture': const Color(0xFFEC407A),
      'Food': const Color(0xFFFFA726),
      'Shopping': const Color(0xFFEF5350),
      'Unexplored': const Color(0xFF78909C),
    };
    
    final themeKeys = {
      'Nature': 'nature',
      'Nightlife': 'nightlife',
      'Adventure': 'adventure',
      'Leisure': 'leisure',
      'Heritage': 'heritage',
      'Culture': 'culture',
      'Food': 'food',
      'Shopping': 'shopping',
      'Unexplored': 'unexplored',
    };
    
    final color = colors[theme]!;
    final currentValue = _themeWeights[theme]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Theme icon with consistent spacing
          Icon(icons[theme], size: 20, color: color),
          const SizedBox(width: 12),
          // Fixed width for theme name to maintain alignment
          SizedBox(
            width: 100,
            child: Text(
              AppLocalizations.of(context).translate(themeKeys[theme]!), 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Slider with interdependent limit enforcement
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                trackHeight: 4,
              ),
              child: Slider(
                value: currentValue,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (val) => setState(() => _themeWeights[theme] = val),
              ),
            ),
          ),
          // Percentage display with fixed width for alignment
          SizedBox(
            width: 45,
            child: Text(
              '${currentValue.toInt()}%', 
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.bold, 
                color: color,
              ), 
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
  


  Widget _buildRequirementsSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: Color(0xFF007BFF), size: 24),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).translate('additional_trip_preferences'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).translate('preferences_description'),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _preferencesController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).translate('preferences_placeholder'),
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Center(
      child: SizedBox(
        width: 400,
        height: 56,
        child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateItinerary,
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
            : Text(
                AppLocalizations.of(context).translate('generate_itinerary').toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        ),
      ),
    );
  }

  void _generateItinerary() async {
    setState(() => _isGenerating = true);

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Generating your personalized itinerary...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      // Format dates as YYYY-MM-DD per API specification
      final dateFormat = DateFormat('yyyy-MM-dd');
      final startDate = widget.tripData['startDate'] as DateTime;
      final endDate = widget.tripData['endDate'] as DateTime;
      final startDateStr = dateFormat.format(startDate);
      final endDateStr = dateFormat.format(endDate);

      // Calculate budget (convert to integer)
      final budgetInt = _totalBudget.toInt();

      // Calculate number of days
      final days = endDate.difference(startDate).inDays + 1;

      // Build preferences object with theme weights
      // If no themes selected, use default value of 50 for all themes
      final Map<String, dynamic> preferencesMap = {};
      
      bool hasSelectedThemes = _themeWeights.values.any((weight) => weight > 0);
      
      if (hasSelectedThemes) {
        // User has selected themes, use their values
        for (var entry in _themeWeights.entries) {
          if (entry.value > 0) {
            preferencesMap[entry.key.toLowerCase()] = entry.value.toInt();
          }
        }
      } else {
        // No themes selected, set all to default 50
        for (var entry in _themeWeights.entries) {
          preferencesMap[entry.key.toLowerCase()] = 50;
        }
      }

      // Capture any additional free-text special requirements the user entered.
      // Do NOT inject these into the numeric preferences map — they should be
      // sent as a top-level string `specialRequirements` in the API request.
      final additionalPrefs = _preferencesController.text.trim();

      // Call backend API /api/v1/plantrip
      print('Calling /api/v1/plantrip with:');
      print('  Destination: ${widget.tripData['to']}');
      print('  Start: $startDateStr, End: $endDateStr');
      print('  Days: $days');
      print('  Budget: $budgetInt');
      print('  People: $_peopleCount');
  print('  Preferences: $preferencesMap');
  print('  Special requirements: "$additionalPrefs"');

      final response = await ApiMiddleware.planTrip(
        destination: widget.tripData['to'], // To location is the destination
        startDate: startDateStr,
        endDate: endDateStr,
        days: days,
        budget: budgetInt,
        preferences: preferencesMap,
        people: _peopleCount,
        specialRequirements: additionalPrefs,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response['success'] == true) {
        // Successfully generated itinerary
        final itineraryData = response['data'];
        
        print('Itinerary generated successfully!');
        print('Trip ID: ${itineraryData['tripId']}');

        if (mounted) {
          // Navigate to itinerary result page with API response
          Navigator.pushNamed(
            context,
            '/itinerary',
            arguments: {
              ...widget.tripData,
              'totalBudget': _totalBudget,
              'travelBudget': _travelBudget,
              'foodBudget': _foodBudget,
              'accommodationBudget': _accommodationBudget,
              'activitiesBudget': _activitiesBudget,
              'othersBudget': _othersBudget,
              'peopleCount': _peopleCount,
              'themeWeights': _themeWeights,
              'additionalPreferences': additionalPrefs,
              // Add API response data
              'apiResponse': itineraryData,
              'itinerary': itineraryData['itinerary'],
              'tripId': itineraryData['tripId'],
              'estimatedCost': itineraryData['estimatedCost'],
              'suggestions': itineraryData['suggestions'],
            },
          );
        }
      } else {
        // API error - show error message
        final errorMsg = response['error'] ?? 'Failed to generate itinerary';
        print('API Error: $errorMsg');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _generateItinerary(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Network or unexpected error
      print('Exception generating itinerary: $e');
      
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _generateItinerary(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
