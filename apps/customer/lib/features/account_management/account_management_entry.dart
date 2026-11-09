import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'domain/account_management_repository.dart';
import 'presentation/bloc/account_management_cubit.dart';
import 'presentation/pages/account_management_page.dart';
export 'domain/account_management_repository.dart';

typedef AccountManagementParams = ({
  AccountAction action,
  DateTime Function() now,
});
void registerAccountManagementDependencies(GetIt dependencies) {
  dependencies.registerFactoryParam<
    AccountManagementCubit,
    AccountManagementRepository,
    AccountManagementParams
  >(
    (repository, params) => AccountManagementCubit(
      repository,
      action: params.action,
      now: params.now,
    ),
  );
}

Widget buildAccountManagementFeature({
  required AccountManagementRepository repository,
  required AccountAction action,
  required DateTime Function() now,
  required VoidCallback onBack,
  required Future<void> Function() onCompleted,
}) => BlocProvider(
  key: ValueKey((repository, action)),
  create: (_) =>
      (locator.isRegistered<AccountManagementCubit>()
            ? locator<AccountManagementCubit>(
                param1: repository,
                param2: (action: action, now: now),
              )
            : AccountManagementCubit(repository, action: action, now: now))
        ..load(),
  child: AccountManagementPage(onBack: onBack, onCompleted: onCompleted),
);
