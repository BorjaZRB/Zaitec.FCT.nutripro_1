import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit fit;
  final BorderRadius? radius;
  final String? heroTag;

  const NetImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final core = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => const SizedBox(
        width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
      fadeInDuration: const Duration(milliseconds: 250),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );

    Widget child = radius != null ? ClipRRect(borderRadius: radius!, child: core) : core;
    if (heroTag != null) child = Hero(tag: heroTag!, child: child);
    return child;
  }
}
