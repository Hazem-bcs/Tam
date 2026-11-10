import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/maps/presentation/bloc/map_picker_cubit.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/pages/map_location_picker_page.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/maps/presentation/widgets/tam_map_canvas.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../support/preview_fonts.dart';
import 'maps_test_support.dart';

const capture = bool.fromEnvironment('CAPTURE_MAPS_UI');

class MemoryTiles extends TileProvider {
  MemoryTiles(this.bytes);
  final Uint8List bytes;
  int disposed = 0;
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(bytes);
  @override
  void dispose() {
    disposed++;
  }
}

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  String locale = 'ar',
  double scale = 1,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: capture ? previewTheme() : AppTheme.light,
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: RepaintBoundary(key: const Key('maps-preview'), child: child),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

Future<void> shot(WidgetTester tester, String name) async {
  if (capture) {
    await expectLater(
      find.byKey(const Key('maps-preview')),
      matchesGoldenFile(
        '../../../../../docs/engineering/deliveries/W4-MAPS/screenshots/$name.png',
      ),
    );
  }
}

void main() {
  setUpAll(() => loadPreviewFonts(enabled: capture));
  for (final language in ['ar', 'en']) {
    for (final size in [
      const Size(320, 740),
      const Size(390, 844),
      const Size(800, 1000),
      const Size(844, 390),
    ]) {
      testWidgets(
        '$language $size pin, label, keyboard and confirm stay reachable',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetViewInsets);
          final repo = MapsProbe(), device = LocationProbe();
          final deps = MapsDependencies(
            configuration: const MapConfiguration(),
            repository: repo,
            deviceLocation: device,
          );
          final cubit = MapPickerCubit(repo, device, language: language);
          addTearDown(cubit.close);
          await pump(
            tester,
            BlocProvider.value(
              value: cubit,
              child: MapLocationPickerPage(dependencies: deps),
            ),
            locale: language,
            scale: size.width == 390 ? 1 : 2,
          );
          expect(find.byType(FlutterMap), findsOneWidget);
          expect(find.byType(TileLayer), findsNothing);
          expect(device.calls, 0);
          await shot(tester, 'picker-$language-${size.width.toInt()}');
          final map = find.byType(FlutterMap);
          await Scrollable.ensureVisible(tester.element(map), alignment: 0.5);
          await tester.pumpAndSettle();
          await tester.tapAt(tester.getCenter(map));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpAndSettle();
          expect(cubit.state.point, isNotNull);
          final label = find.byKey(const Key('map-location-label'));
          final position = tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position;
          position.jumpTo(position.maxScrollExtent);
          await tester.pumpAndSettle();
          await tester.ensureVisible(label);
          await tester.enterText(
            label,
            language == 'ar' ? 'أمام مدخل المبنى' : 'At the building entrance',
          );
          tester.view.viewInsets = const FakeViewPadding(bottom: 180);
          await tester.pumpAndSettle();
          expect(cubit.state.canConfirm, isTrue);
          expect(find.byKey(const Key('map-confirm-location')), findsOneWidget);
          await shot(tester, 'keyboard-$language-${size.width.toInt()}');
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
  testWidgets(
    'configured tile renderer and polyline use injectable image data, no public requests',
    (tester) async {
      final bytes = await tester.runAsync<Uint8List>(() async {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawColor(
          AppTheme.light.colorScheme.surfaceContainer,
          BlendMode.src,
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(256, 256);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        picture.dispose();
        return data!.buffer.asUint8List();
      });
      final provider = MemoryTiles(bytes!);
      await pump(
        tester,
        Scaffold(
          body: Center(
            child: SizedBox(
              height: 400,
              child: TamMapCanvas(
                configuration: const MapConfiguration(
                  tileUrl: 'https://tiles.test.invalid/{z}/{x}/{y}.png',
                ),
                origin: origin,
                destination: destination,
                route: routeValue(origin, destination),
                tileProviderFactory: (_) => provider,
              ),
            ),
          ),
        ),
        settle: false,
      );
      await tester.runAsync(
        () => precacheImage(
          MemoryImage(bytes),
          tester.element(find.byType(TamMapCanvas)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TileLayer), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await shot(tester, 'configured-renderer-fixture');
      await tester.pumpWidget(const SizedBox());
      expect(provider.disposed, 1);
    },
  );
  testWidgets('driver updates do not refetch a route; new endpoints do', (
    tester,
  ) async {
    final repo = MapsProbe(),
        deps = MapsDependencies(
          configuration: const MapConfiguration(),
          repository: MapsProbe(),
          deviceLocation: LocationProbe(),
        );
    Widget content(TripLocation location) => MapsScope(
      dependencies: MapsDependencies(
        configuration: deps.configuration,
        repository: repo,
        deviceLocation: deps.deviceLocation,
      ),
      child: Scaffold(
        body: RouteMapView(
          origin: origin,
          destination: destination,
          driver: location.point,
        ),
      ),
    );
    await pump(tester, content(TripLocation(label: 'driver', point: origin)));
    expect(repo.routes, 1);
    await pump(
      tester,
      content(TripLocation(label: 'driver', point: destination)),
    );
    expect(repo.routes, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
