import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/domain/profile_photo_picker.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_profile_editor.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

import 'settings_page_test.dart' show FakeNavigation, testApp;

class TestPhotoPicker implements ProfilePhotoPicker {
  TestPhotoPicker(this.bytes, {this.fail = false});
  final Uint8List? bytes;
  final bool fail;
  @override
  Future<Uint8List?> pickPhoto() async {
    if (fail) throw const ProfilePhotoFailure();
    return bytes;
  }
}

void main() {
  test(
    'photo and name save atomically; failures preserve saved profile',
    () async {
      final repo = MockSettingsRepository();
      final cubit = SettingsCubit(repo);
      addTearDown(cubit.close);
      await cubit.load();
      final original = cubit.state.profile!.displayName;
      final bytes = Uint8List.fromList([1, 2, 3]);
      cubit.nameChanged('New Name');
      repo.failNextProfileSave = true;
      expect(await cubit.saveName(avatarBytes: bytes), false);
      expect((await repo.loadProfile()).displayName, original);
      expect((await repo.loadProfile()).avatarBytes, isNull);
      expect(await cubit.saveName(avatarBytes: bytes), true);
      bytes[0] = 9;
      expect((await repo.loadProfile()).displayName, 'New Name');
      expect((await repo.loadProfile()).avatarBytes, [1, 2, 3]);
      expect(
        (await MockSettingsRepository().loadProfile()).avatarBytes,
        isNull,
      );
    },
  );

  test('invalid name never saves photo', () async {
    final repo = MockSettingsRepository();
    final cubit = SettingsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.nameChanged('X');
    expect(await cubit.saveName(avatarBytes: Uint8List.fromList([1])), false);
    expect(cubit.state.validationError, true);
    expect((await repo.loadProfile()).avatarBytes, isNull);
  });

  for (final fail in [false, true]) {
    testWidgets(
      'picker ${fail ? 'failure' : 'cancellation'} never saves a photo',
      (tester) async {
        final locale = AppLocaleController();
        addTearDown(locale.dispose);
        final repo = MockSettingsRepository();
        await tester.pumpWidget(
          testApp(
            locale: locale,
            navigation: FakeNavigation(),
            repository: repo,
            photoPicker: TestPhotoPicker(null, fail: fail),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('تعديل الاسم'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('settings-profile-photo')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TamButton>(find.byKey(const Key('settings-profile-save')))
              .onPressed,
          isNull,
        );
        expect((await repo.loadProfile()).avatarBytes, isNull);
        expect(
          find.textContaining('تعذر اختيار الصورة'),
          fail ? findsOneWidget : findsNothing,
        );
      },
    );
  }

  testWidgets('photo-only save closes popup and appears when reopened', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final repo = MockSettingsRepository();
    final photo = File('assets/notifications/account.webp').readAsBytesSync();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: repo,
        photoPicker: TestPhotoPicker(photo),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-profile-photo')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('settings-profile-save')));
    await tester.tap(find.byKey(const Key('settings-profile-save')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsProfileEditor), findsNothing);
    expect((await repo.loadProfile()).avatarBytes, photo);
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(SettingsProfileEditor),
        matching: find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is MemoryImage,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('discard selected photo leaves saved avatar unchanged', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final repo = MockSettingsRepository();
    final photo = File('assets/notifications/account.webp').readAsBytesSync();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: repo,
        photoPicker: TestPhotoPicker(photo),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-profile-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('إلغاء'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تجاهل التغييرات'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsProfileEditor), findsNothing);
    expect((await repo.loadProfile()).avatarBytes, isNull);
  });
}
