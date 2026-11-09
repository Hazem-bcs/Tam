import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/account_management/data/mock/mock_account_management_repository.dart';
import 'package:tam_customer/features/account_management/domain/account_management_repository.dart';
import 'package:tam_customer/features/account_management/presentation/bloc/account_management_cubit.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'account_test_support.dart';

void main() {
  test(
    'uncertain start freezes target and preserves operation ID across retries',
    () async {
      final r = AccountProbe();
      final c = AccountManagementCubit(r, action: AccountAction.changePhone);
      addTearDown(c.close);
      addTearDown(r.events.close);
      await c.load();
      final calls = <(String, AccountAction, String?)>[];
      r.onStart = (id, a, p) async {
        calls.add((id, a, p));
        throw const AccountFailure('NETWORK_ERROR', uncertain: true);
      };
      await c.start('0944444444');
      await c.start('0955555555');
      expect(calls[0], calls[1]);
      expect(c.state.locked, isTrue);
      c.restart();
      expect(c.state.locked, isTrue);
      expect(calls.first.$1, matches(RegExp(r'^[a-f0-9]{48}$')));
    },
  );
  test(
    'uncertain confirmation reconciles, normalizes digits and signs out only after receipt',
    () async {
      final trips = MockTripStore();
      final r = MockAccountManagementRepository(
        trips,
        phone: () => '+963912345678',
        now: () => accountNow,
      )..loseNextConfirm = true;
      final c = AccountManagementCubit(
        r,
        action: AccountAction.deleteAccount,
        now: () => accountNow,
      );
      addTearDown(c.close);
      addTearDown(r.dispose);
      addTearDown(trips.dispose);
      await c.load();
      await c.start('');
      await c.confirm('١٢٣٤٥٦');
      expect(c.state.locked, isTrue);
      expect(c.state.receipt, isNull);
      await c.confirm('000000');
      expect(c.state.receipt, isNotNull);
      expect(c.state.locked, isFalse);
    },
  );
  for (final invalid in ['operation', 'challenge', 'action']) {
    test('invalid $invalid acknowledgement stays unresolved', () async {
      final r = AccountProbe();
      final c = AccountManagementCubit(r, action: AccountAction.deleteAccount);
      addTearDown(c.close);
      addTearDown(r.events.close);
      await c.load();
      await c.start('');
      r.onConfirm = (id, op, code) async => AccountReceipt(
        operationId: invalid == 'operation' ? 'foreign' : op,
        challengeId: invalid == 'challenge' ? 'foreign' : id,
        action: invalid == 'action'
            ? AccountAction.changePhone
            : AccountAction.deleteAccount,
        completedAt: accountNow,
      );
      await c.confirm('123456');
      expect(c.state.failure, 'INVALID_RESPONSE');
      expect(c.state.locked, isTrue);
      expect(c.state.receipt, isNull);
    });
  }
  test(
    'double submit blocked, late success cannot repopulate ended session',
    () async {
      final r = AccountProbe();
      final c = AccountManagementCubit(r, action: AccountAction.deleteAccount);
      addTearDown(c.close);
      addTearDown(r.events.close);
      await c.load();
      await c.start('');
      final reply = Completer<AccountReceipt>();
      var calls = 0;
      r.onConfirm = (id, op, code) {
        calls++;
        return reply.future;
      };
      final pending = c.confirm('123456');
      await c.confirm('123456');
      expect(calls, 1);
      r.events.add(const AccountChange(sessionReset: true));
      reply.complete(
        AccountReceipt(
          operationId: 'foreign',
          challengeId: 'foreign',
          action: AccountAction.deleteAccount,
          completedAt: accountNow,
        ),
      );
      await pending;
      expect(c.state.ended, isTrue);
      expect(c.state.challenge, isNull);
      expect(c.state.receipt, isNull);
    },
  );
  test('closed cubit ignores a late eligibility result', () async {
    final r = AccountProbe();
    final c = AccountManagementCubit(r, action: AccountAction.deleteAccount);
    addTearDown(r.events.close);
    final reply = Completer<AccountEligibility>();
    r.onEligibility = () => reply.future;
    final pending = c.load();
    await c.close();
    reply.complete(AccountEligibility(phoneE164: '+963912345678'));
    await pending;
    expect(c.state.eligibility, isNull);
  });
}
