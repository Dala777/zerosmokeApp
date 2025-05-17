import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/progress_provider.dart';
import 'services/api_service.dart';
import 'services/progress_service.dart';

void main() {
  // Asegurarse de que las dependencias de Flutter estén inicializadas
  WidgetsFlutterBinding.ensureInitialized();
  
  // Crear instancias de servicios
  final apiService = ApiService();
  final progressService = ProgressService(apiService);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider(progressService)),
      ],
      child: const ZeroSmokeApp(),
    ),
  );
}

class ZeroSmokeApp extends StatelessWidget {
  const ZeroSmokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroSmoke',
      debugShowCheckedModeBanner: false, // Quitar banner de debug
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
