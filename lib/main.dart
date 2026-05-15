import 'package:flutter/material.dart';
import 'pages/pages.dart';

void main() {
  runApp(const SmaarApp());
}

class SmaarApp extends StatelessWidget {
  const SmaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMAAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/gate': (context) => const GatePage(),
        '/history': (context) => const HistoryPage(),
        '/dayEvents': (context) => const DayEventsPage(),
        '/calendar': (context) => const CalendarPage(),
        '/details': (context) => const DetailsPage(),
      },
    );
  }
}
