import 'package:flutter/material.dart';

class GateCard extends StatelessWidget {
  final String name;
  final String limitTime;
  final bool isClosed;
  final VoidCallback onHistoryTap;
  final VoidCallback onTap;

  const GateCard({
    super.key,
    required this.name,
    required this.limitTime,
    required this.isClosed,
    required this.onHistoryTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Fundo cinza claro como solicitado
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone da porteira/fazenda
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.fence, color: Colors.black54, size: 30),
            ),
            const SizedBox(width: 16),

            // Informações Centrais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Horário Limite",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    limitTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Ícones de Status e Histórico
            Row(
              children: [
                Icon(
                  isClosed ? Icons.lock : Icons.lock_open,
                  color: isClosed ? Colors.teal : Colors.redAccent,
                  size: 35,
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: Colors.black45,
                    size: 30,
                  ),
                  onPressed: onHistoryTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
