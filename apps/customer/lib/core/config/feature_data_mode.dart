enum FeatureDataMode { mock, api }

enum CustomerFeature {
  home,
  rideRequest,
  trips,
  notifications,
  settings,
  addresses,
  activeTrip,
}

/// Parsed at composition; widgets and feature states never select the mode.
final class FeatureDataModes {
  const FeatureDataModes({
    this.defaultMode = FeatureDataMode.mock,
    this.overrides = const {},
  });

  factory FeatureDataModes.parse({
    required String defaultValue,
    Map<CustomerFeature, String> overrides = const {},
  }) => FeatureDataModes(
    defaultMode: _parse(defaultValue),
    overrides: Map.unmodifiable({
      for (final entry in overrides.entries)
        if (entry.value.isNotEmpty) entry.key: _parse(entry.value),
    }),
  );
  final FeatureDataMode defaultMode;
  final Map<CustomerFeature, FeatureDataMode> overrides;
  FeatureDataMode forFeature(CustomerFeature feature) =>
      overrides[feature] ?? defaultMode;
  static FeatureDataMode _parse(String value) => switch (value) {
    'mock' => FeatureDataMode.mock,
    'api' => FeatureDataMode.api,
    _ => throw ArgumentError.value(value, 'data mode', 'Expected mock or api'),
  };
}
