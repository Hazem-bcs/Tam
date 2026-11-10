import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class PrivateTileLayer extends StatefulWidget {
  const PrivateTileLayer({
    super.key,
    required this.url,
    required this.onLoaded,
    required this.onFailure,
    required this.providerFactory,
  });
  final String url;
  final VoidCallback onLoaded, onFailure;
  final TileProvider Function(String) providerFactory;
  @override
  State<PrivateTileLayer> createState() => _PrivateTileLayerState();
}

class _PrivateTileLayerState extends State<PrivateTileLayer> {
  late final _provider = widget.providerFactory(widget.url);
  bool _loaded = false, _failed = false;
  void _notify(bool success) {
    if ((success && _loaded) || (!success && _failed)) return;
    if (success) {
      _loaded = true;
    } else {
      _failed = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) (success ? widget.onLoaded : widget.onFailure)();
    });
  }

  @override
  Widget build(BuildContext context) => TileLayer(
    urlTemplate: widget.url,
    tileProvider: _provider,
    userAgentPackageName: 'com.tam.tam_customer',
    maxNativeZoom: 19,
    tileDisplay: const TileDisplay.instantaneous(),
    errorTileCallback: (_, _, _) => _notify(false),
    tileBuilder: (context, child, tile) {
      if (tile.imageInfo != null) _notify(true);
      return child;
    },
  );
  // TileLayer owns/disposes the supplied provider and its HTTP client.
}
