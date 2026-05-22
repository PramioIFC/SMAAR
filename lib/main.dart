import 'package:flutter/material.dart';
import 'app_state.dart';
import 'models/models.dart';
import 'repositories/repositories/event_repository.dart';
import 'repositories/repositories/log_repository.dart';
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

class SmaarApp extends StatefulWidget {
  const SmaarApp({super.key});

  @override
  State<SmaarApp> createState() => _SmaarAppState();
}

class _SmaarAppState extends State<SmaarApp> {
  late final AppStateData _state;

  @override
  void initState() {
    super.initState();

    // Copia dados dos repositórios mock para a memória mutável do AppState
    final eventRepo = MockEventRepository();
    final logRepo = MockLogRepository();

    // Porteiras iniciais
    final gates = <Gate>[
      Gate(
        id: 1,
        name: 'Porteira 1',
        limitTimeStart: '06:00',
        limitTimeEnd: '23:00',
        isClosed: true,
      ),
      Gate(
        id: 2,
        name: 'Porteira 2',
        limitTimeStart: '09:00',
        limitTimeEnd: '22:00',
        isClosed: false,
      ),
      Gate(
        id: 3,
        name: 'Porteira 3',
        limitTimeStart: '09:00',
        limitTimeEnd: '22:00',
        isClosed: true,
      ),
    ];

    // Eventos mock copiados diretamente do repositório (acesso via campo interno)
    final events = eventRepo.rawByGate;

    // Logs mock copiados do repositório
    final logs = logRepo.rawByGate;

    _state = AppStateData(gates: gates, events: events, logs: logs);
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      state: _state,
      child: MaterialApp(
        title: 'SMAAR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
      ),
    );
  }
}
