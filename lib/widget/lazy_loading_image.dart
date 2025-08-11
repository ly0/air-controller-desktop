import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LazyLoadingImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final int? memCacheWidth;
  final BoxFit fit;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final double visibilityThreshold;

  const LazyLoadingImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.memCacheWidth,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.fadeInDuration = Duration.zero,
    this.fadeOutDuration = Duration.zero,
    this.visibilityThreshold = 0.01,
  }) : super(key: key);

  @override
  State<LazyLoadingImage> createState() => _LazyLoadingImageState();
}

class _LazyLoadingImageState extends State<LazyLoadingImage> {
  bool _shouldLoad = false;
  bool _hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.imageUrl),
      onVisibilityChanged: (VisibilityInfo info) {
        if (!_hasLoaded && info.visibleFraction >= widget.visibilityThreshold) {
          setState(() {
            _shouldLoad = true;
            _hasLoaded = true;
          });
        }
      },
      child: _shouldLoad
          ? CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: widget.fit,
              width: widget.width,
              height: widget.height,
              memCacheWidth: widget.memCacheWidth,
              fadeOutDuration: widget.fadeOutDuration,
              fadeInDuration: widget.fadeInDuration,
              errorWidget: (context, url, error) =>
                  widget.errorWidget ??
                  Container(
                    width: widget.width,
                    height: widget.height,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  ),
            )
          : Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
            ),
    );
  }
}