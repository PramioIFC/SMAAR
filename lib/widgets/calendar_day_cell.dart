import 'package:flutter/material.dart';

/// Célula do calendário reutilizável
class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final Color? dotColor;
  final double circleSize;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    this.isSelected = false,
    this.dotColor,
    this.circleSize = 44,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = (circleSize * 0.45).clamp(13.0, 20.0);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
