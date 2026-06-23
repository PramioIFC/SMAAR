import 'package:flutter/material.dart';
import 'app_state.dart';
import 'repositories/repositories/gate_repository.dart';
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
    // Repositório real — fala com o backend Django via HTTP/JWT.
    // Para mudar a URL base, edite ApiClient.baseUrl em services/api_client.dart.
    _state = AppStateData(gateRepo: ApiGateRepository());
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

/// Redireciona para /login se não houver sessão ativa.
class _AuthGuard extends StatelessWidget {
  final Widget child;
  const _AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AppState.of(context).isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
