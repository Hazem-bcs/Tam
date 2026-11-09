import '../domain/support_repository.dart';

/// Explicit API adapter until the proposed support contract is implemented.
final class UnavailableSupportRepository implements SupportRepository {
  const UnavailableSupportRepository();
  Never _unavailable() => throw const SupportFailure('SERVICE_UNAVAILABLE');
  @override
  Future<SupportOptions> options({String? tripId}) async => _unavailable();
  @override
  Future<SupportTicketPage> tickets({String? cursor}) async => _unavailable();
  @override
  Future<SupportTicket> ticket(String id) async => _unavailable();
  @override
  Future<SupportTicket> create({
    required String clientRequestId,
    required String categoryId,
    required String body,
    String? tripId,
  }) async => _unavailable();
  @override
  Future<LegalDocument?> legal(
    LegalDocumentKind kind, {
    required String languageCode,
  }) async => _unavailable();
  @override
  Stream<SupportChange> get changes => const Stream.empty();
}
