import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_repositorie.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/features/network/network-alert-controller.dart';
import 'package:flutter_ekg_detector/screens/screen_splash.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityResult? _lastStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription = Connectivity().onConnectivityChanged.listen(
        _handleNetworkChange,
      );
    });
  }

  void _handleNetworkChange(List<ConnectivityResult> results) {
    final result = results.first;

    if (result == _lastStatus) return;
    _lastStatus = result;

    debugPrint('[NetworkConnectivityListener] $result');

    if (!mounted) return;

    // ✔️ Ambil overlay langsung dari NavigatorState
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    if (result == ConnectivityResult.none) {
      NetworkAlertController.showDisconnected(overlayState);
    } else {
      NetworkAlertController.showConnected(overlayState);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(AuthRepository())..add(AppStarted()),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Montserrat', useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}
