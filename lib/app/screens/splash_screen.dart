import 'package:chatter/app/cubits/app_cubit.dart';
import 'package:chatter/modules/authentication/screens/login_screen.dart';
import 'package:chatter/modules/conversations/screens/conversations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<AppCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listener: (context, state) {
        if (state.authStatus == AuthStatus.authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ConversationsScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Text(
            'Chatter',
            style: TextStyle(
              fontSize: 40,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFC6A15B),
            ),
          ),
        ),
      ),
    );
  }
}
