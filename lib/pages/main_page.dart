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

  Future<void> _confirmDelete(BuildContext context, Gate gate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir porteira'),
        content: Text(
          'Tem certeza que deseja excluir "${gate.name}"?\n\n'
          'Todo o histórico de aberturas e fechamentos será apagado permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF757575))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style: TextStyle(
                    color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await AppState.of(context).deleteGate(gate.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${gate.name}" excluída com sucesso.'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: const Color(0xFFD32F2F),
            ),
          );
        }
      }
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
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/logo.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bem-vindo,',
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B5E20),
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_rounded, color: Colors.grey, size: 22),
                      tooltip: 'Sair',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              const Text(
                'Minhas Porteiras',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 16),

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
                            onDeleteTap: () => _confirmDelete(context, gate),
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
            await AppState.of(context).addGate(result);
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
