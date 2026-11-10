import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

class MapSelectionDetails extends StatefulWidget {
  const MapSelectionDetails({
    super.key,
    required this.label,
    required this.point,
    required this.onLabel,
  });
  final String label;
  final GeoPoint? point;
  final ValueChanged<String> onLabel;
  @override
  State<MapSelectionDetails> createState() => _MapSelectionDetailsState();
}

class _MapSelectionDetailsState extends State<MapSelectionDetails> {
  late final _label = TextEditingController(text: widget.label);
  @override
  void didUpdateWidget(MapSelectionDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_label.text != widget.label) {
      _label.value = TextEditingValue(
        text: widget.label,
        selection: TextSelection.collapsed(offset: widget.label.length),
      );
    }
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), point = widget.point;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.mapsTapHint, style: Theme.of(context).textTheme.bodySmall),
        if (point != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Directionality(
            textDirection: TextDirection.ltr,
            child: SelectableText(
              '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        TamTextField(
          key: const Key('map-location-label'),
          labelText: l.mapsAddressLabel,
          hintText: l.mapsAddressHint,
          controller: _label,
          onChanged: widget.onLabel,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
