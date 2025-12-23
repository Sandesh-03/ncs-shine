// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ncs_new/providers/feed_provider.dart';
import 'package:ncs_new/repositories/deed_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/deed_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/leaderboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key, });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Core App Providers ---
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        // --- Repository ---
        Provider<DeedRepositoryFirebase>(
          create: (_) => DeedRepositoryFirebase(),
        ),

        // --- DeedProvider depends on DeedRepositoryFirebase ---
        ChangeNotifierProxyProvider<DeedRepositoryFirebase, DeedProvider>(
          create: (context) =>
              DeedProvider(repository: context.read<DeedRepositoryFirebase>()),
          update: (context, repo, previous) =>
          previous ?? DeedProvider(repository: repo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ncs Shine',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
        ),

        // Launch the splash screen first
        initialRoute: '/',

        // App routes
        routes: {
          '/': (_) => const SplashScreen(),
          AuthScreen.routeName: (_) => const AuthScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          LeaderboardScreen.routeName: (_) => const LeaderboardScreen(),
        },
      ),
    );
  }
}
