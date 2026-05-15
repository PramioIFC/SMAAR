import 'package:flutter/material.dart';

/// Widget de estado vazio reutilizável
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// Factory para eventos vazios
  factory EmptyState.noEvents() {
    return const EmptyState(
      icon: Icons.calendar_today_rounded,
      title: "Nenhum evento",
      subtitle: "Não há registros para este dia.",
    );
  }

  /// Factory para dados vazios genérico
  factory EmptyState.noData() {
    return const EmptyState(
      icon: Icons.inbox_rounded,
      title: "Sem dados",
      subtitle: "Nenhum registro encontrado.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 38,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
