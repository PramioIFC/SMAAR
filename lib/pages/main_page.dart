import 'package:flutter/material.dart';
import '../widgets/gate_card.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo clean
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Superior
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

              // Saudação
              const Text(
                "Olá, Usuário 1",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 30),

              // Lista de Porteiras
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    GateCard(
                      name: "Porteira 1",
                      limitTime: "6:00-23:00",
                      isClosed: true,
                      // Mudança aqui: de /details para /gate
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/gate',
                        arguments: "Porteira 1",
                      ),
                      onHistoryTap: () =>
                          Navigator.pushNamed(context, '/history'),
                    ),
                    GateCard(
                      name: "Porteira 2",
                      limitTime: "9:00-22:00",
                      isClosed: false,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/gate',
                        arguments: "Porteira 2",
                      ),
                      onHistoryTap: () =>
                          Navigator.pushNamed(context, '/history'),
                    ),
                    GateCard(
                      name: "Porteira 3",
                      limitTime: "9:00-22:00",
                      isClosed: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/gate',
                        arguments: "Porteira 3",
                      ),
                      onHistoryTap: () =>
                          Navigator.pushNamed(context, '/history'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Botão Flutuante para Adicionar
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Exemplo: Direcionando para eventos do dia ou criação
          Navigator.pushNamed(context, '/dayEvents');
        },
        backgroundColor: Colors.grey[300],
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}
