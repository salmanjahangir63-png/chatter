import 'package:bot_toast/bot_toast.dart';
import 'package:chatter/app/bloc/bloc_di.dart';
import 'package:chatter/app/screens/splash_screen.dart';
import 'package:chatter/ui/widgets/unfocus.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocDi(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Chat Owner',
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget? child) {
          child = BotToastInit()(context, child);
          child = Unfocus(child: child);
          return child;
        },
        navigatorObservers: [BotToastNavigatorObserver()],
        home: SplashScreen(),
      ),
    );
  }
}
