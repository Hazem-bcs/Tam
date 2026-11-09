import 'support_models.dart';
export 'support_models.dart';

final class SupportPolicy {
  const SupportPolicy({
    this.minBodyCodePoints = 10,
    this.maxBodyCodePoints = 2000,
    this.pageSize = 20,
  });
  final int minBodyCodePoints, maxBodyCodePoints, pageSize;
  String validateBody(String body) {
    final value = body.trim();
    final length = value.runes.length;
    if (length < minBodyCodePoints || length > maxBodyCodePoints) {
      throw const SupportFailure('VALIDATION_ERROR');
    }
    return value;
  }

  SupportCategory validateCategory(SupportOptions options, String categoryId) {
    final found = options.categories
        .where((c) => c.id == categoryId)
        .firstOrNull;
    if (found == null || (found.tripRequired && options.tripId == null)) {
      throw const SupportFailure('INVALID_CATEGORY');
    }
    return found;
  }
}

abstract interface class SupportRepository {
  Future<SupportOptions> options({String? tripId});
  Future<SupportTicketPage> tickets({String? cursor});
  Future<SupportTicket> ticket(String id);
  Future<SupportTicket> create({
    required String clientRequestId,
    required String categoryId,
    required String body,
    String? tripId,
  });
  Future<LegalDocument?> legal(
    LegalDocumentKind kind, {
    required String languageCode,
  });
  Stream<SupportChange> get changes;
}
