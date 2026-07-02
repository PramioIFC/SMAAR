import 'package:flutter/material.dart';
import 'app_state.dart';
import 'services/api_client.dart';                   // [NOVO] para checar token
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

  // [NOVO] Impede que o _AuthGuard redirecione para /login antes de
  // reloadFromToken() terminar — evita o flash de tela de login no boot.
  bool _sessionChecked = false;

  @override
  void initState() {
    super.initState();
    _state = AppStateData(gateRepo: ApiGateRepository());
    _restoreSession(); // [NOVO]
  }

  // [NOVO] Tenta restaurar a sessão a partir do JWT salvo no FlutterSecureStorage.
  // Se tiver token válido, chama reloadFromToken() que faz GET /api/me/ e
  // carrega porteiras/histórico normalmente — usuário vai direto para /
  // sem precisar fazer login de novo.
  Future<void> _restoreSession() async {
    final hasToken = await ApiClient().isAuthenticated;
    if (hasToken) {
      await _state.reloadFromToken();
    }
    if (mounted) setState(() => _sessionChecked = true);
  }

  @override
  Widget build(BuildContext context) {
    // [NOVO] Exibe um loading enquanto _restoreSession() ainda está rodando.
    // Sem esse guard, o _AuthGuard renderiza com isLoggedIn = false e
    // empurra o usuário para /login antes de a sessão ser restaurada.
    if (!_sessionChecked) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
        // [CORRIGIDO] initialRoute dinâmica: vai para / se já estiver logado,
        // para /login caso contrário — o _AuthGuard cobre as rotas protegidas.
        initialRoute: _state.isLoggedIn ? '/' : '/login',
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
