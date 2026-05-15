import 'package:flutter/material.dart';

class GatePage extends StatelessWidget {
  const GatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String gateName =
        ModalRoute.of(context)!.settings.arguments as String? ?? "Porteira";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          gateName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10), // Reduzido

              const Text(
                "STATUS DA PORTEIRA",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Reduzido
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 15), // Reduzido
              // Círculo Central de Status - Tamanho Reduzido
              Container(
                width: 180, // Era 220
                height: 180, // Era 220
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 90, // Reduzido
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "FECHADA",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 34, // Reduzido
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Card de Atividade - Mais compacto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Última atividade:",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "07:16",
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: " - Fechada corretamente"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Botões de Ação - Altura reduzida
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: "ABRIR",
                      icon: Icons.unarchive_outlined,
                      color: const Color(0xFF4CAF50),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildActionButton(
                      label: "FECHAR",
                      icon: Icons.lock_person_outlined,
                      color: const Color(0xFFD32F2F),
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Botão HISTÓRICO - Altura reduzida
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/history'),
                child: Container(
                  width: double.infinity,
                  height: 60, // Era 70
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black26, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: Color(0xFF1976D2), size: 28),
                      SizedBox(width: 10),
                      Text(
                        "HISTÓRICO",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130, // Era 160
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 50), // Reduzido
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18, // Reduzido
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
