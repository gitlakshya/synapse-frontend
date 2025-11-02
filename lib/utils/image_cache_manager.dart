import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;

  const CachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth ?? (width != null ? (width! * 2).toInt() : null),
      memCacheHeight: cacheHeight ?? (height != null ? (height! * 2).toInt() : null),
      maxWidthDiskCache: (width != null ? (width! * 3).toInt() : 1200),
      maxHeightDiskCache: (height != null ? (height! * 3).toInt() : 1200),
      placeholder: (context, url) => Container(
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
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported,
          size: (width != null && width! < 100) ? 24 : 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }
}
