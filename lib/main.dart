

import 'package:flutter/material.dart';
import 'package:soundofmeme/screens/Landing_Screen.dart';
import 'package:soundofmeme/screens/Login_Screen.dart';
import 'package:soundofmeme/screens/Prompt_Screen.dart';
import 'package:soundofmeme/screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute: '/landing',
      routes: {
        '/landing': (context) => LandingScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        SignupScreen.routeName: (context) => SignupScreen(),
        PromptScreen.routeName: (context) => PromptScreen(),
      },

      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          elevation: 0
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade900,
        
      ),
      home: const LandingScreen()
      );
  }
}

