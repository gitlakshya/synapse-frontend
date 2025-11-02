import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Centralized cached image widget with fade-in animation and lazy loading
Widget cachedImage(
  String url, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  bool showPlaceholder = true,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    fadeInDuration: const Duration(milliseconds: 300),
    fadeOutDuration: const Duration(milliseconds: 200),
    placeholder: showPlaceholder
        ? (context, url) => Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
        : null,
    errorWidget: (context, url, error) => Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported,
        size: (width != null && width < 100) ? 24 : 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
    memCacheWidth: (width != null && width.isFinite) ? (width * 2).toInt() : null,
    memCacheHeight: (height != null && height.isFinite) ? (height * 2).toInt() : null,
    maxWidthDiskCache: (width != null && width.isFinite) ? (width * 3).toInt() : 1200,
    maxHeightDiskCache: (height != null && height.isFinite) ? (height * 3).toInt() : 1200,
  );
}

/// Thumbnail variant for list items (optimized for small sizes)
Widget cachedThumbnail(
  String url, {
  double size = 80,
  BoxFit fit = BoxFit.cover,
}) {
  return cachedImage(
    url,
    width: size,
    height: size,
    fit: fit,
  );
}

/// Hero image variant for full-width banners with fade-in
Widget cachedHeroImage(
  String url, {
  double? height,
  BoxFit fit = BoxFit.cover,
  VoidCallback? onLoadComplete,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    height: height,
    width: double.maxFinite,
    fit: fit,
    fadeInDuration: const Duration(milliseconds: 400),
    fadeOutDuration: const Duration(milliseconds: 200),
    imageBuilder: (context, imageProvider) {
      if (onLoadComplete != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onLoadComplete());
      }
      return Image(image: imageProvider, fit: fit, width: double.maxFinite, height: height);
    },
    placeholder: (context, url) => Container(
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    ),
    errorWidget: (context, url, error) => Container(
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
    memCacheHeight: (height != null && height.isFinite) ? (height * 2).toInt() : null,
    maxHeightDiskCache: (height != null && height.isFinite) ? (height * 3).toInt() : 1200,
  );
}
