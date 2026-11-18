import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_feedback.dart';
import 'package:tam_customer/features/ride_request/domain/ride_coupon_offer.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_location_cubit.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_body.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_stage.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_location_access_prompt.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class RideRequestPage extends StatefulWidget {
  const RideRequestPage({
    super.key,
    this.couponOffers = const [],
    this.onActivateCoupon,
    required this.navigation,
    this.savedAddressPickerBuilder,
    this.hasActiveTracking = false,
    this.simulatedTracking = false,
  });
  final CustomerNavigation navigation;
  final bool hasActiveTracking, simulatedTracking;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;
  final List<RideCouponOffer> couponOffers;
  final ValueChanged<String>? onActivateCoupon;
  @override
  State<RideRequestPage> createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage>
    with WidgetsBindingObserver {
  late RideJourneyStep _step;
  RideLocationCubit? _location;
  bool _pickingPickup = false,
      _selectionPending = false,
      _mapSelectionPending = false,
      _settingsPromptOpen = false,
      _initialLocationRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _step = context.read<RideDraftBloc>().state.hasRoute
        ? RideJourneyStep.vehicle
        : RideJourneyStep.places;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final maps = MapsScope.maybeOf(context);
    if (_location != null || maps == null) return;
    _location = RideLocationCubit(
      repository: maps.repository,
      device: maps.deviceLocation,
      settings: maps.locationSettings,
      language: Localizations.localeOf(context).languageCode,
    );
    if (!widget.hasActiveTracking ||
        context.read<ActiveTripCubit>().state.phase == ActiveTripPhase.empty) {
      _locateInitialPickup();
    }
  }

  void _locateInitialPickup() {
    if (_initialLocationRequested ||
        _location == null ||
        context.read<RideDraftBloc>().state.pickup != null) {
      return;
    }
    _initialLocationRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _location?.locate();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _location?.resumed();
      if (widget.hasActiveTracking) {
        context.read<ActiveTripCubit>().refresh(silent: true);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_location?.close());
    super.dispose();
  }

  void _back() {
    final draft = context.read<RideDraftBloc>().state;
    if (draft.confirmedTrip != null ||
        (widget.hasActiveTracking &&
            context.read<ActiveTripCubit>().state.trip != null)) {
      widget.navigation.openHome();
      return;
    }
    if (draft.confirmationPending) return;
    FocusScope.of(context).unfocus();
    if (_location?.state.point != null) {
      _location?.clearPoint();
    } else if (_step == RideJourneyStep.places) {
      Navigator.of(context).maybePop();
    } else {
      setState(() {
        _pickingPickup = false;
        _step = RideJourneyStep.places;
      });
    }
  }

  void _pick(bool pickup) {
    if (context.read<RideDraftBloc>().state.confirmationPending) return;
    _location?.clearPoint();
    setState(() {
      _pickingPickup = pickup;
      _step = RideJourneyStep.places;
    });
  }

  void _manualPickup() {
    _location?.keepManualPickup();
  }

  void _select(TripLocation value) {
    final bloc = context.read<RideDraftBloc>();
    if (_step != RideJourneyStep.places || bloc.state.confirmationPending) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (_pickingPickup) _manualPickup();
    final unchanged =
        (_pickingPickup ? bloc.state.pickup : bloc.state.destination) == value;
    _selectionPending = !unchanged;
    bloc.add(
      _pickingPickup ? PickupSelected(value) : DestinationSelected(value),
    );
    if (unchanged) {
      setState(() {
        if (bloc.state.hasRoute) {
          _step = RideJourneyStep.vehicle;
        } else {
          _pickingPickup = bloc.state.pickup == null;
        }
      });
    }
  }

  void _useMapPoint(TripLocation value, {required bool pickup}) {
    final bloc = context.read<RideDraftBloc>();
    if (bloc.state.confirmationPending) return;
    FocusScope.of(context).unfocus();
    if (pickup) _manualPickup();
    _selectionPending = false;
    final unchanged =
        (pickup ? bloc.state.pickup : bloc.state.destination) == value;
    _mapSelectionPending = !unchanged;
    bloc.add(pickup ? PickupSelected(value) : DestinationSelected(value));
    if (unchanged) _finishMapSelection();
  }

  void _finishMapSelection() {
    _mapSelectionPending = false;
    setState(() {
      final draft = context.read<RideDraftBloc>().state;
      _step = draft.hasRoute ? RideJourneyStep.vehicle : RideJourneyStep.places;
      _pickingPickup = draft.pickup == null;
    });
    // Keep the selected pin until the draft contains its endpoint. The map and
    // panel then see one committed change, never an empty intermediate scene.
    _location?.clearPoint();
  }

  void _continue(RideDraftState state) {
    FocusScope.of(context).unfocus();
    switch (_step) {
      case RideJourneyStep.entry:
        if (state.hasRoute) {
          setState(() => _step = RideJourneyStep.vehicle);
        } else {
          _pick(state.pickup == null);
        }
      case RideJourneyStep.places:
        if (state.hasRoute) setState(() => _step = RideJourneyStep.vehicle);
      case RideJourneyStep.vehicle:
        unawaited(_confirmWithCurrentPickup(state));
    }
  }

  Future<void> _confirmWithCurrentPickup(RideDraftState reviewed) async {
    final bloc = context.read<RideDraftBloc>();
    final pickup = reviewed.pickup;
    if (pickup == null) return;
    // An uncertain submission retries its original idempotent intent.
    final result = !reviewed.pickupFromDevice || reviewed.confirmationPending
        ? PickupValidation.unchanged
        : await _location?.validatePickup(pickup.point) ??
              PickupValidation.unavailable;
    if (!mounted || bloc.state != reviewed) return;
    if (result == PickupValidation.unavailable) return;
    if (result == PickupValidation.moved) {
      bloc.add(
        PickupSelected(
          TripLocation(label: pickup.label, point: _location!.state.fix!),
          fromDevice: true,
        ),
      );
      setState(() => _step = RideJourneyStep.vehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).rideRequestPickupMoved),
        ),
      );
      return;
    }
    bloc.add(const RideConfirmationRequested());
  }

  void _locationChanged(BuildContext context, RideLocationState state) {
    final bloc = context.read<RideDraftBloc>();
    if (state.fix != null &&
        !state.locating &&
        state.failure == null &&
        !bloc.state.confirmationPending) {
      if (bloc.state.pickup == null) {
        bloc.add(
          PickupSelected(
            TripLocation(
              label: AppLocalizations.of(context).mapsCurrentLocation,
              point: state.fix!,
            ),
            fromDevice: true,
          ),
        );
      }
    }
    if (state.failure == 'LOCATION_DISABLED' ||
        state.failure == 'LOCATION_DENIED_FOREVER') {
      unawaited(_promptSettings(context, state.failure!));
    } else if (state.failure != null) {
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mapFailureText(t, state.failure)),
          action: SnackBarAction(
            label: state.failure == 'LOCATION_DENIED'
                ? t.mapsAllowLocation
                : t.mapsRetry,
            onPressed: () =>
                _location?.locate(requireFresh: true, focusMap: true),
          ),
        ),
      );
    }
  }

  Future<void> _promptSettings(
    BuildContext themedContext,
    String failure,
  ) async {
    if (_settingsPromptOpen) return;
    _settingsPromptOpen = true;
    try {
      final open = await showRideLocationAccessPrompt(themedContext, failure);
      if (mounted && open) await _location?.openSettings(failure: failure);
    } finally {
      _settingsPromptOpen = false;
    }
  }

  Widget _draft(BuildContext context, RideLocationState location) =>
      BlocConsumer<RideDraftBloc, RideDraftState>(
        listenWhen: (previous, current) =>
            previous.confirmedTrip?.id != current.confirmedTrip?.id ||
            ((_selectionPending || _mapSelectionPending) &&
                (previous.pickup != current.pickup ||
                    previous.destination != current.destination)),
        listener: (context, state) {
          if (state.confirmedTrip != null) {
            if (widget.hasActiveTracking) {
              context.read<ActiveTripCubit>().track(state.confirmedTrip!);
            } else {
              widget.navigation.openActiveTrip(
                id: state.confirmedTrip!.id,
                replaceCurrent: true,
              );
            }
          } else if (_mapSelectionPending) {
            _finishMapSelection();
          } else if (_selectionPending && !state.searching) {
            _selectionPending = false;
            setState(() {
              if (state.hasRoute) {
                _step = RideJourneyStep.vehicle;
              } else {
                _pickingPickup = state.pickup == null;
              }
            });
          }
        },
        builder: (context, state) => widget.hasActiveTracking
            ? BlocConsumer<ActiveTripCubit, ActiveTripState>(
                listenWhen: (previous, current) =>
                    previous.phase != current.phase &&
                    current.phase == ActiveTripPhase.empty,
                listener: (context, _) => _locateInitialPickup(),
                builder: (context, active) =>
                    _scene(context, state, location, active: active),
              )
            : _scene(context, state, location),
      );

  Widget _scene(
    BuildContext context,
    RideDraftState state,
    RideLocationState location, {
    ActiveTripState? active,
  }) {
    final canConfirm =
        context.read<RideDraftBloc>().canConfirm ||
        (state.failureStep == RideFailureStep.confirmation &&
            state.quote != null);
    final enabled = switch (_step) {
      RideJourneyStep.entry => !state.confirmationPending,
      RideJourneyStep.places => state.hasRoute && !state.confirmationPending,
      RideJourneyStep.vehicle => canConfirm && !location.locating,
    };
    return PopScope(
      canPop:
          (_step == RideJourneyStep.places || active?.trip != null) &&
          location.point == null &&
          !state.confirmationPending,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            maintainBottomViewPadding: true,
            child: RideJourneyBody(
              couponOffers: widget.couponOffers,
              onActivateCoupon: widget.onActivateCoupon,
              active: active,
              navigation: widget.navigation,
              simulated: widget.simulatedTracking,
              step: _step,
              draft: state,
              location: location,
              pickingPickup: _pickingPickup,
              onBack: _back,
              onPickup: () => _pick(true),
              onDestination: () => _pick(false),
              onSelected: _select,
              onContinue: enabled ? () => _continue(state) : null,
              onMapPoint: (point) => _location?.selectPoint(point),
              onMapPickup: (value) => _useMapPoint(value, pickup: true),
              onMapDestination: (value) => _useMapPoint(value, pickup: false),
              onClearPoint: () => _location?.clearPoint(),
              onLocate: _location == null
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      _location!.locate(requireFresh: true, focusMap: true);
                    },
              onSettings: _location?.openSettings,
              savedAddressPickerBuilder: widget.savedAddressPickerBuilder,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.rideJourney(Theme.of(context)),
    child: Builder(
      builder: (context) => _location == null
          ? _draft(context, const RideLocationState())
          : BlocConsumer<RideLocationCubit, RideLocationState>(
              bloc: _location,
              listenWhen: (a, b) =>
                  a.fixRevision != b.fixRevision || a.failure != b.failure,
              listener: _locationChanged,
              builder: (context, state) => _draft(context, state),
            ),
    ),
  );
}
