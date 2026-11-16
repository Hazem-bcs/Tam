import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/activity_masthead.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_history_list.dart';

/// TAM Motion Journal: a distinctive, purpose-driven activity surface.
class TripsListPage extends StatelessWidget {
  const TripsListPage({super.key, required this.navigation});

  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // The burgundy activity header continues behind the Android status bar.
    // On edge-to-edge devices Flutter paints the safe-area inset itself;
    // on older Android versions statusBarColor colors the native system bar.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: colors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.primary,
        body: SafeArea(
          bottom: false,
          child: ColoredBox(
            color: colors.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ActivityMasthead(navigation: navigation),
                    Expanded(
                      child: BlocBuilder<TripsListCubit, TripsListState>(
                        builder: (context, state) => TripHistoryList(
                          state: state,
                          navigation: navigation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
