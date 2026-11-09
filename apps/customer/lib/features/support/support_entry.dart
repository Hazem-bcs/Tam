import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'domain/support_repository.dart';
import 'presentation/bloc/legal_cubit.dart';
import 'presentation/bloc/support_detail_cubit.dart';
import 'presentation/bloc/support_editor_cubit.dart';
import 'presentation/bloc/support_list_cubit.dart';
import 'presentation/pages/legal_page.dart';
import 'presentation/pages/support_editor_page.dart';
import 'presentation/pages/support_page.dart';
import 'presentation/pages/support_ticket_page.dart';
export 'domain/support_repository.dart';

typedef SupportEditorParams = ({
  SupportPolicy policy,
  DateTime Function() now,
  String? tripId,
});
typedef LegalParams = ({LegalDocumentKind kind, String languageCode});
void registerSupportDependencies(GetIt dependencies) {
  dependencies.registerFactoryParam<SupportListCubit, SupportRepository, void>(
    (repository, _) => SupportListCubit(repository),
  );
  dependencies.registerFactoryParam<
    SupportEditorCubit,
    SupportRepository,
    SupportEditorParams
  >(
    (repository, params) => SupportEditorCubit(
      repository,
      policy: params.policy,
      now: params.now,
      tripId: params.tripId,
    ),
  );
  dependencies
      .registerFactoryParam<SupportDetailCubit, SupportRepository, String>(
        (repository, id) => SupportDetailCubit(repository, id),
      );
  dependencies.registerFactoryParam<LegalCubit, SupportRepository, LegalParams>(
    (repository, params) => LegalCubit(
      repository,
      kind: params.kind,
      languageCode: params.languageCode,
    ),
  );
}

Widget buildSupportFeature({
  required SupportRepository repository,
  required SupportPolicy policy,
  required DateTime Function() now,
  required VoidCallback onBack,
  required VoidCallback onCreate,
  required ValueChanged<String> onTicket,
  required VoidCallback onChooseTrip,
}) => BlocProvider(
  key: ValueKey(repository),
  create: (_) =>
      (locator.isRegistered<SupportListCubit>()
            ? locator<SupportListCubit>(param1: repository)
            : SupportListCubit(repository))
        ..load(),
  child: SupportPage(
    onBack: onBack,
    onCreate: onCreate,
    onTicket: onTicket,
    onChooseTrip: onChooseTrip,
  ),
);
Widget buildSupportEditorFeature({
  required SupportRepository repository,
  required SupportPolicy policy,
  required DateTime Function() now,
  String? tripId,
  required VoidCallback onBack,
  required ValueChanged<String> onCreated,
}) => BlocProvider(
  key: ValueKey((repository, tripId)),
  create: (_) =>
      (locator.isRegistered<SupportEditorCubit>()
            ? locator<SupportEditorCubit>(
                param1: repository,
                param2: (policy: policy, now: now, tripId: tripId),
              )
            : SupportEditorCubit(
                repository,
                policy: policy,
                now: now,
                tripId: tripId,
              ))
        ..load(),
  child: SupportEditorPage(onBack: onBack, onCreated: onCreated),
);
Widget buildSupportTicketFeature({
  required SupportRepository repository,
  required String id,
  required VoidCallback onBack,
}) => BlocProvider(
  key: ValueKey((repository, id)),
  create: (_) =>
      (locator.isRegistered<SupportDetailCubit>()
            ? locator<SupportDetailCubit>(param1: repository, param2: id)
            : SupportDetailCubit(repository, id))
        ..load(),
  child: SupportTicketDetailsPage(onBack: onBack),
);
Widget buildLegalFeature({
  required SupportRepository repository,
  required LegalDocumentKind kind,
  required String languageCode,
  required VoidCallback onBack,
}) => BlocProvider(
  key: ValueKey((repository, kind, languageCode)),
  create: (_) =>
      (locator.isRegistered<LegalCubit>()
            ? locator<LegalCubit>(
                param1: repository,
                param2: (kind: kind, languageCode: languageCode),
              )
            : LegalCubit(repository, kind: kind, languageCode: languageCode))
        ..load(),
  child: LegalPage(onBack: onBack),
);
