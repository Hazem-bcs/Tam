import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/addresses_repository.dart';
import '../../domain/saved_address.dart';

IconData addressIcon(AddressIcon icon) => switch (icon) {
  AddressIcon.home => Icons.home_outlined,
  AddressIcon.work => Icons.work_outline,
  AddressIcon.study => Icons.school_outlined,
  AddressIcon.gym => Icons.fitness_center_outlined,
  AddressIcon.other => Icons.place_outlined,
};

String addressIconLabel(AppLocalizations t, AddressIcon icon) => switch (icon) {
  AddressIcon.home => t.addressesIconHome,
  AddressIcon.work => t.addressesIconWork,
  AddressIcon.study => t.addressesIconStudy,
  AddressIcon.gym => t.addressesIconGym,
  AddressIcon.other => t.addressesIconOther,
};

String addressFailureMessage(AppLocalizations t, AddressFailureCode? code) =>
    switch (code) {
      AddressFailureCode.unavailable => t.addressesUnavailable,
      AddressFailureCode.notFound => t.addressesNotFound,
      AddressFailureCode.limitReached => t.addressesLimit(
        AddressesRepository.maxAddresses,
      ),
      AddressFailureCode.idempotencyConflict => t.addressesConflict,
      _ => t.addressesError,
    };
