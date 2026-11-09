enum SupportTicketStatus { open, inProgress, resolved }

enum LegalDocumentKind { terms, privacy }

final class SupportCategory {
  const SupportCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.tripRequired = false,
  });
  final String id, nameAr, nameEn;
  final bool tripRequired;
}

final class SupportOptions {
  SupportOptions({required Iterable<SupportCategory> categories, this.tripId})
    : categories = List.unmodifiable(categories);
  final List<SupportCategory> categories;
  final String? tripId;
}

final class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.clientRequestId,
    required this.categoryId,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
    this.tripId,
  });
  final String id, clientRequestId, categoryId, body;
  final String? tripId;
  final SupportTicketStatus status;
  final DateTime createdAt, updatedAt;
  final int revision;
}

final class SupportTicketPage {
  SupportTicketPage({required Iterable<SupportTicket> tickets, this.nextCursor})
    : tickets = List.unmodifiable(tickets);
  final List<SupportTicket> tickets;
  final String? nextCursor;
}

final class LegalDocument {
  const LegalDocument({
    required this.kind,
    required this.languageCode,
    required this.plainText,
    required this.version,
    required this.publishedAt,
  });
  final LegalDocumentKind kind;
  final String languageCode, plainText, version;
  final DateTime publishedAt;
}

final class SupportChange {
  const SupportChange({this.sessionReset = false});
  final bool sessionReset;
}

final class SupportFailure implements Exception {
  const SupportFailure(this.code, {this.uncertain = false});
  final String code;
  final bool uncertain;
}
