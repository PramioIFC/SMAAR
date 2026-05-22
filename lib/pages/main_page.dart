import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/models.dart';
import '../widgets/gate_card.dart';
import 'register_gate_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da conta'),
        content: const Text('Deseja encerrar sua sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF757575))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair',
                style: TextStyle(
                    color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppState.of(context).logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final gates = state.gates;
    final userName = state.currentUser?.name ?? 'Usuário';
    // Capitaliza apenas a primeira letra
    final displayName =
        userName.isEmpty ? 'Usuário' : userName[0].toUpperCase() + userName.substring(1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Barra superior ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Minhas Porteiras',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () => _logout(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              color: Color(0xFFE53935), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Sair',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Text(
                'Olá, $displayName',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: gates.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: gates.length,
                        itemBuilder: (context, index) {
                          final gate = gates[index];
                          return GateCard(
                            gate: gate,
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                '/gate',
                                arguments: gate,
                              );
                            },
                            onHistoryTap: () => Navigator.pushNamed(
                              context,
                              '/history',
                              arguments: gate.id,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Gate>(
            context,
            MaterialPageRoute(builder: (_) => const RegisterGatePage()),
          );
          if (result != null && context.mounted) {
            AppState.of(context).addGate(result);
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fence_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhuma porteira cadastrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para adicionar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
