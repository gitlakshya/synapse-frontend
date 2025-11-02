# Animations Quick Reference

## Import
```dart
import '../utils/animations_helper.dart';
import '../utils/page_transitions.dart';
```

## Page Transitions
```dart
// Fade + Slide (most pages)
Navigator.push(
  context,
  FadeSlidePageRoute(page: NextScreen()),
);

// Scale + Fade (modals)
Navigator.push(
  context,
  ScalePageRoute(page: LoginScreen()),
);
```

## List Entrance Animations
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return StaggeredListAnimation(
      index: index,
      delay: 100, // ms between items
      child: ListItem(),
    );
  },
)
```

## Hover Effects
```dart
// Card hover with lift
HoverScaleCard(
  scale: 1.02,
  onTap: () {},
  child: Card(),
)

// Manual hover control
MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
  ),
)
```

## Button Press Effect
```dart
AnimatedButton(
  onPressed: () {},
  child: Text('Click Me'),
)
```

## Expansion Animation
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  height: _isExpanded ? 200 : 0,
  child: Content(),
)
```

## Animation Timing
- **Page transitions:** 600ms
- **Hover effects:** 200ms
- **Button press:** 100ms
- **List entrance:** 400ms + (index × 100ms)

## Curves
```dart
Curves.easeOut    // Entrance
Curves.easeInOut  // Transitions
Curves.easeIn     // Exit
```

## Performance Tips
- Use `const` constructors
- Animate Transform, not Layout
- Use RepaintBoundary for complex widgets
- Profile with DevTools
