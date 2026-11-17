import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped preferred saved place. No backend or cross-account claim:
/// the selected address remains visible while the app session is active.
final class PreferredAddressSelection extends Cubit<String?> {
  PreferredAddressSelection() : super(null);

  void choose(String id) {
    if (!isClosed && id.isNotEmpty && state != id) emit(id);
  }

  void clearIfMissing(Iterable<String> ids) {
    if (!isClosed && state != null && !ids.contains(state)) emit(null);
  }
}
