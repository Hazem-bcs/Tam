import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/domain/settings_models.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';

void main() {
  test('loading and independent draft tracking, then saved state', () async {
    final repository = MockSettingsRepository();
    final cubit = SettingsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.isReady, true);
    expect(cubit.state.hasUnsavedChanges, false);

    cubit.nameChanged('  Omar  Salim ');
    expect(cubit.state.nameDirty, true);
    expect(cubit.state.notificationsDirty, false);
    expect(await cubit.saveName(), true);
    expect(cubit.state.profile?.displayName, 'Omar Salim');
    expect(cubit.state.hasUnsavedChanges, false);

    cubit.notificationsChanged(false);
    expect(cubit.state.notificationsDirty, true);
    expect(await cubit.savePreferences(), true);
    expect(cubit.state.preferences?.accountNotificationsEnabled, false);
    expect(cubit.state.hasUnsavedChanges, false);
  });

  test('validation shows error without saving data', () async {
    final cubit = SettingsCubit(MockSettingsRepository());
    addTearDown(cubit.close);
    await cubit.load();
    cubit.nameChanged('x');
    expect(await cubit.saveName(), false);
    expect(cubit.state.validationError, true);
    expect(cubit.state.nameDirty, true);
    expect(cubit.state.profile?.displayName, 'مستخدم تم');
    cubit.nameChanged('Valid');
    expect(cubit.state.validationError, false);
  });

  test('failed name save preserves draft and supports retry', () async {
    final repository = MockSettingsRepository()..failNextProfileSave = true;
    final cubit = SettingsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.nameChanged('Valid New');
    expect(await cubit.saveName(), false);
    expect(cubit.state.error, SettingsFailureCode.saveFailed);
    expect(cubit.state.nameDirty, true);
    expect(cubit.state.profile?.displayName, 'مستخدم تم');
    expect(await cubit.saveName(), true);
    expect(cubit.state.nameDirty, false);
    expect(cubit.state.error, isNull);
  });

  test('failed notifications save preserves unsaved switch', () async {
    final repository = MockSettingsRepository()..failNextPreferencesSave = true;
    final cubit = SettingsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.notificationsChanged(false);
    expect(await cubit.savePreferences(), false);
    expect(cubit.state.notificationsDirty, true);
    expect(cubit.state.preferences?.accountNotificationsEnabled, true);
    expect(await cubit.savePreferences(), true);
    expect(cubit.state.notificationsDirty, false);
  });

  test('load error and retry do not manufacture profile data', () async {
    final repository = MockSettingsRepository()..failNextProfileLoad = true;
    final cubit = SettingsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.isReady, false);
    expect(cubit.state.error, SettingsFailureCode.serviceUnavailable);
    await cubit.load();
    expect(cubit.state.isReady, true);
    expect(cubit.state.error, isNull);
  });

  test(
    'new unsaved edit survives unrelated successful settings save',
    () async {
      final cubit = SettingsCubit(MockSettingsRepository());
      addTearDown(cubit.close);
      await cubit.load();
      cubit.nameChanged('Changed');
      cubit.notificationsChanged(false);
      expect(await cubit.savePreferences(), true);
      expect(cubit.state.nameDirty, true);
      expect(cubit.state.notificationsDirty, false);
    },
  );
}
