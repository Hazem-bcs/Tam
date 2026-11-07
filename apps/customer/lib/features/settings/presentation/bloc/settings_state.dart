import 'package:tam_customer/features/settings/domain/settings_models.dart';

enum SettingsActivity { loading, ready, savingName, savingPreferences }

enum SettingsErrorTarget { load, name, preferences }

const _unchanged = Object();

final class SettingsState {
  const SettingsState({
    this.activity = SettingsActivity.loading,
    this.profile,
    this.preferences,
    this.draftName = '',
    this.draftNotificationsEnabled = false,
    this.error,
    this.errorTarget,
    this.validationError = false,
    this.successAction,
  });

  final SettingsActivity activity;
  final SettingsProfile? profile;
  final SettingsPreferences? preferences;
  final String draftName;
  final bool draftNotificationsEnabled;
  final SettingsFailureCode? error;
  final SettingsErrorTarget? errorTarget;
  final bool validationError;
  final String? successAction;

  bool get isReady => profile != null && preferences != null;
  bool get isBusy => activity != SettingsActivity.ready;
  bool get nameDirty => isReady && draftName != profile!.displayName;
  bool get notificationsDirty =>
      isReady &&
      draftNotificationsEnabled != preferences!.accountNotificationsEnabled;
  bool get hasUnsavedChanges => nameDirty || notificationsDirty;

  SettingsState copyWith({
    SettingsActivity? activity,
    SettingsProfile? profile,
    SettingsPreferences? preferences,
    String? draftName,
    bool? draftNotificationsEnabled,
    Object? error = _unchanged,
    Object? errorTarget = _unchanged,
    bool? validationError,
    Object? successAction = _unchanged,
  }) => SettingsState(
    activity: activity ?? this.activity,
    profile: profile ?? this.profile,
    preferences: preferences ?? this.preferences,
    draftName: draftName ?? this.draftName,
    draftNotificationsEnabled:
        draftNotificationsEnabled ?? this.draftNotificationsEnabled,
    error: identical(error, _unchanged)
        ? this.error
        : error as SettingsFailureCode?,
    errorTarget: identical(errorTarget, _unchanged)
        ? this.errorTarget
        : errorTarget as SettingsErrorTarget?,
    validationError: validationError ?? this.validationError,
    successAction: identical(successAction, _unchanged)
        ? this.successAction
        : successAction as String?,
  );
}
