import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/account_management/data/mock/mock_account_management_repository.dart';
import 'package:tam_customer/features/account_management/domain/account_management_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'account_test_support.dart';

Matcher failure(String code) =>
    isA<AccountFailure>().having((e) => e.code, 'code', code);
void main() {
  for (final action in AccountAction.values) {
    test(
      '$action validates owner, duplicate intent, OTP and immutable accepted receipt',
      () async {
        final trips = MockTripStore(seed: seedMockTrips());
        final r = MockAccountManagementRepository(
          trips,
          phone: () => '+963912345678',
          now: () => accountNow,
        );
        addTearDown(trips.dispose);
        addTearDown(r.dispose);
        Future<AccountChallenge> start({String? phone}) => r.start(
          action: action,
          operationId: operationId,
          newPhoneE164: action == AccountAction.changePhone
              ? (phone ?? '+963944444444')
              : phone,
        );
        final challenge = await start();
        expect(await start(), challenge);
        await expectLater(
          start(phone: '+963955555555'),
          throwsA(
            failure(
              action == AccountAction.changePhone
                  ? 'IDEMPOTENCY_CONFLICT'
                  : 'IDEMPOTENCY_CONFLICT',
            ),
          ),
        );
        await expectLater(
          r.confirm(
            challengeId: challenge.id,
            operationId: operationId,
            code: '000000',
          ),
          throwsA(failure('OTP_INVALID')),
        );
        final result = await r.confirm(
          challengeId: challenge.id,
          operationId: operationId,
          code: '123456',
        );
        expect(result.action, action);
        expect(await r.operation(operationId), result);
        expect(
          await r.confirm(
            challengeId: challenge.id,
            operationId: operationId,
            code: '123456',
          ),
          result,
        );
        await expectLater(
          r.confirm(
            challengeId: challenge.id,
            operationId: operationId,
            code: '654321',
          ),
          throwsA(failure('IDEMPOTENCY_CONFLICT')),
        );
        expect((await r.eligibility()).phoneE164, isNull);
        r.resetSession();
        expect(await r.operation(operationId), isNull);
      },
    );
  }
  test(
    'resend rotates code, is idempotent, enforces cooldown and expiry',
    () async {
      var time = accountNow;
      final trips = MockTripStore();
      final r = MockAccountManagementRepository(
        trips,
        phone: () => '+963912345678',
        now: () => time,
      );
      addTearDown(trips.dispose);
      addTearDown(r.dispose);
      final c = await r.start(
        action: AccountAction.changePhone,
        operationId: operationId,
        newPhoneE164: '+963944444444',
      );
      Future<AccountChallenge> resend() =>
          r.resend(challengeId: c.id, requestId: 'account-resend-0001');
      await expectLater(resend(), throwsA(failure('OTP_COOLDOWN')));
      time = time.add(const Duration(seconds: 30));
      final next = await resend();
      expect(await resend(), next);
      expect(next.revision, 2);
      await expectLater(
        r.confirm(challengeId: c.id, operationId: operationId, code: '123456'),
        throwsA(failure('OTP_INVALID')),
      );
      time = time.add(const Duration(minutes: 5));
      await expectLater(
        r.confirm(challengeId: c.id, operationId: operationId, code: '654321'),
        throwsA(failure('OTP_EXPIRED')),
      );
    },
  );
  test('attempt cap cannot be bypassed by starting a new challenge', () async {
    var time = accountNow;
    final trips = MockTripStore();
    final r = MockAccountManagementRepository(
      trips,
      phone: () => '+963912345678',
      now: () => time,
    );
    addTearDown(trips.dispose);
    addTearDown(r.dispose);
    final c = await r.start(
      action: AccountAction.deleteAccount,
      operationId: operationId,
    );
    for (var i = 0; i < 5; i++) {
      await expectLater(
        r.confirm(challengeId: c.id, operationId: operationId, code: '000000'),
        throwsA(failure('OTP_INVALID')),
      );
    }
    await expectLater(
      r.start(
        action: AccountAction.deleteAccount,
        operationId: 'account-operation-0002',
      ),
      throwsA(failure('RATE_LIMITED')),
    );
    time = time.add(const Duration(minutes: 15));
    expect(
      (await r.start(
        action: AccountAction.deleteAccount,
        operationId: 'account-operation-0002',
      )).attemptsRemaining,
      5,
    );
  });
  test(
    'active trip checked again at confirmation, guest denied, unknown challenge rejected',
    () async {
      final seed = seedMockTrips().first;
      final trips = MockTripStore();
      String? phone = '+963912345678';
      final r = MockAccountManagementRepository(
        trips,
        phone: () => phone,
        now: () => accountNow,
      );
      addTearDown(trips.dispose);
      addTearDown(r.dispose);
      final c = await r.start(
        action: AccountAction.deleteAccount,
        operationId: operationId,
      );
      trips.create(seed.booking, idempotencyKey: 'book-once');
      await expectLater(
        r.confirm(challengeId: c.id, operationId: operationId, code: '123456'),
        throwsA(failure('ACTIVE_TRIP_EXISTS')),
      );
      trips.clear();
      phone = null;
      await expectLater(
        r.start(
          action: AccountAction.deleteAccount,
          operationId: 'account-operation-0002',
        ),
        throwsA(failure('ACCOUNT_REQUIRED')),
      );
      phone = '+963912345678';
      await expectLater(
        r.confirm(
          challengeId: 'foreign',
          operationId: operationId,
          code: '123456',
        ),
        throwsA(failure('CHALLENGE_NOT_FOUND')),
      );
      await expectLater(
        r.start(
          action: AccountAction.changePhone,
          operationId: 'account-operation-0002',
          newPhoneE164: phone,
        ),
        throwsA(failure('PHONE_UNCHANGED')),
      );
    },
  );
  test(
    'lost start and confirmation responses reconcile without a second mutation',
    () async {
      final trips = MockTripStore();
      final r =
          MockAccountManagementRepository(
              trips,
              phone: () => '+963912345678',
              now: () => accountNow,
            )
            ..loseNextStart = true
            ..loseNextConfirm = true;
      addTearDown(trips.dispose);
      addTearDown(r.dispose);
      Future<AccountChallenge> start() => r.start(
        action: AccountAction.deleteAccount,
        operationId: operationId,
      );
      await expectLater(
        start(),
        throwsA(
          isA<AccountFailure>().having((e) => e.uncertain, 'uncertain', true),
        ),
      );
      final c = await start();
      await expectLater(
        r.confirm(challengeId: c.id, operationId: operationId, code: '123456'),
        throwsA(
          isA<AccountFailure>().having((e) => e.uncertain, 'uncertain', true),
        ),
      );
      expect((await r.operation(operationId))!.challengeId, c.id);
    },
  );
}
