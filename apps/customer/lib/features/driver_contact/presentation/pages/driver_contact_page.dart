import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import '../../domain/driver_contact_repository.dart';
import '../bloc/driver_contact_cubit.dart';

class DriverContactPage extends StatefulWidget {
  const DriverContactPage({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  State<DriverContactPage> createState() => _DriverContactPageState();
}

class _DriverContactPageState extends State<DriverContactPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => context
      .read<DriverContactCubit>()
      .setActive(state == AppLifecycleState.resumed);
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.driverContactTitle),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<DriverContactCubit, DriverContactState>(
              builder: (context, state) => ListView(
                padding: AppSpacing.pagePadding,
                children: [
                  Text(l.driverContactHint),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.ended) Text(l.driverContactSessionEnded),
                  if (state.result != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        state.result == DialerResult.simulated
                            ? l.driverContactSimulation
                            : l.driverContactOpened,
                      ),
                    ),
                  if (state.failure != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        switch (state.failure) {
                          'DRIVER_CHANGED' => l.driverContactChanged,
                          'CONTACT_UNAVAILABLE' ||
                          'TRIP_NOT_FOUND' => l.driverContactUnavailable,
                          'DIALER_UNAVAILABLE' =>
                            l.driverContactDialerUnavailable,
                          _ => l.driverContactOffline,
                        },
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  TamButton.primary(
                    key: const Key('driver-contact-call'),
                    label: l.driverContactCall,
                    loadingLabel: l.driverContactBusy,
                    isLoading: state.busy,
                    icon: Icons.phone_outlined,
                    onPressed: state.busy || state.ended
                        ? null
                        : context.read<DriverContactCubit>().call,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
