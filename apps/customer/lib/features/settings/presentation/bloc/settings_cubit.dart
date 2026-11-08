import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/settings/domain/settings_models.dart';
import 'package:tam_customer/features/settings/domain/settings_repository.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';

/// Single source of truth for draft and saved account settings.
final class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;
  bool _loading = false;

  Future<void> load() async {
    if (isClosed ||
        _loading ||
        state.hasUnsavedChanges ||
        state.activity == SettingsActivity.savingName ||
        state.activity == SettingsActivity.savingPreferences) {
      return;
    }
    _loading = true;
    emit(
      state.copyWith(
        activity: SettingsActivity.loading,
        error: null,
        errorTarget: null,
        successAction: null,
      ),
    );
    try {
      final profile = await _repository.loadProfile();
      final preferences = await _repository.loadPreferences();
      if (isClosed) return;
      emit(
        SettingsState(
          activity: SettingsActivity.ready,
          profile: profile,
          preferences: preferences,
          draftName: profile.displayName,
          draftNotificationsEnabled: preferences.accountNotificationsEnabled,
        ),
      );
    } on SettingsFailure catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            activity: SettingsActivity.ready,
            error: e.code,
            errorTarget: SettingsErrorTarget.load,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            activity: SettingsActivity.ready,
            error: SettingsFailureCode.serviceUnavailable,
            errorTarget: SettingsErrorTarget.load,
          ),
        );
      }
    } finally {
      _loading = false;
    }
  }

  void discardChanges() {
    if (isClosed || !state.isReady || state.isBusy) return;
    emit(
      state.copyWith(
        draftName: state.profile!.displayName,
        draftNotificationsEnabled:
            state.preferences!.accountNotificationsEnabled,
        validationError: false,
        error: null,
        errorTarget: null,
        successAction: null,
      ),
    );
  }

  void nameChanged(String name) {
    if (!state.isReady || state.isBusy) return;
    emit(
      state.copyWith(
        draftName: name,
        error: null,
        errorTarget: null,
        validationError: false,
        successAction: null,
      ),
    );
  }

  void notificationsChanged(bool enabled) {
    if (!state.isReady || state.isBusy) return;
    emit(
      state.copyWith(
        draftNotificationsEnabled: enabled,
        error: null,
        errorTarget: null,
        successAction: null,
      ),
    );
  }

  Future<bool> saveName() async {
    if (!state.isReady || state.isBusy || !state.nameDirty) return false;
    if (!SettingsNameRules.isValid(state.draftName)) {
      emit(
        state.copyWith(validationError: true, error: null, errorTarget: null),
      );
      return false;
    }
    emit(
      state.copyWith(
        activity: SettingsActivity.savingName,
        validationError: false,
        error: null,
        errorTarget: null,
        successAction: null,
      ),
    );
    try {
      final updated = await _repository.updateDisplayName(state.draftName);
      if (isClosed) return false;
      emit(
        state.copyWith(
          activity: SettingsActivity.ready,
          profile: updated,
          draftName: updated.displayName,
          successAction: 'name',
        ),
      );
      return true;
    } on SettingsFailure catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            activity: SettingsActivity.ready,
            error: e.code,
            errorTarget: SettingsErrorTarget.name,
          ),
        );
      }
      return false;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            activity: SettingsActivity.ready,
            error: SettingsFailureCode.serviceUnavailable,
            errorTarget: SettingsErrorTarget.name,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> savePreferences() async {
    if (!state.isReady || state.isBusy || !state.notificationsDirty) {
      return false;
    }
    emit(
      state.copyWith(
        activity: SettingsActivity.savingPreferences,
        error: null,
        errorTarget: null,
        successAction: null,
      ),
    );
    try {
      final updated = await _repository.updatePreferences(
        SettingsPreferences(
          accountNotificationsEnabled: state.draftNotificationsEnabled,
        ),
      );
      if (isClosed) return false;
      emit(
        state.copyWith(
          activity: SettingsActivity.ready,
          preferences: updated,
          draftNotificationsEnabled: updated.accountNotificationsEnabled,
          successAction: 'preferences',
        ),
      );
      return true;
    } on SettingsFailure catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            activity: SettingsActivity.ready,
            error: e.code,
            errorTarget: SettingsErrorTarget.preferences,
          ),
        );
      }
      return false;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            activity: SettingsActivity.ready,
            error: SettingsFailureCode.serviceUnavailable,
            errorTarget: SettingsErrorTarget.preferences,
          ),
        );
      }
      return false;
    }
  }
}
