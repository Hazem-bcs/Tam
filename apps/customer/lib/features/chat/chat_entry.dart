import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'data/mock/mock_chat_repository.dart';
import 'domain/chat_repository.dart';
import 'presentation/bloc/chat_cubit.dart';
import 'presentation/pages/chat_page.dart';
export 'domain/chat_repository.dart';

typedef ChatParams = ({
  String tripId,
  ChatPolicy policy,
  DateTime Function() now,
});
void registerChatDependencies(GetIt dependencies) {
  dependencies.registerFactoryParam<ChatCubit, ChatRepository, ChatParams>(
    (repository, params) => ChatCubit(
      repository,
      tripId: params.tripId,
      policy: params.policy,
      now: params.now,
    ),
  );
}

Widget buildChatFeature({
  required ChatRepository repository,
  required String tripId,
  required ChatPolicy policy,
  required DateTime Function() now,
  required VoidCallback onBack,
}) => BlocProvider(
  key: ValueKey((repository, tripId)),
  create: (_) => locator.isRegistered<ChatCubit>()
      ? locator<ChatCubit>(
          param1: repository,
          param2: (tripId: tripId, policy: policy, now: now),
        )
      : ChatCubit(repository, tripId: tripId, policy: policy, now: now),
  child: ChatPage(
    onBack: onBack,
    showDemoAvatar: repository is MockChatRepository,
  ),
);
