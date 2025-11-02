# Responsive Design Quick Reference

## Import
```dart
import '../utils/responsive.dart';
```

## Breakpoint Checks
```dart
// Check device type
final isMobile = Responsive.isMobile(context);   // < 768px
final isTablet = Responsive.isTablet(context);   // 768-1199px
final isDesktop = Responsive.isDesktop(context); // ≥ 1200px
```

## Adaptive Padding
```dart
// Automatic padding: 16px (mobile), 24px (tablet), 40px (desktop)
Padding(
  padding: Responsive.padding(context),
  child: Content(),
)
```

## Font Scaling
```dart
// Respects user's text scale factor
Text(
  'Title',
  style: TextStyle(
    fontSize: Responsive.fontSize(context, 24),
  ),
)
```

## Layout Switching
```dart
// Desktop: Side-by-side
// Mobile: Stacked
Responsive.isDesktop(context)
  ? Row(children: [Content(), Sidebar()])
  : Column(children: [Content(), SidebarButton()])
```

## Bottom Sheet Pattern
```dart
// Collapse sidebar to bottom sheet on mobile
ElevatedButton(
  onPressed: () => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      child: Sidebar(),
    ),
  ),
  child: Text('View Details'),
)
```

## Responsive Grid
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: Responsive.isMobile(context) ? 1 : 
                    Responsive.isTablet(context) ? 2 : 3,
  ),
)
```

## Testing Breakpoints
```bash
# Chrome DevTools
flutter run -d chrome
# Press F12 → Toggle device toolbar (Ctrl+Shift+M)
# Test: 375×812, 768×1024, 1024×768, 1366×768
```

## Common Patterns
```dart
// Adaptive width
width: Responsive.isMobile(context) ? double.infinity : 600

// Conditional rendering
if (Responsive.isDesktop(context)) DesktopWidget()

// Shortened labels
label: Responsive.isMobile(context) ? 'Edit' : 'Edit Inputs'
```
