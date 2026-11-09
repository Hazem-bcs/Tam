import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/features/support/presentation/bloc/legal_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_editor_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_list_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_detail_cubit.dart';
import 'support_test_support.dart';

SupportEditorCubit editor(SupportRepository repo, {String? tripId}) =>
    SupportEditorCubit(
      repo,
      policy: const SupportPolicy(),
      now: () => supportNow,
      tripId: tripId,
    );
void main() {
  test(
    'uncertain payload locked, retry uses identical secure ID, no concurrent duplicate',
    () async {
      final repo = ControlledSupportRepository();
      final c = editor(repo);
      addTearDown(c.close);
      addTearDown(repo.events.close);
      await c.load();
      c.bodyChanged('  Details of the issue  ');
      final response = Completer<SupportTicket>();
      repo.onCreate = (id, category, body, trip) => response.future;
      final sent = c.submit();
      await c.submit();
      expect(repo.requests, hasLength(1));
      expect(c.state.sending, isTrue);
      response.completeError(
        const SupportFailure('NETWORK_ERROR', uncertain: true),
      );
      await sent;
      expect(c.state.locked, isTrue);
      c.bodyChanged('A different issue body');
      c.categoryChanged('unknown');
      expect(c.state.body, '  Details of the issue  ');
      repo.onCreate = (id, category, body, trip) async => supportTicket(
        clientId: id,
        category: category,
        body: body,
        tripId: trip,
      );
      await c.submit();
      expect(repo.requests[0], repo.requests[1]);
      expect(repo.requests.first.id, matches(RegExp(r'^[0-9a-f]{48}$')));
      expect(c.state.accepted!.body, 'Details of the issue');
      await c.submit();
      expect(repo.requests, hasLength(2));
    },
  );
  for (final invalid in ['client', 'category', 'body', 'trip', 'identity']) {
    test(
      'invalid $invalid acknowledgement stays unresolved and cannot replace payload',
      () async {
        final repo = ControlledSupportRepository();
        final c = editor(repo, tripId: 'trip-1');
        addTearDown(c.close);
        addTearDown(repo.events.close);
        await c.load();
        c.bodyChanged('Details of the issue');
        repo.onCreate = (id, category, body, trip) async => supportTicket(
          id: invalid == 'identity' ? '' : 'ticket-1',
          clientId: invalid == 'client' ? 'wrong-0000000001' : id,
          category: invalid == 'category' ? 'other' : category,
          body: invalid == 'body' ? 'Unexpected response' : body,
          tripId: invalid == 'trip' ? 'foreign' : trip,
        );
        await c.submit();
        expect(c.state.accepted, isNull);
        expect(c.state.locked, isTrue);
        expect(c.state.failure!.code, 'INVALID_RESPONSE');
        c.bodyChanged('Different issue body');
        expect(c.state.body, 'Details of the issue');
      },
    );
  }
  test(
    'close discards page state while accepted request remains in app repository',
    () async {
      final store = supportStore();
      final repo = MockSupportRepository(store, now: () => supportNow);
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      final c = editor(repo);
      await c.load();
      c.bodyChanged('Details of the issue');
      await c.submit();
      final id = c.state.accepted!.id;
      await c.close();
      final fresh = editor(repo);
      addTearDown(fresh.close);
      await fresh.load();
      expect(fresh.state.body, isEmpty);
      expect((await repo.tickets()).tickets.single.id, id);
    },
  );
  test(
    'late options cannot change newer context or restore state after session reset',
    () async {
      final repo = ControlledSupportRepository();
      final c = editor(repo);
      addTearDown(c.close);
      addTearDown(repo.events.close);
      final first = Completer<SupportOptions>();
      repo.onOptions = (_) => first.future;
      final pending = c.load();
      repo.onOptions = (_) async => SupportOptions(
        categories: const [
          SupportCategory(id: 'new', nameAr: 'جديد', nameEn: 'New'),
        ],
      );
      await c.load();
      first.complete(
        SupportOptions(
          categories: const [
            SupportCategory(id: 'old', nameAr: 'قديم', nameEn: 'Old'),
          ],
        ),
      );
      await pending;
      expect(c.state.categoryId, 'new');
      c.bodyChanged('Details of the issue');
      final response = Completer<SupportTicket>();
      repo.onCreate = (_, _, _, _) => response.future;
      final sent = c.submit();
      repo.events.add(const SupportChange(sessionReset: true));
      response.complete(supportTicket());
      await sent;
      expect(c.state.ended, isTrue);
      expect(c.state.body, isEmpty);
      expect(c.state.accepted, isNull);
    },
  );
  test(
    'close rejects late create result and late detail reads preserve latest revision',
    () async {
      final repo = ControlledSupportRepository();
      final c = editor(repo);
      addTearDown(repo.events.close);
      await c.load();
      c.bodyChanged('Details of the issue');
      final response = Completer<SupportTicket>();
      repo.onCreate = (_, _, _, _) => response.future;
      final sent = c.submit();
      await c.close();
      response.complete(supportTicket());
      await sent;
      expect(c.state.accepted, isNull);
      final detail = SupportDetailCubit(repo, 'ticket-1');
      addTearDown(detail.close);
      final old = Completer<SupportTicket>();
      repo.onTicket = (_) => old.future;
      final read = detail.load();
      repo.onTicket = (_) async => supportTicket(revision: 3);
      await detail.load();
      old.complete(supportTicket(revision: 1));
      await read;
      expect(detail.state.ticket!.revision, 3);
      repo.onTicket = (_) async => supportTicket(revision: 2);
      await detail.load();
      expect(detail.state.ticket!.revision, 3);
      repo.onTicket = (_) async => supportTicket(id: 'foreign');
      await detail.load();
      expect(detail.state.failure!.code, 'INVALID_RESPONSE');
      expect(detail.state.ticket!.revision, 3);
      repo.events.add(const SupportChange(sessionReset: true));
      expect(detail.state.ticket, isNull);
    },
  );
  test(
    'list pagination retains content on failure and ignores stale reads and revisions',
    () async {
      final repo = ControlledSupportRepository();
      final c = SupportListCubit(repo);
      addTearDown(c.close);
      addTearDown(repo.events.close);
      final old = Completer<SupportTicketPage>();
      repo.onList = (_) => old.future;
      final read = c.load();
      repo.onList = (_) async => SupportTicketPage(
        tickets: [supportTicket(revision: 3)],
        nextCursor: 'next',
      );
      await c.load();
      old.complete(SupportTicketPage(tickets: []));
      await read;
      expect(c.state.tickets.single.revision, 3);
      repo.onList = (_) async => SupportTicketPage(
        tickets: [supportTicket(revision: 2)],
        nextCursor: 'next',
      );
      await c.load();
      expect(c.state.tickets.single.revision, 3);
      repo.onList = (_) async => throw const SupportFailure('NETWORK_ERROR');
      await c.load(more: true);
      expect(c.state.tickets.single.revision, 3);
      expect(c.state.cursor, 'next');
      expect(c.state.failure, isNotNull);
      repo.events.add(const SupportChange(sessionReset: true));
      expect(c.state.tickets, isEmpty);
      expect(c.state.ended, isTrue);
    },
  );
  test(
    'legal null, failure, approved plain text and wrong-language acknowledgement',
    () async {
      final repo = ControlledSupportRepository();
      final c = LegalCubit(
        repo,
        kind: LegalDocumentKind.terms,
        languageCode: 'ar',
      );
      addTearDown(c.close);
      addTearDown(repo.events.close);
      await c.load();
      expect(c.state.document, isNull);
      expect(c.state.loading, isFalse);
      expect(c.state.failure, isNull);
      // Approved content is supplied only by this local test double.
      repo.onLegal = (kind, lang) async => LegalDocument(
        kind: kind,
        languageCode: lang,
        plainText: '<plain text, never HTML>',
        version: 'test-only',
        publishedAt: supportNow,
      );
      await c.load();
      expect(c.state.document!.plainText, contains('<plain text'));
      repo.onLegal = (_, _) async =>
          throw const SupportFailure('NETWORK_ERROR');
      await c.load();
      expect(c.state.document, isNotNull);
      expect(c.state.failure, isNotNull);
      repo.onLegal = (kind, _) async => LegalDocument(
        kind: kind,
        languageCode: 'en',
        plainText: 'Test only',
        version: 'test',
        publishedAt: supportNow,
      );
      await c.load();
      expect(c.state.failure!.code, 'INVALID_RESPONSE');
      expect(c.state.document!.languageCode, 'ar');
    },
  );
}
