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
  String get tripsStatusDriverEnRoute => 'Driver on the way';

  @override
  String get tripsStatusDriverArrived => 'Driver waiting';

  @override
  String get tripsStatusNoDriver => 'No driver found';

  @override
  String get tripsCompletion => 'Trip summary and rating';

  @override
  String get tripsSupport => 'Get help with this trip';

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
      'This number belongs to your sign-in. Use Change phone number to update it.';

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
  String get settingsHelp => 'Help and support';

  @override
  String get settingsTerms => 'Terms and conditions';

  @override
  String get settingsPrivacy => 'Privacy policy';

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

  @override
  String get activeTripTitle => 'Trip tracking';

  @override
  String get activeTripHome => 'Home';

  @override
  String get activeTripFollow => 'Follow my trip';

  @override
  String get activeTripLoading => 'Updating trip…';

  @override
  String get activeTripRefresh => 'Refresh status';

  @override
  String get activeTripEmpty =>
      'There is no trip available to follow right now.';

  @override
  String get activeTripNewBooking => 'Request a ride';

  @override
  String get activeTripScheduledHint =>
      'Your trip is reserved. Driver search starts at the scheduled time.';

  @override
  String get activeTripSearchingHint =>
      'We are looking for a driver for your trip.';

  @override
  String get activeTripAssignedHint =>
      'Your ride was accepted. The driver is preparing to head your way.';

  @override
  String get activeTripEnRouteHint =>
      'Your driver is on the way to the pickup.';

  @override
  String get activeTripArrivedHint =>
      'Your driver has arrived and is waiting at the pickup.';

  @override
  String get activeTripJourneyHint => 'You are on the way to your destination.';

  @override
  String get activeTripCompletedHint =>
      'You have arrived. Your trip is complete.';

  @override
  String get activeTripCancelledHint => 'This trip was cancelled.';

  @override
  String get activeTripNoDriverHint =>
      'No driver was found. You can request another ride with a new quote.';

  @override
  String activeTripPlate(String plate) {
    return 'Plate: $plate';
  }

  @override
  String activeTripRating(String rating) {
    return 'Rating: $rating out of 5';
  }

  @override
  String get activeTripDriverDetails => 'View driver and vehicle details';

  @override
  String get activeTripContactPending => 'Calls are not connected yet.';

  @override
  String get activeTripClose => 'Close';

  @override
  String activeTripRouteSemantics(String pickup, String destination) {
    return 'Route from $pickup to $destination';
  }

  @override
  String get activeTripPositionStale =>
      'The driver location is outdated. Do not rely on its previous position or ETA.';

  @override
  String get activeTripSchematic => 'Schematic route, not a navigation map.';

  @override
  String get activeTripCancelTitle => 'Cancel trip';

  @override
  String get activeTripCancelPrompt => 'Do you want to cancel this trip?';

  @override
  String get activeTripKeep => 'Keep trip';

  @override
  String get activeTripConfirmCancel => 'Confirm cancellation';

  @override
  String get activeTripCancelUncertain =>
      'The cancellation result is uncertain. Retry for the same trip before requesting another.';

  @override
  String get activeTripRetryCancel => 'Retry cancellation';

  @override
  String get activeTripCancelling => 'Cancelling…';

  @override
  String get activeTripRebook => 'Request another ride';

  @override
  String get activeTripDetails => 'Order details';

  @override
  String get activeTripCannotCancel =>
      'The trip has started or changed state and can no longer be cancelled.';

  @override
  String get activeTripNotFound => 'This trip is no longer available.';

  @override
  String get activeTripInvalidResponse =>
      'The trip update could not be verified. Please refresh again.';

  @override
  String get activeTripAccessDenied =>
      'This action requires an authorized session.';

  @override
  String get activeTripUnavailable => 'Trip tracking is currently unavailable.';

  @override
  String get activeTripConnectionLost =>
      'The trip could not be updated. Check your connection and retry.';

  @override
  String get activeTripCached =>
      'This is the last received status. The trip may have changed while disconnected.';

  @override
  String activeTripEta(int minutes) {
    return 'Estimated arrival in $minutes minutes';
  }

  @override
  String get activeTripSimulationNotice =>
      'Trips currently use local simulation until the service is connected.';

  @override
  String get activeTripChat => 'Chat with driver';

  @override
  String get activeTripCompletion => 'Trip summary and rating';

  @override
  String get activeTripSupport => 'Get help with this trip';

  @override
  String get chatTitle => 'Driver';

  @override
  String get chatRetry => 'Retry';

  @override
  String get chatMessageHint => 'Write a message…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatRefresh => 'Refresh conversation';

  @override
  String get chatLoading => 'Loading conversation';

  @override
  String get chatEmpty => 'No messages yet';

  @override
  String get chatReadOnly =>
      'This trip has ended. This conversation is read only.';

  @override
  String get chatLoadOlder => 'Load older messages';

  @override
  String get chatNewest => 'Newest messages';

  @override
  String get chatSent => 'Sent';

  @override
  String get chatDelivered => 'Delivered';

  @override
  String get chatRead => 'Read';

  @override
  String get chatSending => 'Sending…';

  @override
  String get chatFailed => 'Failed to send';

  @override
  String get chatUncertain => 'Send unconfirmed — refresh or retry';

  @override
  String get chatValidation => 'Enter a message from 1 to 1000 characters.';

  @override
  String get chatUnavailable =>
      'Conversation unavailable for this driver or trip.';

  @override
  String get chatSessionEnded => 'Session ended. Return to Home.';

  @override
  String get chatConnectionError =>
      'Connection failed. Previous messages are retained; refresh to try again.';

  @override
  String chatCharacterCount(int count, int max) {
    return '$count / $max characters';
  }

  @override
  String get chatSimulation => 'Simulation';

  @override
  String get completionTitle => 'Trip summary and rating';

  @override
  String get completionLoading => 'Loading trip summary';

  @override
  String get completionSessionEnded =>
      'Your session ended. Return home to continue.';

  @override
  String get completionThankYou => 'Thank you for riding with Tam';

  @override
  String completionTripId(String id) {
    return 'Trip ID: $id';
  }

  @override
  String get completionRecordedFare => 'Recorded booking amount';

  @override
  String get completionFareNote =>
      'The amount recorded at booking; this does not confirm payment or provide a receipt.';

  @override
  String completionDriver(String name) {
    return 'Driver: $name';
  }

  @override
  String get completionRateTrip => 'How was your trip?';

  @override
  String completionStars(int count) {
    return '$count of 5 stars';
  }

  @override
  String get completionComment => 'Optional comment';

  @override
  String completionCommentLimit(int count) {
    return 'Up to $count code points after trimming surrounding whitespace.';
  }

  @override
  String get completionSubmit => 'Submit rating';

  @override
  String get completionSubmitting => 'Submitting rating';

  @override
  String get completionSaved => 'Your rating is saved. Thank you';

  @override
  String get completionImmutable =>
      'Each trip has one rating, which cannot be edited.';

  @override
  String get completionUncertain =>
      'We could not confirm the save. Your rating is kept unchanged; retry to check without duplicating it.';

  @override
  String get completionRetry => 'Check and retry';

  @override
  String get completionSupport => 'Contact support for this trip';

  @override
  String get completionHome => 'Return home';

  @override
  String get completionValidation =>
      'Choose 1–5 stars and keep the comment within the allowed limit.';

  @override
  String get completionNotFound => 'This trip could not be found.';

  @override
  String get completionNotCompleted =>
      'Summary and rating are available after the trip is completed.';

  @override
  String get completionUnavailable =>
      'The rating service integration is currently unavailable.';

  @override
  String get completionAlreadyRated =>
      'This trip was already rated. Checking the saved rating.';

  @override
  String get completionInvalidResponse =>
      'The result could not be verified. Retry to check or contact support.';

  @override
  String get completionOffline =>
      'Could not connect. Check your network and retry.';

  @override
  String get completionSimulationNotice =>
      'Ratings in this version are stored locally for testing until the service is connected.';

  @override
  String get supportTitle => 'Help and support';

  @override
  String get supportIntro =>
      'Create a general support request or choose a trip to report an issue.';

  @override
  String get supportNewTicket => 'New support request';

  @override
  String get supportChooseTrip => 'Choose a trip to report';

  @override
  String get supportMyTickets => 'My support requests';

  @override
  String get supportEmpty => 'No support requests yet.';

  @override
  String get supportLoading => 'Loading';

  @override
  String get supportLoadMore => 'Load more';

  @override
  String get supportCategory => 'Category';

  @override
  String get supportBody => 'Request details';

  @override
  String get supportBodyHint =>
      'Enter 10 to 2000 characters, excluding surrounding whitespace.';

  @override
  String get supportSubmit => 'Send request';

  @override
  String get supportSending => 'Sending';

  @override
  String get supportCreated => 'Support request created';

  @override
  String get supportRetry => 'Retry';

  @override
  String get supportUncertain =>
      'Delivery could not be confirmed. Your details are locked; retry with the same request ID to avoid a duplicate.';

  @override
  String get supportBodyValidation =>
      'The text must contain 10 to 2000 characters after trimming whitespace.';

  @override
  String get supportInvalidCategory =>
      'Choose a valid category for this request.';

  @override
  String get supportNotFound =>
      'This request or trip is unavailable for this account.';

  @override
  String get supportSessionEnded =>
      'The session ended. Support data has been removed from this page.';

  @override
  String get supportConflict =>
      'This request ID was used with different details. This request could not be confirmed.';

  @override
  String get supportOffline =>
      'Unable to connect. Try again when the network is available.';

  @override
  String get supportUnavailable =>
      'Support is currently unavailable. Try again later.';

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusInProgress => 'In progress';

  @override
  String get supportStatusResolved => 'Resolved';

  @override
  String get supportTicketDetails => 'Support request details';

  @override
  String get supportTerms => 'Terms and conditions';

  @override
  String get supportPrivacy => 'Privacy policy';

  @override
  String get supportLegalUnpublished =>
      'Approved content has not been published yet. It will appear here once supplied and approved.';

  @override
  String supportTicketReference(String id) {
    return 'Support request: $id';
  }

  @override
  String supportTripReference(String id) {
    return 'Trip: $id';
  }

  @override
  String supportLegalVersion(String version, String date) {
    return 'Version $version · Published $date';
  }

  @override
  String get supportSimulationNotice =>
      'Support operations in this version are simulated and are not sent to a real support team.';

  @override
  String get accountManagementChangePhone => 'Change phone number';

  @override
  String get accountManagementDeleteAccount => 'Delete account';

  @override
  String get accountManagementSimulation =>
      'Local simulation; no server account is changed or deleted.';

  @override
  String get accountManagementPhone => 'New phone number';

  @override
  String get accountManagementRequestCode => 'Send verification code';

  @override
  String get accountManagementCode => 'Verification code';

  @override
  String get accountManagementOtpHint =>
      'Enter the code sent to the displayed number. This verification is separate from sign-in.';

  @override
  String get accountManagementConfirm => 'Confirm action';

  @override
  String get accountManagementResend => 'Resend code';

  @override
  String get accountManagementRestart => 'Start new verification';

  @override
  String get accountManagementDeleteNotice =>
      'Confirmation ends your session. Deletion cannot be undone from the app.';

  @override
  String get accountManagementDeleteConsent =>
      'I confirm that I want to delete my account';

  @override
  String get accountManagementChanged =>
      'Phone changed. Sign in with the new number.';

  @override
  String get accountManagementDeleted => 'Account deletion confirmed.';

  @override
  String get accountManagementSignOut => 'End session and continue';

  @override
  String get accountManagementBusy => 'Processing action';

  @override
  String get accountManagementRetry => 'Retry';

  @override
  String get accountManagementUncertain =>
      'Confirmation was not received. Details are locked; retry to reconcile the same action.';

  @override
  String get accountManagementActiveTrip =>
      'Finish active trips or cancel scheduled trips before changing the account number or deleting it.';

  @override
  String get accountManagementRequired =>
      'Enter with a phone number to manage an account.';

  @override
  String get accountManagementInvalidPhone =>
      'Enter a valid Syrian mobile number different from the current one.';

  @override
  String get accountManagementPhoneInUse =>
      'This number belongs to another account. Accounts cannot be merged here.';

  @override
  String get accountManagementInvalidCode =>
      'The verification code is incorrect.';

  @override
  String get accountManagementExpired =>
      'Verification expired or attempts were exhausted. Start a new verification when allowed.';

  @override
  String get accountManagementCooldown =>
      'Wait before resending or trying again.';

  @override
  String get accountManagementUnavailable =>
      'Could not complete this action. Retry when the service is available.';

  @override
  String get accountManagementInvalidResponse =>
      'The service response could not be verified. Retry the same action.';

  @override
  String get accountManagementSessionEnded =>
      'The session ended. This form is no longer available.';

  @override
  String get accountManagementChangedNotice =>
      'After verification your session ends; sign in using your new number.';

  @override
  String get accountManagementValidation =>
      'Check the supplied fields and retry.';

  @override
  String get driverContactTitle => 'Call driver';

  @override
  String get driverContactCall => 'Open phone call';

  @override
  String get driverContactHint =>
      'We request the contact available for this trip, then open the phone app. Opening it does not confirm a call.';

  @override
  String get driverContactSimulation =>
      'Opening the dialer was simulated. No fixture number will be called.';

  @override
  String get driverContactOpened => 'The number was handed to the phone app.';

  @override
  String get driverContactBusy => 'Preparing call';

  @override
  String get driverContactUnavailable =>
      'Calling is not available for this trip right now.';

  @override
  String get driverContactChanged =>
      'The assigned driver changed. Return to trip tracking and refresh.';

  @override
  String get driverContactDialerUnavailable =>
      'The phone app could not be opened on this device.';

  @override
  String get driverContactOffline =>
      'The call could not be prepared. Check the network and retry.';

  @override
  String get driverContactSessionEnded =>
      'The session ended. No new call was opened.';
}
