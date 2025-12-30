import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personal_app/screens/auth_wrapper.dart';
import 'package:personal_app/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:personal_app/services/auth_service.dart';
import 'package:personal_app/models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        StreamProvider<UserModel?>(
          create: (context) => context.read<AuthService>().currentUserStream,
          initialData: null,
          catchError: (_, err) => null,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Personal',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}
