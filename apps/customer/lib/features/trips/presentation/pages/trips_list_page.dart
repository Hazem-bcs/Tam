import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/activity_masthead.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_history_list.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trips_activity_navigation.dart';

/// TAM Motion Journal: a distinctive, purpose-driven activity surface.
class TripsListPage extends StatelessWidget {
  const TripsListPage({super.key, required this.navigation});

  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: TripsActivityNavigation(navigation: navigation),
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
                    builder: (context, state) =>
                        TripHistoryList(state: state, navigation: navigation),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
