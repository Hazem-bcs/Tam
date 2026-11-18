import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/preferences/app_preferences.dart';

enum AppPreferencesError { restore, save }

final class AppPreferencesState {
  const AppPreferencesState({
    this.preferences = const AppPreferences(),
    this.busy = false,
    this.error,
  });

  final AppPreferences preferences;
  final bool busy;
  final AppPreferencesError? error;
}

/// Serializes restoration and rapid changes so late disk writes never win.
final class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit({
    AppPreferencesRepository? repository,
    AppPreferences initial = const AppPreferences(),
  }) : _repository = repository,
       _hydrated = repository == null,
       super(AppPreferencesState(preferences: initial));

  final AppPreferencesRepository? _repository;
  Future<void> _pending = Future.value();
  bool _hydrated;

  Future<bool> _enqueue(Future<bool> Function() operation) {
    final result = _pending.then<bool>((_) => isClosed ? false : operation());
    _pending = result.then<void>((_) {});
    return result;
  }

  Future<bool> restore() => _enqueue(_restore);

  Future<bool> _restore() async {
    if (_repository == null) return true;
    emit(AppPreferencesState(preferences: state.preferences, busy: true));
    try {
      final restored = await _repository.load();
      _hydrated = true;
      if (!isClosed) emit(AppPreferencesState(preferences: restored));
      return true;
    } catch (_) {
      _hydrated = false;
      if (!isClosed) {
        emit(
          AppPreferencesState(
            preferences: state.preferences,
            error: AppPreferencesError.restore,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> setLanguage(String code) {
    if (!const ['ar', 'en'].contains(code)) {
      throw ArgumentError.value(code, 'code', 'Supported languages: ar, en');
    }
    return _change((value) => value.copyWith(languageCode: code));
  }

  Future<bool> setAppearance(AppAppearance value) =>
      _change((current) => current.copyWith(appearance: value));

  Future<bool> setFontSize(AppFontSize value) =>
      _change((current) => current.copyWith(fontSize: value));

  Future<bool> _change(AppPreferences Function(AppPreferences) update) =>
      _enqueue(() async {
        // Never replace preferences that could not yet be read with defaults.
        if (!_hydrated && !await _restore()) return false;
        if (isClosed) return false;
        final previous = state.preferences;
        final next = update(previous);
        emit(AppPreferencesState(preferences: next, busy: true));
        try {
          await _repository?.save(next);
          if (!isClosed) emit(AppPreferencesState(preferences: next));
          return true;
        } catch (_) {
          if (!isClosed) {
            emit(
              AppPreferencesState(
                preferences: previous,
                error: AppPreferencesError.save,
              ),
            );
          }
          return false;
        }
      });
}
