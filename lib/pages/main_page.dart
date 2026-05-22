import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/models.dart';
import '../widgets/gate_card.dart';
import 'register_gate_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lê o AppState — rebuilda automaticamente quando notifyListeners() é chamado
    final state = AppState.of(context);
    final gates = state.gates;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'tela principal',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.black87),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                'Olá, Usuário 1',
                style: TextStyle(
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
