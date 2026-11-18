import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/native_vector_map.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/vector_map_surface.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import 'support/vector_platform_probe.dart';

void main() {
  setUp(() {
    final previous = MapLibrePlatform.createInstance;
    MapLibrePlatform.createInstance = VectorPlatformProbe.new;
    addTearDown(() => MapLibrePlatform.createInstance = previous);
  });
  const map = Scaffold(
    body: VectorMapSurface(
      configuration: MapConfiguration(
        vectorStyleAsset: MapConfiguration.libertyStyleAsset,
      ),
    ),
  );
  Widget app(GlobalKey<NavigatorState> navigator, {Widget? home}) =>
      MaterialApp(
        navigatorKey: navigator,
        builder: (context, child) =>
            DefaultAssetBundle(bundle: _StyleBundle(), child: child!),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home ?? const Scaffold(body: Text('home')),
      );
  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));

    await tester.pump();
  }

  testWidgets('surface waits for entrance and survives covering route', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navigator));
    navigator.currentState!.push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => map,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(NativeVectorMap), findsNothing);
    await finish(tester);
    expect(find.byType(NativeVectorMap), findsOneWidget);
    final surface = tester.element(find.byType(NativeVectorMap));
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('cover')),
      ),
    );
    await tester.pump();
    await finish(tester);
    navigator.currentState!.pop();
    await tester.pump();
    await finish(tester);
    expect(tester.element(find.byType(NativeVectorMap)), same(surface));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('popping during entrance leaves no delayed surface', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navigator));
    navigator.currentState!.push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => map,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    navigator.currentState!.pop();
    await tester.pump();
    await finish(tester);
    expect(find.byType(NativeVectorMap), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('zero-duration route creates the map without a timer', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(navigator));
    navigator.currentState!.push(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => map,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(NativeVectorMap), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('initial route does not wait for a nonexistent entrance', (
    tester,
  ) async {
    await tester.pumpWidget(app(GlobalKey<NavigatorState>(), home: map));
    await finish(tester);
    expect(find.byType(NativeVectorMap), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

class _StyleBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      '{"version":8,"sources":{},"layers":[]}';
  @override
  Future<ByteData> load(String key) async => ByteData(0);
}
