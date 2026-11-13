import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Shows a report photo, or an image icon when there is none.
///
/// * Supabase mode: [url] is the public https link from Storage.
/// * Local demo mode: [url] is the path of the picked file
///   (a blob: link on the web).
class ReportPhoto extends StatelessWidget {
  const ReportPhoto({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 12,
    this.iconSize = 24,
  });

  final String? url;
  final double? width;
  final double? height;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.image, size: iconSize, color: scheme.onSurfaceVariant),
    );

    final src = url;
    Widget child;
    if (src == null || src.isEmpty) {
      child = placeholder;
    } else if (kIsWeb || src.startsWith('http')) {
      child = Image.network(
        src,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, image, progress) {
          if (progress == null) return image;
          return Stack(
            alignment: Alignment.center,
            children: [
              placeholder,
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          );
        },
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    } else {
      child = Image.file(
        File(src),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }
}