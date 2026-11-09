// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tam';

  @override
  String get authWelcome => 'Welcome to Tam';

  @override
  String get authPhoneDescription => 'Enter your phone number to continue';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHelper =>
      'Syrian mobile in local or international format.';

  @override
  String get authPhoneInvalid => 'Enter a valid Syrian mobile number';

  @override
  String get authSendCode => 'Send verification code';

  @override
  String get authSending => 'Sending code';

  @override
  String get authContinueGuest => 'Continue as a guest';

  @override
  String get authUnifiedAccount =>
      'Your verified number signs you in or creates a new account.';

  @override
  String get authVerifyTitle => 'Verify your phone';

  @override
  String get authVerifyDescription => 'Enter the six-digit verification code';

  @override
  String get authEditPhone => 'Change phone number';

  @override
  String get authCodeLabel => 'Verification code';

  @override
  String get authCodeInvalid => 'Enter all six digits';

  @override
  String get authCodeExpired => 'The code has expired';

  @override
  String get authVerifyCode => 'Verify code';

  @override
  String get authVerifying => 'Verifying';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authRestartHint =>
      'Go back to your phone number to start again after the waiting period.';

  @override
  String get authRestoring => 'Checking your session';

  @override
  String get authSessionDescription => 'Restoring your account information';

  @override
  String get authRetry => 'Try again';

  @override
  String get authSignOutThisDevice => 'Sign out of this device';

  @override
  String get authGuestTitle => 'You are browsing as a guest';

  @override
  String get authGuestDescription =>
      'Sign in to continue with your phone number.';

  @override
  String get authSignedInTitle => 'You are signed in';

  @override
  String get authLogout => 'Sign out';

  @override
  String get authLoggingOut => 'Signing out';

  @override
  String get authSignIn => 'Sign in';

  @override
  String authRetryIn(int seconds) {
    return 'Try again in $seconds seconds';
  }

  @override
  String authResendIn(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String authCodeExpires(int seconds) {
    return 'Code expires in $seconds seconds';
  }

  @override
  String authAttemptsRemaining(int count) {
    return 'Attempts remaining: $count';
  }

  @override
  String authSignedInAs(String identity) {
    return 'Welcome, $identity';
  }

  @override
  String get authNationalPhoneHint => '9XX XXX XXX';

  @override
  String get authPhoneWithCountry => 'Phone number, country code +963';

  @override
  String authResendCountdown(String time) {
    return 'Resend code in $time';
  }

  @override
  String get authContinue => 'Continue';

  @override
  String get authContinuing => 'Continuing';

  @override
  String get authPhonePrivacy =>
      'Use your phone number to personalize your experience.';

  @override
  String get homeWelcome => 'Your journey starts with Tam';

  @override
  String get homePhoneTitle => 'Your phone number';

  @override
  String get homeServiceTitle => 'Rides are currently unavailable';

  @override
  String get homeServiceDescription =>
      'Please check back later for service availability.';

  @override
  String get navHome => 'Home';

  @override
  String get navRideRequest => 'Request a ride';

  @override
  String get navTrips => 'My trips';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSettings => 'Settings';

  @override
  String get featureNotConnected => 'This feature is currently unavailable.';

  @override
  String get homeGreeting => 'Welcome,';

  @override
  String get homeChooseService => 'Choose a service';

  @override
  String get homeRideEntryTitle => 'Where to?';

  @override
  String get homeRideEntryHint =>
      'Choose your pickup and destination to request a ride';

  @override
  String get homeRide => 'Ride';

  @override
  String get homeFood => 'Food';

  @override
  String get homeShopping => 'Shopping';

  @override
  String get homeComingSoon => 'Coming soon';

  @override
  String get homeLoading => 'Loading home';

  @override
  String get homeEmpty => 'There\'s no home content available right now.';

  @override
  String get homeUnavailable => 'Home is not yet available in API mode.';

  @override
  String get homeError =>
      'Couldn\'t load Home. Check your connection and try again.';

  @override
  String homeUnreadNotifications(int count) {
    return 'Notifications, unread: $count';
  }

  @override
  String get rideRequestTitle => 'Book a ride';

  @override
  String get rideRequestPickup => 'Pickup';

  @override
  String get rideRequestPickupHint => 'Choose pickup';

  @override
  String get rideRequestDestination => 'Destination';

  @override
  String get rideRequestDestinationHint => 'Where to?';

  @override
  String get rideRequestSearchPlaces => 'Search for a place';

  @override
  String get rideRequestNoPlaces => 'No matching places. Try another name.';

  @override
  String get rideRequestMockMap =>
      'Illustrative map • simulated places, not GPS';

  @override
  String get rideRequestRouteHint =>
      'Choose pickup and destination to see an estimated fare.';

  @override
  String get rideRequestChooseClass => 'Choose a ride type';

  @override
  String get rideRequestStandard => 'Standard';

  @override
  String get rideRequestStandardDescription => 'For everyday rides';

  @override
  String get rideRequestComfort => 'Comfort';

  @override
  String get rideRequestComfortDescription => 'More space and comfort';

  @override
  String get rideRequestVan => 'Van';

  @override
  String get rideRequestVanDescription => 'For families and groups';

  @override
  String get rideRequestMotorbike => 'Motorbike';

  @override
  String get rideRequestMotorbikeDescription => 'For documents and parcels';

  @override
  String get rideRequestQuoteTitle => 'Ride details';

  @override
  String get rideRequestDistance => 'Distance';

  @override
  String get rideRequestDuration => 'Duration';

  @override
  String get rideRequestFare => 'Fare';

  @override
  String get rideRequestCurrencySyp => 'SYP';

  @override
  String get rideRequestKm => 'km';

  @override
  String get rideRequestMinute => 'min';

  @override
  String get rideRequestPayment => 'Payment method';

  @override
  String get rideRequestCash => 'Cash';

  @override
  String get rideRequestCashOnly => 'Only simulated cash payment is available.';

  @override
  String get rideRequestReview => 'Review request';

  @override
  String get rideRequestConfirm => 'Confirm ride request';

  @override
  String get rideRequestConfirming => 'Confirming request';

  @override
  String get rideRequestQuoteLoading => 'Estimating fare';

  @override
  String get rideRequestRetry => 'Try again';

  @override
  String get rideRequestRefreshQuote => 'Get a new quote';

  @override
  String get rideRequestErrorValidation =>
      'Choose two different, valid places and a ride type.';

  @override
  String get rideRequestErrorExpired =>
      'This quote has expired. Request a new one.';

  @override
  String get rideRequestErrorUnavailable =>
      'Service is unavailable right now. Please retry.';

  @override
  String get rideRequestErrorConflict =>
      'The request conflicts with an existing confirmation.';

  @override
  String get rideRequestErrorGeneric =>
      'Could not complete the request. Try again.';

  @override
  String get rideRequestSimulationNotice =>
      'Local simulation only: no real ride or payment is made.';

  @override
  String get rideRequestSelected => 'Selected';

  @override
  String get rideRequestPlaceSearchLoading => 'Searching places';

  @override
  String get rideRequestEdit => 'Edit';

  @override
  String get rideRequestImmediate => 'Now';

  @override
  String get rideRequestScheduled => 'Scheduled';

  @override
  String get rideRequestScheduleTitle => 'Choose your trip time';

  @override
  String get rideRequestScheduleDate => 'Date';

  @override
  String get rideRequestScheduleTime => 'Trip time';

  @override
  String rideRequestScheduleTimezone(String offset) {
    return 'Service time: $offset';
  }

  @override
  String rideRequestScheduleRange(int minutes, int days) {
    return 'Choose a time between $minutes minutes and $days days from now.';
  }

  @override
  String get rideRequestScheduleInvalid =>
      'This time is outside the available window. Change the date or time and try again.';

  @override
  String get rideRequestScheduleUnavailable =>
      'Scheduling is unavailable for this time. Choose another time or request a ride now.';

  @override
  String get rideRequestScheduleSave => 'Confirm time';

  @override
  String get rideRequestScheduleCancel => 'Cancel';

  @override
  String get rideRequestScheduledNotice =>
      'Reserving a time does not assign a driver now.';

  @override
  String get rideRequestHour => 'Hour';

  @override
  String get rideRequestMinuteInput => 'Minute';

  @override
  String get rideRequestTimeFormat => '24-hour time (00–23).';

  @override
  String get rideRequestTimeInvalid => 'Enter a valid value in range.';

  @override
  String get tripsAll => 'All';

  @override
  String get tripsActive => 'Active';

  @override
  String get tripsCompletedFilter => 'Completed';

  @override
  String get tripsCancelledFilter => 'Cancelled';

  @override
  String get tripsStatusRequested => 'Requested';

  @override
  String get tripsStatusConfirmed => 'Confirmed';

  @override
  String get tripsStatusInProgress => 'In progress';

  @override
  String get tripsStatusCompleted => 'Completed';

  @override
  String get tripsStatusCancelled => 'Cancelled';

  @override
  String get tripsFrom => 'From';

  @override
  String get tripsTo => 'To';

  @override
  String get tripsDetails => 'Details';

  @override
  String get tripsDetailsTitle => 'Trip details';

  @override
  String tripsTripNumber(String id) {
    return 'Trip $id';
  }

  @override
  String get tripsCreatedAt => 'Requested at';

  @override
  String get tripsFare => 'Fare';

  @override
  String get tripsVehicleClass => 'Vehicle category';

  @override
  String get tripsVehicleStandard => 'Standard';

  @override
  String get tripsEmptyTitle => 'No trips here';

  @override
  String get tripsEmptyDescription => 'Your trips will appear in this section.';

  @override
  String get tripsErrorTitle => 'Couldn\'t load trips';

  @override
  String get tripsErrorDescription => 'Check your connection and try again.';

  @override
  String get tripsRetry => 'Try again';

  @override
  String get tripsRefresh => 'Refresh';

  @override
  String get tripsLoadMore => 'Load more';

  @override
  String get tripsCancel => 'Cancel trip';

  @override
  String get tripsCancelTitle => 'Cancel this trip?';

  @override
  String get tripsCancelPrompt =>
      'Cancellation can\'t be undone once confirmed.';

  @override
  String get tripsConfirmCancel => 'Confirm cancellation';

  @override
  String get tripsKeepTrip => 'Keep trip';

  @override
  String get tripsCancelledSuccess => 'Trip cancelled.';

  @override
  String get tripsCannotCancel =>
      'This trip can\'t be cancelled in its current state.';

  @override
  String get tripsRebook => 'Book again';

  @override
  String get tripsNotFoundTitle => 'Trip not found';

  @override
  String get tripsNotFoundDescription =>
      'This trip may have been removed or is no longer available.';

  @override
  String get tripsBackToList => 'Back to my trips';

  @override
  String get tripsFareNote =>
      'This is the saved fare for the previous trip, not a new quote.';

  @override
  String get tripsServiceUnavailable =>
      'Trip service is currently unavailable.';

  @override
  String get tripsValidationError => 'Invalid request. Please try again.';

  @override
  String get tripsUnknownError => 'Something went wrong. Please try again.';

  @override
  String get tripsPaginationError => 'Couldn\'t load more trips.';

  @override
  String get tripsRoute => 'Trip route';

  @override
  String get tripsInformation => 'Trip information';

  @override
  String get tripsNoLiveTracking =>
      'Live trip tracking isn\'t available in this version.';

  @override
  String get tripsLoading => 'Loading trips';

  @override
  String get tripsLoadingDetails => 'Loading trip details';

  @override
  String get tripsCancelling => 'Cancelling';

  @override
  String get tripsTripList => 'Trip list';

  @override
  String get tripsStatusScheduled => 'Scheduled';

  @override
  String get tripsScheduledTime => 'Trip time';

  @override
  String tripsScheduledAt(String time) {
    return 'Scheduled: $time';
  }

  @override
  String get notificationsMarkAll => 'Mark all as read';

  @override
  String notificationsUnreadCount(int count) {
    return 'Unread: $count';
  }

  @override
  String get notificationsUnknownCount => 'Count unavailable';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get notificationsLoadMore => 'Show more';

  @override
  String get notificationsLoadingMore => 'Loading more';

  @override
  String get notificationsRefresh => 'Refresh';

  @override
  String get notificationsRetry => 'Try again';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyBody =>
      'Your updates will appear here when available.';

  @override
  String get notificationsErrorTitle => 'Couldn\'t load notifications';

  @override
  String get notificationsErrorBody => 'Check your connection and try again.';

  @override
  String get notificationsOfflineBody =>
      'Notifications API is not connected yet.';

  @override
  String get notificationsMutationError =>
      'Couldn\'t save read status. Try again.';

  @override
  String get notificationsMoreError => 'Couldn\'t load more notifications.';

  @override
  String get notificationsUnavailableTarget =>
      'This notification has no safe destination to open.';

  @override
  String get notificationsRead => 'Read';

  @override
  String get notificationsUnread => 'Unread';

  @override
  String get notificationsLoading => 'Loading notifications';

  @override
  String get notificationsOpenNotification => 'Open notification';

  @override
  String get settingsTitle => 'My account';

  @override
  String get settingsProfileSubtitle => 'Manage your profile';

  @override
  String get settingsEditName => 'Edit name';

  @override
  String get settingsName => 'Display name';

  @override
  String get settingsNameHint => '2–60 characters';

  @override
  String get settingsNameValidation =>
      'Enter a name of 2–60 characters without control characters';

  @override
  String get settingsPhone => 'Phone number';

  @override
  String get settingsPhoneReadOnly =>
      'This number comes from sign-in and cannot be changed here';

  @override
  String get settingsPhoneUnavailable => 'No phone number for this session';

  @override
  String get settingsSaveName => 'Save name';

  @override
  String get settingsPreferencesTitle => 'Settings';

  @override
  String get settingsAccountNotifications => 'Account notifications';

  @override
  String get settingsNotificationHint =>
      'Mock in-app notification preference; does not request push permission';

  @override
  String get settingsSavePreferences => 'Save notification preference';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsUnsaved => 'Unsaved changes';

  @override
  String get settingsUnsavedTitle => 'Unsaved changes';

  @override
  String get settingsUnsavedMessage =>
      'Leaving now will discard changes you have not saved.';

  @override
  String get settingsKeepEditing => 'Keep editing';

  @override
  String get settingsDiscard => 'Discard changes';

  @override
  String get settingsInfoTitle => 'Support & information';

  @override
  String get settingsMockNotice =>
      'The profile and preferences are simulated for development, not connected to a server. Language changes apply immediately for this session only.';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutConfirm => 'Log out of the current session?';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsLogoutError => 'Could not log out. Please try again.';

  @override
  String get settingsNotifications => 'Open notifications';

  @override
  String get settingsLoading => 'Loading settings';

  @override
  String get settingsServiceUnavailable =>
      'Could not load account data. The service is unavailable.';

  @override
  String get settingsRetry => 'Try again';

  @override
  String get settingsSaveError =>
      'Could not save changes. Saved data was not changed; you can retry.';

  @override
  String get settingsSaved => 'Simulated changes saved';

  @override
  String get settingsSaving => 'Saving';

  @override
  String get settingsLoggingOut => 'Logging out';

  @override
  String get addressesTitle => 'My addresses';

  @override
  String get addressesDescription => 'Save places for faster booking';

  @override
  String get addressesAdd => 'Add a place';

  @override
  String get addressesEdit => 'Edit place';

  @override
  String get addressesDelete => 'Delete place';

  @override
  String get addressesDeleteTitle => 'Delete this place?';

  @override
  String get addressesDeleteBody =>
      'It will be removed from saved addresses. Existing trips will stay unchanged.';

  @override
  String get addressesCancel => 'Cancel';

  @override
  String get addressesConfirmDelete => 'Delete';

  @override
  String get addressesLoading => 'Loading addresses';

  @override
  String get addressesSaving => 'Saving place';

  @override
  String get addressesSave => 'Save place';

  @override
  String get addressesEmpty => 'No saved addresses yet';

  @override
  String get addressesEmptyBody =>
      'Add a place to choose it quickly when booking.';

  @override
  String get addressesError => 'Unable to complete the operation. Try again.';

  @override
  String get addressesUnavailable =>
      'The addresses service is unavailable in API mode.';

  @override
  String get addressesNotFound => 'This address no longer exists.';

  @override
  String addressesLimit(int max) {
    return 'You can save up to $max addresses.';
  }

  @override
  String get addressesConflict => 'The save request conflicted. Try again.';

  @override
  String get addressesRetry => 'Retry';

  @override
  String get addressesRefresh => 'Refresh addresses';

  @override
  String get addressesName => 'Place name';

  @override
  String get addressesNameHint => 'For example: Home or Work';

  @override
  String addressesNameError(int max) {
    return 'Enter a name between 1 and $max characters.';
  }

  @override
  String get addressesLocation => 'Location';

  @override
  String get addressesChooseLocation => 'Choose the place location';

  @override
  String get addressesLocationError => 'Choose a location before saving.';

  @override
  String get addressesSearch => 'Search places';

  @override
  String get addressesNoPlaces => 'No matching places. Try another search.';

  @override
  String get addressesChooseIcon => 'Choose an icon';

  @override
  String get addressesIconHome => 'Home';

  @override
  String get addressesIconWork => 'Work';

  @override
  String get addressesIconStudy => 'Study';

  @override
  String get addressesIconGym => 'Gym';

  @override
  String get addressesIconOther => 'Other';

  @override
  String get addressesDiscardTitle => 'Discard changes?';

  @override
  String get addressesDiscardBody =>
      'Your changes to this place have not been saved.';

  @override
  String get addressesDiscard => 'Discard';

  @override
  String get addressesKeepEditing => 'Keep editing';

  @override
  String get addressesRetryPending =>
      'The save confirmation was not received. Retry the same operation to avoid adding a duplicate.';

  @override
  String get addressesManage => 'Manage addresses';

  @override
  String get addressesSavedTab => 'Saved addresses';

  @override
  String get addressesSearchTab => 'Search';
}
