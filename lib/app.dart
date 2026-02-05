import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_repositorie.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/features/network/network-alert-controller.dart';
import 'package:flutter_ekg_detector/features/scan/ekg_repository.dart';
import 'package:flutter_ekg_detector/features/scan/scan_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/scan_event.dart';
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
  @override
  Widget build(BuildContext context) {
    // 1. Gunakan MultiRepositoryProvider di level paling atas
    return MultiRepositoryProvider(
      providers: [
        // Inject EkgRepository agar bisa dibaca oleh ScanBloc
        RepositoryProvider<EkgRepository>(create: (context) => EkgRepository()),
        // Opsional: Inject AuthRepository juga agar konsisten
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            // Sekarang kita bisa baca AuthRepository dari context juga (Best Practice)
            // atau tetap pakai 'AuthRepository()' manual seperti kode lama Anda juga boleh.
            create: (context) =>
                AuthBloc(context.read<AuthRepository>())..add(AppStarted()),
          ),
          BlocProvider<ScanBloc>(
            // 2. Sekarang context.read<EkgRepository>() akan BERHASIL
            // karena sudah disediakan oleh RepositoryProvider di atasnya
            create: (context) =>
                ScanBloc(context.read<EkgRepository>())..add(InitModel()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Montserrat', useMaterial3: true),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
