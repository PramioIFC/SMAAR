import 'package:flutter/material.dart';
import '../widgets/gate_card.dart';
import '../models/models.dart';
import 'register_gate_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Gate> _gates = [
    Gate(
      id: 1,
      name: "Porteira 1",
      limitTimeStart: "06:00",
      limitTimeEnd: "23:00",
      isClosed: true,
    ),
    Gate(
      id: 2,
      name: "Porteira 2",
      limitTimeStart: "09:00",
      limitTimeEnd: "22:00",
      isClosed: false,
    ),
    Gate(
      id: 3,
      name: "Porteira 3",
      limitTimeStart: "09:00",
      limitTimeEnd: "22:00",
      isClosed: true,
    ),
  ];

  Future<void> _openRegisterPage() async {
    final result = await Navigator.push<Gate>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterGatePage()),
    );

    if (result != null) {
      setState(() => _gates.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    "tela principal",
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
                "Olá, Usuário 1",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: _gates.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _gates.length,
                        itemBuilder: (context, index) {
                          final gate = _gates[index];
                          return GateCard(
                            gate: gate,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/gate',
                              arguments: gate, // passa o Gate completo
                            ),
                            onHistoryTap: () => Navigator.pushNamed(
                              context,
                              '/history',
                              arguments: gate.id, // passa o id correto
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
        onPressed: _openRegisterPage,
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
            "Nenhuma porteira cadastrada",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Toque em + para adicionar",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
