# Image Caching Quick Reference

## Import
```dart
import '../utils/image_helper.dart';
```

## Usage

### List Thumbnails (80x80 to 120x120)
```dart
ListTile(
  leading: cachedThumbnail(
    imageUrl,
    size: 80,  // Default 80x80
  ),
)
```

### Card Images (Custom Size)
```dart
Container(
  child: cachedImage(
    imageUrl,
    width: 300,
    height: 200,
    fit: BoxFit.cover,
  ),
)
```

### Hero/Banner Images (Full Width)
```dart
cachedHeroImage(
  imageUrl,
  height: 400,
)
```

## Features
- ✅ Automatic memory caching (2x display size)
- ✅ Disk caching (3x display size, max 1200px)
- ✅ Progressive loading with fade-in
- ✅ Theme-aware placeholders
- ✅ Graceful error handling
- ✅ Optimized for smooth scrolling

## Don't Use
❌ `Image.network()` - No caching, poor performance
❌ `FadeInImage()` - Limited caching control
❌ Direct network calls without caching

## CDN Optimization
```dart
// Add size parameters to URLs
'https://images.unsplash.com/photo-id?w=800&h=600&q=80'
```
