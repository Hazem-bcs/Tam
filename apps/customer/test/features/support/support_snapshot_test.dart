import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_detail_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_list_cubit.dart';
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
      'detail and list preserve accepted snapshot after $changed mutation',
      () async {
        final repo = ControlledSupportRepository();
        final initial = supportTicket();
        repo.onTicket = (_) async => initial;
        repo.onList = (_) async => SupportTicketPage(tickets: [initial]);
        final detail = SupportDetailCubit(repo, initial.id);
        final list = SupportListCubit(repo);
        addTearDown(detail.close);
        addTearDown(list.close);
        addTearDown(repo.events.close);
        await detail.load();
        await list.load();
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
        repo.onList = (_) async => SupportTicketPage(tickets: [invalid]);
        await detail.load();
        await list.load();
        expect(detail.state.ticket, initial);
        expect(list.state.tickets.single, initial);
        expect(detail.state.failure!.code, 'INVALID_RESPONSE');
        expect(list.state.failure!.code, 'INVALID_RESPONSE');
      },
    );
  }
}
