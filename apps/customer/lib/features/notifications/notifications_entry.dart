import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'domain/notifications_repository.dart';
import 'presentation/bloc/notifications_cubit.dart';
import 'presentation/pages/notifications_page.dart';

Widget buildNotificationsFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required NotificationsRepository repository,
}) => BlocProvider(
  create: (_) => NotificationsCubit(repository)..load(),
  child: NotificationsPage(navigation: navigation),
);
