import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool thumbnail;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.thumbnail = false,
  });

  @override
  Widget build(BuildContext context) {
    // Add thumbnail size parameter to Unsplash URLs
    final url = thumbnail && imageUrl.contains('unsplash.com')
        ? '$imageUrl&w=400&q=80'
        : imageUrl;

    return Semantics(
      label: 'Image',
      image: true,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: thumbnail ? 400 : null,
        memCacheHeight: thumbnail ? 300 : null,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Icon(Icons.image, size: 40, color: Colors.grey),
        ),
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
