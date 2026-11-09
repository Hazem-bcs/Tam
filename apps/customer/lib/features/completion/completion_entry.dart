import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'domain/completion_repository.dart';
import 'presentation/bloc/completion_cubit.dart';
import 'presentation/pages/completion_page.dart';
export 'domain/completion_repository.dart';

typedef CompletionParams = ({
  String tripId,
  CompletionPolicy policy,
  DateTime Function() now,
});
void registerCompletionDependencies(GetIt dependencies) {
  dependencies.registerFactoryParam<
    CompletionCubit,
    CompletionRepository,
    CompletionParams
  >(
    (repository, params) => CompletionCubit(
      repository,
      tripId: params.tripId,
      policy: params.policy,
      now: params.now,
    ),
  );
}

Widget buildCompletionFeature({
  required CompletionRepository repository,
  required String tripId,
  required CompletionPolicy policy,
  required DateTime Function() now,
  required VoidCallback onBack,
  required VoidCallback onSupport,
  required VoidCallback onHome,
}) => BlocProvider(
  key: ValueKey((repository, tripId)),
  create: (_) => locator.isRegistered<CompletionCubit>()
      ? locator<CompletionCubit>(
          param1: repository,
          param2: (tripId: tripId, policy: policy, now: now),
        )
      : CompletionCubit(repository, tripId: tripId, policy: policy, now: now),
  child: CompletionPage(onBack: onBack, onSupport: onSupport, onHome: onHome),
);
