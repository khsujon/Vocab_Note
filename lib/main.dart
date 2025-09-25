import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/vocab_note.dart';
import 'viewmodels/vocab_viewmodel.dart';
import 'views/splash_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VocabNoteAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VocabViewModel()..loadVocabList(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vocab_Note',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
            primary: Colors.deepPurple,
            secondary: Colors.tealAccent,
            surface: const Color(0xFF23272F),
            background: const Color(0xFF181A20),
          ),
          scaffoldBackgroundColor: const Color(0xFF181A20),
          cardColor: const Color(0xFF23272F),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF181A20), // Match scaffold background
            foregroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.tealAccent),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF23272F),
            border: OutlineInputBorder(),
            hintStyle: TextStyle(color: Colors.white70),
            labelStyle: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.tealAccent),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
