import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_repositorie.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/screens/screen_splash.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(AuthRepository())..add(AppStarted()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
