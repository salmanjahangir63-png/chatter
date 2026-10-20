import 'package:chatter/app/bloc/app_bloc_observer.dart';
import 'package:chatter/app/my_app.dart';
import 'package:chatter/core/initializer/init_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  /// =============== App initialization ==================
  await initApp();
  runApp(const ChatApp());
}


