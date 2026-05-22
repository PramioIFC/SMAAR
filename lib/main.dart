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
import 'pages/login_page.dart';
import 'pages/register_user_page.dart';

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

    final eventRepo = MockEventRepository();
    final logRepo   = MockLogRepository();

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

    _state = AppStateData(
      gates:  gates,
      events: eventRepo.rawByGate,
      logs:   logRepo.rawByGate,
    );
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
        // O app sempre abre na tela de login
        initialRoute: '/login',
        routes: {
          '/login':        (context) => const LoginPage(),
          '/register':     (context) => const RegisterUserPage(),
          '/':             (context) => const _AuthGuard(child: MainPage()),
          '/gate':         (context) => const _AuthGuard(child: GatePage()),
          '/history':      (context) => const _AuthGuard(child: HistoryPage()),
          '/calendar':     (context) => const _AuthGuard(child: CalendarPage()),
          '/dayEvents':    (context) => const _AuthGuard(child: DayEventsPage()),
          '/details':      (context) => const _AuthGuard(child: DetailsPage()),
          '/registerGate': (context) => const _AuthGuard(child: RegisterGatePage()),
        },
      ),
    );
  }
}

/// Guarda de rota: redireciona para /login se não houver sessão ativa.
/// Envolve qualquer página que exija autenticação.
class _AuthGuard extends StatelessWidget {
  final Widget child;
  const _AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AppState.of(context).isLoggedIn;
    if (!isLoggedIn) {
      // Agenda o redirecionamento após o frame atual para evitar erros de build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (_) => false,
        );
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
