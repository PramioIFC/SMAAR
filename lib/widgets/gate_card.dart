import 'package:flutter/material.dart';
import '../models/models.dart';

/// Card de Porteira reutilizável
class GateCard extends StatelessWidget {
  final Gate gate;
  final VoidCallback onTap;
  final VoidCallback onHistoryTap;

  const GateCard({
    super.key,
    required this.gate,
    required this.onTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone da porteira
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.fence, color: Colors.black54, size: 30),
            ),
            const SizedBox(width: 16),

            // Informações centrais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gate.name,
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
                    gate.limitTimeFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Ícones de status e histórico
            Row(
              children: [
                Icon(
                  gate.isClosed ? Icons.lock : Icons.lock_open,
                  color: gate.isClosed ? const Color(0xFF4CAF50) : Colors.redAccent,
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
