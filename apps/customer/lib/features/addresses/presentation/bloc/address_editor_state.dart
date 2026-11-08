import 'package:tam_customer/shared/domain/trip.dart';

import '../../domain/addresses_repository.dart';
import '../../domain/saved_address.dart';

enum AddressEditorPhase { loading, ready, saving, saved, notFound, error }

const _absent = Object();

final class AddressEditorState {
  const AddressEditorState({
    this.phase = AddressEditorPhase.loading,
    this.original,
    this.name = '',
    this.icon = AddressIcon.home,
    this.location,
    this.suggestions = const [],
    this.searching = false,
    this.searchFailure,
    this.failure,
    this.validationAttempted = false,
    this.retryPending = false,
  });
  final AddressEditorPhase phase;
  final SavedAddress? original;
  final String name;
  final AddressIcon icon;
  final TripLocation? location;
  final List<TripLocation> suggestions;
  final bool searching;
  final AddressFailureCode? searchFailure;
  final AddressFailureCode? failure;
  final bool validationAttempted;
  final bool retryPending;
  bool get busy =>
      phase == AddressEditorPhase.loading || phase == AddressEditorPhase.saving;
  bool get locked => busy || retryPending || phase == AddressEditorPhase.saved;
  bool get dirty =>
      name.trim() != (original?.input.name ?? '') ||
      icon != (original?.input.icon ?? AddressIcon.home) ||
      location != original?.input.location;
  bool get valid =>
      AddressInput.validName(name) &&
      location != null &&
      AddressInput.validLocation(location!);

  AddressEditorState copyWith({
    AddressEditorPhase? phase,
    SavedAddress? original,
    String? name,
    AddressIcon? icon,
    TripLocation? location,
    List<TripLocation>? suggestions,
    bool? searching,
    Object? searchFailure = _absent,
    Object? failure = _absent,
    bool? validationAttempted,
    bool? retryPending,
  }) => AddressEditorState(
    phase: phase ?? this.phase,
    original: original ?? this.original,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    location: location ?? this.location,
    suggestions: suggestions ?? this.suggestions,
    searching: searching ?? this.searching,
    searchFailure: identical(searchFailure, _absent)
        ? this.searchFailure
        : searchFailure as AddressFailureCode?,
    failure: identical(failure, _absent)
        ? this.failure
        : failure as AddressFailureCode?,
    validationAttempted: validationAttempted ?? this.validationAttempted,
    retryPending: retryPending ?? this.retryPending,
  );
}
