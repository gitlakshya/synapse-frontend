# Accessibility Quick Reference

## Adding Semantics to Widgets

### Buttons
```dart
Semantics(
  label: 'Action description',
  button: true,
  hint: 'What happens when pressed',
  child: ElevatedButton(...)
)
```

### Text Fields
```dart
Semantics(
  label: 'Field name',
  textField: true,
  child: TextField(...)
)
```

### Images
```dart
Semantics(
  label: 'Image description',
  image: true,
  child: Image(...)
)
```

### Sliders
```dart
Semantics(
  label: 'Slider name',
  value: 'Current value',
  slider: true,
  child: Slider(...)
)
```

### Selection Controls
```dart
Semantics(
  label: 'Option name',
  selected: isSelected,
  button: true,
  child: FilterChip(...)
)
```

## Adding Tooltips
```dart
Tooltip(
  message: 'Helpful description',
  child: IconButton(...)
)
```

## Keyboard Navigation
```dart
Focus(
  focusNode: _focusNode,
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        // Handle left arrow
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  },
  child: YourWidget(),
)
```

## Focus Indicators
```dart
Focus(
  child: Builder(
    builder: (context) {
      final isFocused = Focus.of(context).hasFocus;
      return Container(
        decoration: BoxDecoration(
          border: isFocused 
            ? Border.all(color: Colors.blue, width: 2) 
            : null,
        ),
        child: YourWidget(),
      );
    },
  ),
)
```

## Testing
```bash
# Run with screen reader
flutter run -d chrome

# Test keyboard navigation:
# - Tab through elements
# - Arrow keys for carousels
# - Enter/Space to activate
```

## Checklist
- [ ] All buttons have labels
- [ ] All images have descriptions
- [ ] All form fields have labels
- [ ] Tooltips on icon buttons
- [ ] Focus indicators visible
- [ ] Keyboard shortcuts work
