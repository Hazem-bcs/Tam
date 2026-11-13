import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_unread_count_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class HomeNotificationsButton extends StatelessWidget {
  const HomeNotificationsButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeUnreadCountCubit, int?>(
    builder: (context, count) {
      final t = AppLocalizations.of(context);
      final label = count == null
          ? t.navNotifications
          : t.homeUnreadNotifications(count);
      return IconButton(
        key: const Key('home-notifications'),
        onPressed: onPressed,
        tooltip: label,
        icon: Semantics(
          label: label,
          child: ExcludeSemantics(
            child: Badge(
              isLabelVisible: count != null && count > 0,
              label: Text(
                MaterialLocalizations.of(context).formatDecimal(count ?? 0),
              ),
              child: const Icon(Icons.notifications_none_outlined),
            ),
          ),
        ),
      );
    },
  );
}
