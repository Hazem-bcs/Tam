import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_backdrop.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_stage.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class RideRequestPage extends StatefulWidget {
  const RideRequestPage({
    super.key,
    required this.navigation,
    this.savedAddressPickerBuilder,
  });
  final CustomerNavigation navigation;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;
  @override
  State<RideRequestPage> createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage> {
  late RideJourneyStep _step;
  bool _pickingPickup = true;
  bool _selectionPending = false;

  @override
  void initState() {
    super.initState();
    _step = context.read<RideDraftBloc>().state.hasRoute
        ? RideJourneyStep.vehicle
        : RideJourneyStep.entry;
  }

  void _back() {
    if (context.read<RideDraftBloc>().state.confirmationPending) return;
    FocusScope.of(context).unfocus();
    if (_step == RideJourneyStep.entry) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step = RideJourneyStep.values[_step.index - 1]);
    }
  }

  void _pick(bool pickup) {
    if (context.read<RideDraftBloc>().state.confirmationPending) return;
    setState(() {
      _pickingPickup = pickup;
      _step = RideJourneyStep.places;
    });
  }

  void _select(TripLocation value) {
    final bloc = context.read<RideDraftBloc>();
    if (_step != RideJourneyStep.places || bloc.state.confirmationPending) {
      return;
    }
    FocusScope.of(context).unfocus();
    _selectionPending = true;
    bloc.add(
      _pickingPickup ? PickupSelected(value) : DestinationSelected(value),
    );
  }

  void _continue(RideDraftState state) {
    FocusScope.of(context).unfocus();
    switch (_step) {
      case RideJourneyStep.entry:
        _pick(state.pickup == null);
      case RideJourneyStep.places:
        if (state.hasRoute) setState(() => _step = RideJourneyStep.vehicle);
      case RideJourneyStep.vehicle:
        if (state.hasRoute) setState(() => _step = RideJourneyStep.review);
      case RideJourneyStep.review:
        context.read<RideDraftBloc>().add(const RideConfirmationRequested());
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.rideJourney(Theme.of(context)),
    child: Builder(
      builder: (context) => BlocConsumer<RideDraftBloc, RideDraftState>(
        listenWhen: (previous, current) =>
            previous.confirmedTrip?.id != current.confirmedTrip?.id ||
            (_selectionPending &&
                (previous.pickup != current.pickup ||
                    previous.destination != current.destination)),
        listener: (context, state) {
          if (state.confirmedTrip != null) {
            widget.navigation.openActiveTrip(id: state.confirmedTrip!.id);
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
        builder: (context, state) {
          final t = AppLocalizations.of(context);
          final reduced = MediaQuery.disableAnimationsOf(context);
          final canConfirm =
              context.read<RideDraftBloc>().canConfirm ||
              (state.failureStep == RideFailureStep.confirmation &&
                  state.quote != null);
          final enabled = switch (_step) {
            RideJourneyStep.entry => !state.confirmationPending,
            RideJourneyStep.places =>
              state.hasRoute && !state.confirmationPending,
            RideJourneyStep.vehicle =>
              state.hasRoute &&
                  state.quote != null &&
                  !state.confirmationPending &&
                  state.status != RideFlowStatus.quoting,
            RideJourneyStep.review => canConfirm,
          };
          return PopScope(
            canPop:
                _step == RideJourneyStep.entry && !state.confirmationPending,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _back();
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).colorScheme.surface,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: Theme.of(context).colorScheme.surface,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
              child: Scaffold(
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: LayoutBuilder(
                        builder: (context, bounds) {
                          final short = bounds.maxHeight < 500;
                          final largeText =
                              MediaQuery.textScalerOf(context).scale(16) > 24;
                          final fraction = switch (_step) {
                            RideJourneyStep.entry => .46,
                            RideJourneyStep.places => .80,
                            RideJourneyStep.vehicle => .70,
                            RideJourneyStep.review => .68,
                          };
                          final height = math.min(
                            math.max(bounds.maxHeight * fraction, 330.0),
                            math.max(160.0, bounds.maxHeight - 80),
                          );
                          final sheet = RideJourneyStage(
                            step: _step,
                            state: state,
                            pickingPickup: _pickingPickup,
                            onPickup: () => _pick(true),
                            onDestination: () => _pick(false),
                            onSelected: _select,
                            onContinue: enabled ? () => _continue(state) : null,
                            savedAddressPickerBuilder:
                                widget.savedAddressPickerBuilder,
                          );
                          final header = Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                IconButton(
                                  key: const Key('ride-flow-back'),
                                  onPressed: state.confirmationPending
                                      ? null
                                      : _back,
                                  tooltip: MaterialLocalizations.of(
                                    context,
                                  ).backButtonTooltip,
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                                Expanded(
                                  child: Text(
                                    t.appName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  ),
                                ),
                                Text(
                                  t.rideRequestFlowStep(_step.index + 1, 5),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          );
                          final backdrop = RideJourneyBackdrop(
                            pickup: state.pickup,
                            destination: state.destination,
                            compact: _step != RideJourneyStep.entry,
                          );
                          if (short && bounds.maxWidth > 600 && !largeText) {
                            return Column(
                              children: [
                                header,
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: backdrop),
                                      Expanded(child: sheet),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return Stack(
                            children: [
                              Positioned.fill(
                                bottom: height - 24,
                                child: backdrop,
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: header,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: reduced
                                      ? Duration.zero
                                      : AppMotion.long,
                                  curve: AppMotion.easeOut,
                                  height: largeText
                                      ? bounds.maxHeight - 80
                                      : height,
                                  child: AnimatedSwitcher(
                                    duration: reduced
                                        ? Duration.zero
                                        : AppMotion.medium,
                                    switchInCurve: AppMotion.easeOut,
                                    child: KeyedSubtree(
                                      key: ValueKey(_step),
                                      child: sheet,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
