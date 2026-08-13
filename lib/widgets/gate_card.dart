import 'package:flutter/material.dart';
import '../models/models.dart';

/// Card de Porteira reutilizável
class GateCard extends StatelessWidget {
  final Gate gate;
  final VoidCallback onTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onDeleteTap;

  const GateCard({
    super.key,
    required this.gate,
    required this.onTap,
    required this.onHistoryTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Lixeira alinhada ao topo direito, dentro do card
            GestureDetector(
              onTap: onDeleteTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade300,
                  size: 20,
                ),
              ),
            ),

            Row(
              children: [
                // Ícone da porteira
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: const Icon(Icons.fence_rounded, color: Color(0xFF4CAF50), size: 30),
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
          ],
        ),
      ),
    );
  }
}
