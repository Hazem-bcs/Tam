import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_detail_cubit.dart';
import 'support_test_support.dart';

void main() {
  for (final changed in [
    'body',
    'category',
    'trip',
    'client',
    'same-revision',
  ]) {
    test(
      'ticket details preserve accepted snapshot after $changed mutation',
      () async {
        final repo = ControlledSupportRepository();
        final initial = supportTicket();
        repo.onTicket = (_) async => initial;
        final detail = SupportDetailCubit(repo, initial.id);
        addTearDown(detail.close);
        addTearDown(repo.events.close);
        await detail.load();
        final invalid = supportTicket(
          revision: changed == 'same-revision' ? 1 : 2,
          body: changed == 'body' || changed == 'same-revision'
              ? 'Unexpected changed issue'
              : initial.body,
          category: changed == 'category' ? 'different' : initial.categoryId,
          tripId: changed == 'trip' ? 'foreign-trip' : initial.tripId,
          clientId: changed == 'client'
              ? 'foreign-request-001'
              : initial.clientRequestId,
        );
        repo.onTicket = (_) async => invalid;
        await detail.load();
        expect(detail.state.ticket, initial);
        expect(detail.state.failure!.code, 'INVALID_RESPONSE');
      },
    );
  }
}
