import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/preferences/app_preferences.dart';
import 'package:tam_customer/app/preferences/app_preferences_cubit.dart';
import 'package:tam_customer/app/preferences/cached_app_preferences_repository.dart';
import 'package:tam_customer/core/cache/local_cache_store.dart';

final class MemoryStore implements LocalCacheStore {
  final values = <String, CachedPayload>{};
  bool failRead = false;
  bool failWrite = false;
  Completer<void>? nextWrite;
  Completer<void>? nextRead;

  @override
  Future<CachedPayload?> read(String key) async {
    final gate = nextRead;
    nextRead = null;
    if (gate != null) await gate.future;
    if (failRead) throw StateError('read unavailable');
    return values[key];
  }

  @override
  Future<void> write(String key, String payload, DateTime fetchedAt) async {
    final gate = nextWrite;
    nextWrite = null;
    if (gate != null) await gate.future;
    if (failWrite) throw StateError('disk full');
    values[key] = CachedPayload(value: payload, fetchedAt: fetchedAt);
  }

  @override
  Future<void> remove(String key) async => values.remove(key);
  @override
  Future<void> clear() async => values.clear();
}

void main() {
  late MemoryStore store;
  late AppPreferencesCubit cubit;

  setUp(() {
    store = MemoryStore();
    cubit = AppPreferencesCubit(
      repository: CachedAppPreferencesRepository(store),
    );
  });
  tearDown(() => cubit.close());

  test(
    'first run defaults to Arabic/system independently of device locale',
    () async {
      await cubit.restore();
      expect(cubit.state.preferences.languageCode, 'ar');
      expect(cubit.state.preferences.appearance, AppAppearance.system);
      expect(cubit.state.preferences.fontSize, AppFontSize.standard);
    },
  );

  test('all choices survive a new controller/repository', () async {
    await cubit.restore();
    await cubit.setLanguage('en');
    await cubit.setAppearance(AppAppearance.dark);
    await cubit.setFontSize(AppFontSize.extraLarge);
    final reopened = AppPreferencesCubit(
      repository: CachedAppPreferencesRepository(store),
    );
    addTearDown(reopened.close);
    await reopened.restore();
    expect(reopened.state.preferences.languageCode, 'en');
    expect(reopened.state.preferences.appearance, AppAppearance.dark);
    expect(reopened.state.preferences.fontSize, AppFontSize.extraLarge);
  });

  test('v1 migration retains valid choices and unrelated data', () async {
    await store.write(
      CachedAppPreferencesRepository.storageKey,
      '{"version":1,"locale":"en","themeMode":"dark","textScale":1.15,"extra":"keep"}',
      DateTime.now(),
    );
    await store.write('account.notifications', 'unchanged', DateTime.now());
    await cubit.restore();
    expect(cubit.state.preferences.languageCode, 'en');
    expect(cubit.state.preferences.appearance, AppAppearance.dark);
    expect(cubit.state.preferences.fontSize, AppFontSize.large);
    await cubit.setFontSize(AppFontSize.small);
    final reopened = CachedAppPreferencesRepository(store);
    expect((await reopened.load()).fontSize, AppFontSize.small);
    final payload =
        jsonDecode(
              store.values[CachedAppPreferencesRepository.storageKey]!.value,
            )
            as Map;
    expect(payload['extra'], 'keep');
    expect(store.values['account.notifications']!.value, 'unchanged');
  });

  test(
    'malformed fields default independently and malformed JSON is safe',
    () async {
      await store.write(
        CachedAppPreferencesRepository.storageKey,
        '{"languageCode":"en","appearance":42,"fontSize":[]}',
        DateTime.now(),
      );
      await cubit.restore();
      expect(cubit.state.preferences.languageCode, 'en');
      expect(cubit.state.preferences.appearance, AppAppearance.system);
      await store.write(
        CachedAppPreferencesRepository.storageKey,
        '{bad',
        DateTime.now(),
      );
      await cubit.restore();
      expect(cubit.state.preferences.languageCode, 'ar');
    },
  );

  test(
    'read failure is recoverable; write failure restores previous choices',
    () async {
      store.failRead = true;
      expect(await cubit.restore(), false);
      expect(cubit.state.error, AppPreferencesError.restore);
      store.failRead = false;
      expect(await cubit.restore(), true);
      await cubit.setLanguage('en');
      store.failWrite = true;
      expect(await cubit.setLanguage('ar'), false);
      expect(cubit.state.preferences.languageCode, 'en');
      expect(cubit.state.error, AppPreferencesError.save);
      expect(
        (await CachedAppPreferencesRepository(store).load()).languageCode,
        'en',
      );
    },
  );

  test('failed restoration cannot overwrite unseen stored preferences', () async {
    await store.write(
      CachedAppPreferencesRepository.storageKey,
      '{"version":2,"languageCode":"en","appearance":"light","fontSize":"large","extra":"keep"}',
      DateTime.now(),
    );
    store.failRead = true;
    expect(await cubit.restore(), false);
    expect(await cubit.setAppearance(AppAppearance.dark), false);
    final unchanged =
        jsonDecode(
              store.values[CachedAppPreferencesRepository.storageKey]!.value,
            )
            as Map;
    expect(unchanged['appearance'], 'light');
    expect(cubit.state.error, AppPreferencesError.restore);
    store.failRead = false;
    expect(await cubit.setAppearance(AppAppearance.dark), true);
    final restored = await CachedAppPreferencesRepository(store).load();
    expect(restored.languageCode, 'en');
    expect(restored.fontSize, AppFontSize.large);
    expect(restored.appearance, AppAppearance.dark);
    expect(
      jsonDecode(
        store.values[CachedAppPreferencesRepository.storageKey]!.value,
      )['extra'],
      'keep',
    );
  });

  test(
    'rapid choices serialize behind pending save without overwriting fields',
    () async {
      await cubit.restore();
      final gate = Completer<void>();
      store.nextWrite = gate;
      final first = cubit.setAppearance(AppAppearance.dark);
      final second = cubit.setFontSize(AppFontSize.large);
      final third = cubit.setLanguage('en');
      await Future<void>.delayed(Duration.zero);
      gate.complete();
      expect(await Future.wait([first, second, third]), [true, true, true]);
      final restored = await CachedAppPreferencesRepository(store).load();
      expect(restored.appearance, AppAppearance.dark);
      expect(restored.fontSize, AppFontSize.large);
      expect(restored.languageCode, 'en');
    },
  );
}
