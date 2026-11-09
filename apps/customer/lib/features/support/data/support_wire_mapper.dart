import '../domain/support_repository.dart';

/// Strict decoder shared by proposed API examples and the future HTTP adapter.
abstract final class SupportWireMapper {
  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return value;
  }

  static String _text(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Expected text');
    }
    return value;
  }

  static String? _optional(Object? value) =>
      value == null ? null : _text(value);
  static DateTime _time(Object? value) {
    final text = _text(value);
    final date = DateTime.tryParse(text);
    if (!text.endsWith('Z') || date == null || !date.isUtc) {
      throw const FormatException('Expected UTC timestamp');
    }
    return date;
  }

  static Object? _data(Map<String, dynamic> envelope) {
    if (!envelope.containsKey('data') || envelope.containsKey('error')) {
      throw const FormatException('Expected success envelope');
    }
    return envelope['data'];
  }

  static SupportOptions options(Map<String, dynamic> envelope) {
    final data = _map(_data(envelope));
    final tripId = _optional(data['trip_id']);
    final categories = data['categories'];
    if (categories is! List || categories.isEmpty) {
      throw const FormatException('Expected categories');
    }
    final ids = <String>{};
    return SupportOptions(
      tripId: tripId,
      categories: categories.map((value) {
        final item = _map(value), name = _map(_map(value)['name']);
        final requiredTrip = item['trip_required'];
        final id = _text(item['id']);
        if (requiredTrip is! bool ||
            (requiredTrip && tripId == null) ||
            !ids.add(id)) {
          throw const FormatException('Invalid category context');
        }
        return SupportCategory(
          id: id,
          nameAr: _text(name['ar']),
          nameEn: _text(name['en']),
          tripRequired: requiredTrip,
        );
      }),
    );
  }

  static SupportTicket ticket(Map<String, dynamic> envelope) =>
      ticketData(_map(_data(envelope)));
  static SupportTicket ticketData(Map<String, dynamic> data) {
    final status = switch (data['status']) {
      'open' => SupportTicketStatus.open,
      'in_progress' => SupportTicketStatus.inProgress,
      'resolved' => SupportTicketStatus.resolved,
      _ => throw const FormatException('Unknown status'),
    };
    final created = _time(data['created_at']),
        updated = _time(data['updated_at']);
    final revision = data['revision'];
    final clientId = _text(data['client_request_id']);
    final body = _text(data['body']);
    if (revision is! int ||
        revision < 1 ||
        updated.isBefore(created) ||
        body != body.trim() ||
        body.runes.length < 10 ||
        body.runes.length > 2000 ||
        !RegExp(r'^[A-Za-z0-9_-]{16,128}$').hasMatch(clientId)) {
      throw const FormatException('Invalid ticket');
    }
    return SupportTicket(
      id: _text(data['id']),
      clientRequestId: clientId,
      categoryId: _text(data['category_id']),
      body: body,
      status: status,
      createdAt: created,
      updatedAt: updated,
      revision: revision,
      tripId: _optional(data['trip_id']),
    );
  }

  static SupportTicketPage page(Map<String, dynamic> envelope) {
    final data = _map(_data(envelope)),
        pagination = _map(_map(_data(envelope))['pagination']);
    final values = data['tickets'];
    if (values is! List || values.length > 20 || pagination['limit'] != 20) {
      throw const FormatException('Invalid pagination');
    }
    final tickets = values.map((v) => ticketData(_map(v))).toList();
    if (tickets.map((t) => t.id).toSet().length != tickets.length) {
      throw const FormatException('Duplicate ticket');
    }
    for (var i = 1; i < tickets.length; i++) {
      final before = tickets[i - 1], after = tickets[i];
      if (before.createdAt.isBefore(after.createdAt) ||
          (before.createdAt == after.createdAt &&
              before.id.compareTo(after.id) <= 0)) {
        throw const FormatException('Invalid order');
      }
    }
    final cursor = _optional(pagination['next_cursor']);
    if (cursor != null && tickets.length != 20) {
      throw const FormatException('Invalid continuation');
    }
    return SupportTicketPage(tickets: tickets, nextCursor: cursor);
  }

  static LegalDocument? legal(Map<String, dynamic> envelope) {
    final data = _data(envelope);
    if (data == null) return null;
    final value = _map(data);
    final kind = switch (value['kind']) {
      'terms' => LegalDocumentKind.terms,
      'privacy' => LegalDocumentKind.privacy,
      _ => throw const FormatException('Invalid legal kind'),
    };
    final language = _text(value['language']);
    if (!{'ar', 'en'}.contains(language)) {
      throw const FormatException('Invalid language');
    }
    return LegalDocument(
      kind: kind,
      languageCode: language,
      plainText: _text(value['plain_text']),
      version: _text(value['version']),
      publishedAt: _time(value['published_at']),
    );
  }

  static SupportFailure failure(Map<String, dynamic> envelope) {
    final error = _map(envelope['error']),
        messages = _map(_map(envelope['error'])['message']);
    _text(messages['ar']);
    _text(messages['en']);
    final uncertain = error['uncertain'];
    if (uncertain != null && uncertain is! bool) {
      throw const FormatException('Invalid uncertainty');
    }
    return SupportFailure(_text(error['code']), uncertain: uncertain == true);
  }
}
