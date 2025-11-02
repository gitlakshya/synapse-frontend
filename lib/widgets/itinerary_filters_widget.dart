import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ItineraryFilters {
  double mainBudget;
  double travelBudget;
  double foodBudget;
  double accommodationBudget;
  double experiencesBudget;
  int peopleCount;
  Map<String, double> themePercentages;
  bool hasPet;
  bool seniorCitizens;
  bool vegetarianOnly;

  ItineraryFilters({
    this.mainBudget = 50000,
    this.travelBudget = 15000,
    this.foodBudget = 10000,
    this.accommodationBudget = 15000,
    this.experiencesBudget = 10000,
    this.peopleCount = 2,
    Map<String, double>? themePercentages,
    this.hasPet = false,
    this.seniorCitizens = false,
    this.vegetarianOnly = false,
  }) : themePercentages = themePercentages ?? {};
}

class ItineraryFiltersWidget extends StatefulWidget {
  final ItineraryFilters initialFilters;
  final Function(ItineraryFilters) onApply;

  const ItineraryFiltersWidget({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<ItineraryFiltersWidget> createState() => _ItineraryFiltersWidgetState();
}

class _ItineraryFiltersWidgetState extends State<ItineraryFiltersWidget> {
  late ItineraryFilters _filters;
  bool _isUpdatingMain = false;
  bool _isUpdatingSub = false;

  @override
  void initState() {
    super.initState();
    _filters = ItineraryFilters(
      mainBudget: widget.initialFilters.mainBudget,
      travelBudget: widget.initialFilters.travelBudget,
      foodBudget: widget.initialFilters.foodBudget,
      accommodationBudget: widget.initialFilters.accommodationBudget,
      experiencesBudget: widget.initialFilters.experiencesBudget,
      peopleCount: widget.initialFilters.peopleCount,
      themePercentages: Map.from(widget.initialFilters.themePercentages),
      hasPet: widget.initialFilters.hasPet,
      seniorCitizens: widget.initialFilters.seniorCitizens,
      vegetarianOnly: widget.initialFilters.vegetarianOnly,
    );
  }

  void _updateMainBudget(double value) {
    if (_isUpdatingSub) return;
    _isUpdatingMain = true;
    setState(() {
      final oldTotal = _filters.travelBudget + _filters.foodBudget + _filters.accommodationBudget + _filters.experiencesBudget;
      if (oldTotal > 0) {
        final ratio = value / oldTotal;
        _filters.travelBudget *= ratio;
        _filters.foodBudget *= ratio;
        _filters.accommodationBudget *= ratio;
        _filters.experiencesBudget *= ratio;
      }
      _filters.mainBudget = value;
    });
    _isUpdatingMain = false;
  }

  void _updateSubBudgets() {
    if (_isUpdatingMain) return;
    _isUpdatingSub = true;
    setState(() {
      _filters.mainBudget = _filters.travelBudget + _filters.foodBudget + _filters.accommodationBudget + _filters.experiencesBudget;
    });
    _isUpdatingSub = false;
  }

  double get _themeTotal => _filters.themePercentages.values.fold(0.0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMainBudget(),
            const SizedBox(height: 24),
            _buildSubBudgets(),
            const SizedBox(height: 24),
            _buildPerDayBreakdown(),
            const Divider(height: 32),
            _buildPeopleSelector(),
            const Divider(height: 32),
            _buildThemeToggles(),
            const Divider(height: 32),
            _buildSpecialRequirements(),
            const SizedBox(height: 24),
            _buildApplyButton(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text('Refine Your Trip', style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }

  Widget _buildMainBudget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Budget', style: Theme.of(context).textTheme.titleMedium),
            Text('₹${_filters.mainBudget.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        Slider(
          value: _filters.mainBudget,
          min: 5000,
          max: 200000,
          divisions: 195,
          label: '₹${_filters.mainBudget.toInt()}',
          onChanged: _updateMainBudget,
        ),
      ],
    );
  }

  Widget _buildSubBudgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        _buildSubSlider('Travel', _filters.travelBudget, (v) {
          setState(() => _filters.travelBudget = v);
          _updateSubBudgets();
        }),
        _buildSubSlider('Food', _filters.foodBudget, (v) {
          setState(() => _filters.foodBudget = v);
          _updateSubBudgets();
        }),
        _buildSubSlider('Accommodation', _filters.accommodationBudget, (v) {
          setState(() => _filters.accommodationBudget = v);
          _updateSubBudgets();
        }),
        _buildSubSlider('Experiences', _filters.experiencesBudget, (v) {
          setState(() => _filters.experiencesBudget = v);
          _updateSubBudgets();
        }),
      ],
    );
  }

  Widget _buildSubSlider(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text('₹${value.toInt()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 100000,
            divisions: 200,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPerDayBreakdown() {
    final days = 5;
    final perDay = _filters.mainBudget / days;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Per Day Budget', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          Text('₹${perDay.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildPeopleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of People', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _filters.peopleCount > 1 ? () => setState(() => _filters.peopleCount--) : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${_filters.peopleCount}', style: Theme.of(context).textTheme.titleLarge),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _filters.peopleCount < 10 ? () => setState(() => _filters.peopleCount++) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeToggles() {
    final themes = ['Heritage', 'Nightlife', 'Adventure', 'Food', 'Nature'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trip Themes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_themeTotal > 100)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.error),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, size: 16, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Expanded(child: Text('Theme percentages exceed 100%', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error))),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: themes.map((theme) => _buildThemeChip(theme)).toList(),
        ),
        const SizedBox(height: 12),
        ...themes.where((t) => _filters.themePercentages.containsKey(t)).map((t) => _buildThemeSlider(t)),
      ],
    );
  }

  Widget _buildThemeChip(String theme) {
    final isSelected = _filters.themePercentages.containsKey(theme);
    return FilterChip(
      label: Text(theme),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _filters.themePercentages[theme] = 20;
          } else {
            _filters.themePercentages.remove(theme);
          }
        });
      },
    );
  }

  Widget _buildThemeSlider(String theme) {
    final value = _filters.themePercentages[theme] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(theme, style: Theme.of(context).textTheme.bodySmall),
              Text('${value.toInt()}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (v) => setState(() => _filters.themePercentages[theme] = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Special Requirements', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text('Traveling with Pet', style: Theme.of(context).textTheme.bodyMedium),
          value: _filters.hasPet,
          onChanged: (v) => setState(() => _filters.hasPet = v ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          title: Text('Senior Citizens', style: Theme.of(context).textTheme.bodyMedium),
          value: _filters.seniorCitizens,
          onChanged: (v) => setState(() => _filters.seniorCitizens = v ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          title: Text('Vegetarian Only', style: Theme.of(context).textTheme.bodyMedium),
          value: _filters.vegetarianOnly,
          onChanged: (v) => setState(() => _filters.vegetarianOnly = v ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildApplyButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => widget.onApply(_filters),
        icon: const Icon(Icons.refresh),
        label: const Text('Apply & Regenerate'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
        ),
      ),
    );
  }
}
