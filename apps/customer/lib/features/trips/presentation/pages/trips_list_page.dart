import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/activity_masthead.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_history_list.dart';

/// Activity journal: content-first layout using the shared brand typography.
class TripsListPage extends StatelessWidget {
  const TripsListPage({super.key, required this.navigation});

  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.activity(Theme.of(context));
    final colors = theme.colorScheme;
    final systemIcons = colors.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: colors.surface,
          statusBarIconBrightness: systemIcons,
          statusBarBrightness: colors.brightness,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarColor: colors.surface,
          systemNavigationBarIconBrightness: systemIcons,
        ),
        child: Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            bottom: false,
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
