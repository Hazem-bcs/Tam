import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/account_management/data/mock/mock_account_management_repository.dart';
import 'package:tam_customer/features/account_management/domain/account_management_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'account_test_support.dart';

void main() {
  for (final wrongAttempts in [1, 3]) {
    test(
      'resend invalidates old OTP after $wrongAttempts wrong attempts',
      () async {
        var time = accountNow;
        final trips = MockTripStore();
        final repository = MockAccountManagementRepository(
          trips,
          phone: () => '+963912345678',
          now: () => time,
        );
        addTearDown(trips.dispose);
        addTearDown(repository.dispose);
        final challenge = await repository.start(
          action: AccountAction.deleteAccount,
          operationId: operationId,
        );
        for (var i = 0; i < wrongAttempts; i++) {
          await expectLater(
            repository.confirm(
              challengeId: challenge.id,
              operationId: operationId,
              code: '000000',
            ),
            throwsA(isA<AccountFailure>()),
          );
        }
        time = time.add(const Duration(seconds: 30));
        await repository.resend(
          challengeId: challenge.id,
          requestId: 'resend-operation-001',
        );
        await expectLater(
          repository.confirm(
            challengeId: challenge.id,
            operationId: operationId,
            code: '123456',
          ),
          throwsA(
            isA<AccountFailure>().having((e) => e.code, 'code', 'OTP_INVALID'),
          ),
        );
        expect(await repository.operation(operationId), isNull);
        expect(
          (await repository.confirm(
            challengeId: challenge.id,
            operationId: operationId,
            code: '654321',
          )).action,
          AccountAction.deleteAccount,
        );
      },
    );
  }
  test('multiple resends never reactivate any earlier OTP', () async {
    var time = accountNow;
    final trips = MockTripStore();
    final repository = MockAccountManagementRepository(
      trips,
      phone: () => '+963912345678',
      now: () => time,
    );
    addTearDown(trips.dispose);
    addTearDown(repository.dispose);
    final challenge = await repository.start(
      action: AccountAction.changePhone,
      operationId: operationId,
      newPhoneE164: '+963944444444',
    );
    for (var i = 0; i < 3; i++) {
      time = time.add(const Duration(seconds: 30));
      await repository.resend(
        challengeId: challenge.id,
        requestId: 'resend-operation-000$i',
      );
    }
    for (final code in ['123456', '654321', '654322']) {
      await expectLater(
        repository.confirm(
          challengeId: challenge.id,
          operationId: operationId,
          code: code,
        ),
        throwsA(
          isA<AccountFailure>().having((e) => e.code, 'code', 'OTP_INVALID'),
        ),
      );
    }
    expect(await repository.operation(operationId), isNull);
    expect(
      (await repository.confirm(
        challengeId: challenge.id,
        operationId: operationId,
        code: '654323',
      )).action,
      AccountAction.changePhone,
    );
  });
}
