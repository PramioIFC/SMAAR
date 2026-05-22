import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/history_page.dart';
import 'pages/details_page.dart';
import 'pages/day_events_page.dart';
import 'pages/gate_page.dart';
import 'pages/calendar_page.dart';
import 'pages/register_gate_page.dart';

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
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'sans-serif',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/gate': (context) => const GatePage(),
        '/history': (context) => const HistoryPage(),
        '/calendar': (context) => const CalendarPage(),
        '/dayEvents': (context) => const DayEventsPage(),
        '/details': (context) => const DetailsPage(),
        '/registerGate': (context) => const RegisterGatePage(),
      },
    );
  }
}
