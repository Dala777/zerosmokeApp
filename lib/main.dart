import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/notification_provider.dart';
import 'services/api_service.dart';
import 'services/progress_service.dart';
import 'services/gamification_service.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final progressService = ProgressService(apiService);
  final gamificationService = GamificationService();
  final notificationService = NotificationService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider(progressService)),
        ChangeNotifierProvider(create: (_) => GamificationProvider(gamificationService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(notificationService)),
      ],
      child: const _FcmGate(child: ZeroSmokeApp()),
    ),
  );
}

class _FcmGate extends StatefulWidget {
  final Widget child;
  const _FcmGate({required this.child});

  @override
  State<_FcmGate> createState() => _FcmGateState();
}

class _FcmGateState extends State<_FcmGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initializeFcm();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ZeroSmokeApp extends StatelessWidget {
  const ZeroSmokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroSmoke',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.text),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
