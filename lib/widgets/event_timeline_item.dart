import 'package:flutter/material.dart';
import '../models/models.dart';

/// Item da timeline de eventos
class EventTimelineItem extends StatelessWidget {
  final DayEvent event;
  final bool isLast;

  const EventTimelineItem({
    super.key,
    required this.event,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EventColors.forType(event.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Coluna esquerda: ícone + linha conectora
          SizedBox(
            width: 62,
            child: Column(
              children: [
                // Ícone circular
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(event.icon, color: Colors.white, size: 26),
                ),
                // Linha conectora
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Coluna direita: card do evento
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horário
                    Text(
                      event.time,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.timeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Título
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.titleColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Subtítulo
                    Text(
                      event.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.subtitleColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
