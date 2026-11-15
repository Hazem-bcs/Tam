import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_map_colors.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import '../../../domain/maps_repository.dart';
import '../map_feedback.dart';
import 'native_vector_map.dart';
import 'vector_map_scene.dart';
import 'vector_map_style.dart';

/// Loads a bundled UI resource, as with an SVG or font. No public HTTP client,
/// auth credentials, booking rules or platform location engine live here.
class VectorMapSurface extends StatefulWidget {
  const VectorMapSurface({
    super.key,
    required this.configuration,
    this.origin,
    this.destination,
    this.driver,
    this.selection,
    this.route,
    this.onSelected,
    this.bottomInset,
    this.onLocate,
    this.locating = false,
  });
  final MapConfiguration configuration;
  final GeoPoint? origin, destination, driver, selection;
  final MapRoute? route;
  final ValueChanged<GeoPoint>? onSelected;
  final ValueListenable<double>? bottomInset;
  final VoidCallback? onLocate;
  final bool locating;
  @override
  State<VectorMapSurface> createState() => _VectorMapSurfaceState();
}

class _VectorMapSurfaceState extends State<VectorMapSurface> {
  AssetBundle? _bundle;
  Future<String>? _template;
  String? _raw, _style, _language;
  AppMapColors? _palette;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bundle = DefaultAssetBundle.of(context);
    if (_bundle != bundle) {
      _bundle = bundle;
      _load();
    }
  }

  @override
  void didUpdateWidget(VectorMapSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configuration.vectorStyleAsset !=
        widget.configuration.vectorStyleAsset) {
      _load();
    }
  }

  void _load() {
    if (!_supported) return;
    _raw = _style = null;
    _template = _bundle!.loadString(widget.configuration.vectorStyleAsset);
  }

  bool get _supported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_supported) {
      return Center(
        child: Text(l.mapsNativeUnavailable, textAlign: TextAlign.center),
      );
    }
    return FutureBuilder<String>(
      future: _template,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        try {
          if (snapshot.hasError) throw snapshot.error!;
          final palette = Theme.of(context).extension<AppMapColors>()!;
          final language = Localizations.localeOf(context).languageCode;
          if (_raw != snapshot.data ||
              _palette != palette ||
              _language != language) {
            _style = VectorMapStyle.build(snapshot.data!, palette, language);
            _raw = snapshot.data;
            _palette = palette;
            _language = language;
          }
          return NativeVectorMap(
            style: _style!,
            initialCenter: widget.configuration.initialCenter,
            scene: VectorMapScene(
              origin: widget.origin,
              destination: widget.destination,
              driver: widget.driver,
              selection: widget.selection,
              route: widget.route,
            ),
            onSelected: widget.onSelected,
            bottomInset: widget.bottomInset,
            onLocate: widget.onLocate,
            locating: widget.locating,
          );
        } catch (_) {
          return Center(
            child: MapFeedback(
              text: l.mapsTilesFailed,
              onRetry: () => setState(_load),
            ),
          );
        }
      },
    );
  }
}
