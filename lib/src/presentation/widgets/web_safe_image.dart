import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

class WebSafeImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  WebSafeImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  }) {
    if (kIsWeb && url.isNotEmpty) {
      final String viewId = 'img-${url.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final element = web.HTMLImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = _boxFitToHtml(fit);

        element.addEventListener(
          'error',
          ((web.Event e) {
            element.src =
                'https://via.placeholder.com/400x300?text=Error+Loading+Image';
          }).toJS,
        );

        return element;
      });
    }
  }

  String _boxFitToHtml(BoxFit fit) {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'scale-down';
      case BoxFit.fitHeight:
        return 'scale-down';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return errorWidget ?? Container(color: Colors.grey[300]);
    }

    if (kIsWeb) {
      return SizedBox(
        width: width,
        height: height,
        child: HtmlElementView(viewType: 'img-${url.hashCode}'),
      );
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(color: Colors.grey[300]);
      },
    );
  }
}
