import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jetpack/providers/admin_provider.dart';
import 'package:jetpack/providers/delivery_provider.dart';
import 'package:jetpack/providers/expeditor_provider.dart';
import 'package:jetpack/providers/menu_provider.dart';
import 'package:jetpack/providers/notification_provider.dart';
import 'package:jetpack/providers/statistics.dart';
import 'package:jetpack/providers/theme_notifier.dart';
import 'package:jetpack/providers/user_provider.dart';
import 'package:jetpack/services/shared_data.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/splash%20screen/custom_splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await DataPrefrences.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ExpeditorProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => Statistics()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'jetpack',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CustomSplashScreen(),
    );
  }
}
