import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_commerce/presentation/dashboard.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.light(primary: Colors.blue),
          appBarTheme: const AppBarTheme(
            color: Colors.blue,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
        home: const Dashboard());
  }
}
