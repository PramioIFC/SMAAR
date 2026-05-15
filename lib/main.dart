import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/history_page.dart';
import 'pages/details_page.dart';
import 'pages/dayEvents_page.dart';
import 'pages/gate_page.dart';
import 'pages/calendar_page.dart';

void main() {
  runApp(const SmaarApp());
}

class SmaarApp extends StatelessWidget {
  const SmaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMAAR',
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'sans-serif', // Garante um visual moderno
      ),
      // Definindo a tela inicial
      initialRoute: '/',
      // Mapeando os nomes das rotas para as páginas
      routes: {
        '/': (context) => const MainPage(),
        '/gate': (context) => const GatePage(),
        '/history': (context) => const HistoryPage(),
        '/calendar': (context) => const CalendarPage(),
        '/dayEvents': (context) => const DayEventsPage(),
        '/details': (context) => const DetailsPage(),
      },
    );
  }
}
