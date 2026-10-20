import 'package:chatter/app/cubits/app_cubit.dart';
import 'package:chatter/core/di/service_locator.dart';
import 'package:chatter/modules/chat/cubits/chat_cubit.dart';
import 'package:chatter/modules/chat/repository/chat_repository.dart';
import 'package:chatter/modules/conversations/cubits/conversations_cubit.dart';
import 'package:chatter/modules/user/cubits/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocDi extends StatelessWidget {
  final Widget child;
  const BlocDi({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppCubit(
            storageService: sl(),
            authStorage: sl(),
            dioClient: sl(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              UserCubit(userAccountRepository: sl())..loadUser(),
        ),
        BlocProvider(
          create: (context) => ConversationsCubit(conversationRepository: sl(),dioClient: sl()),
        ),
      ],
      child: child,
    );
  }
}
