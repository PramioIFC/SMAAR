import 'package:flutter/material.dart';

/// Card de histórico reutilizável
class HistoryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final Color contentColor;
  final bool hasBorder;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.backgroundColor,
    required this.contentColor,
    this.hasBorder = false,
    required this.onTap,
  });

  /// Factory para criar card de "Hoje"
  factory HistoryCard.today({
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return HistoryCard(
      title: "Hoje",
      subtitle: subtitle,
      backgroundColor: const Color(0xFFE8F5E9),
      contentColor: const Color(0xFF2E7D32),
      onTap: onTap,
    );
  }

  /// Factory para criar card de "Ontem"
  factory HistoryCard.yesterday({
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return HistoryCard(
      title: "Ontem",
      subtitle: subtitle,
      backgroundColor: const Color(0xFFE3F2FD),
      contentColor: const Color(0xFF1565C0),
      onTap: onTap,
    );
  }

  /// Factory para criar card de data comum
  factory HistoryCard.date({
    required String date,
    required VoidCallback onTap,
  }) {
    return HistoryCard(
      title: date,
      backgroundColor: Colors.white,
      contentColor: Colors.black87,
      hasBorder: true,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: hasBorder
              ? Border.all(color: Colors.black12, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_note,
              color: contentColor,
              size: 32,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 16,
                        color: contentColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: contentColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
