import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/domain/settings_models.dart';
import 'package:tam_customer/features/settings/domain/settings_repository.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';

final class ControlledSettingsRepository implements SettingsRepository {
  final delegate = MockSettingsRepository();
  Completer<void>? loadGate;
  Completer<void>? saveGate;
  int profileLoads = 0;
  int nameSaves = 0;

  @override
  Future<SettingsProfile> loadProfile() async {
    profileLoads++;
    await loadGate?.future;
    return delegate.loadProfile();
  }

  @override
  Future<SettingsPreferences> loadPreferences() => delegate.loadPreferences();

  @override
  Future<SettingsProfile> updateDisplayName(
    String name, {
    Uint8List? avatarBytes,
  }) async {
    nameSaves++;
    await saveGate?.future;
    return delegate.updateDisplayName(name, avatarBytes: avatarBytes);
  }

  @override
  Future<SettingsPreferences> updatePreferences(SettingsPreferences value) =>
      delegate.updatePreferences(value);
}

void main() {
  test('duplicate load does not issue stale requests', () async {
    final repository = ControlledSettingsRepository()..loadGate = Completer();
    final cubit = SettingsCubit(repository);
    addTearDown(cubit.close);
    final pending = cubit.load();
    await cubit.load();
    expect(repository.profileLoads, 1);
    repository.loadGate!.complete();
    await pending;
    expect(cubit.state.isReady, true);
  });

  test('reload cannot overwrite unsaved edits or a pending save', () async {
    final repository = ControlledSettingsRepository();
    final cubit = SettingsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.nameChanged('Unsaved Name');
    await cubit.load();
    expect(repository.profileLoads, 1);
    expect(cubit.state.draftName, 'Unsaved Name');

    repository.saveGate = Completer();
    final pending = cubit.saveName();
    await cubit.load();
    expect(await cubit.saveName(), false);
    cubit.nameChanged('Concurrent Edit');
    cubit.discardChanges();
    expect(repository.profileLoads, 1);
    expect(repository.nameSaves, 1);
    expect(cubit.state.draftName, 'Unsaved Name');
    repository.saveGate!.complete();
    expect(await pending, true);
    expect(cubit.state.profile!.displayName, 'Unsaved Name');
    expect(cubit.state.hasUnsavedChanges, false);
  });

  test(
    'discard reverts both drafts without changing repository data',
    () async {
      final repository = MockSettingsRepository()..failNextProfileSave = true;
      final cubit = SettingsCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      cubit.nameChanged('Uncommitted Name');
      cubit.notificationsChanged(false);
      expect(await cubit.saveName(), false);
      cubit.discardChanges();
      expect(cubit.state.hasUnsavedChanges, false);
      expect(cubit.state.error, isNull);
      expect(cubit.state.draftName, 'مستخدم تم');
      expect(cubit.state.draftNotificationsEnabled, true);
      expect((await repository.loadProfile()).displayName, 'مستخدم تم');
    },
  );

  test('completing after close does not emit into disposed state', () async {
    final repository = ControlledSettingsRepository()..loadGate = Completer();
    final cubit = SettingsCubit(repository);
    final pending = cubit.load();
    await cubit.close();
    repository.loadGate!.complete();
    await pending;
    expect(cubit.state.isReady, false);
  });
}
