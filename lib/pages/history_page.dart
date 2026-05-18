import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../widgets/widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recebe o gateId da porteira selecionada
    final gateId = ModalRoute.of(context)?.settings.arguments as int?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Histórico",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  HistoryCard.today(
                    subtitle: DateHelper.formatDate(DateTime.now()),
                    onTap: () => _navigateToDay(context, "Hoje", gateId),
                  ),
                  const SizedBox(height: 15),
                  HistoryCard.yesterday(
                    subtitle: DateHelper.formatDate(
                        DateTime.now().subtract(const Duration(days: 1))),
                    onTap: () => _navigateToDay(context, "Ontem", gateId),
                  ),
                  const SizedBox(height: 15),
                  ..._buildPastDays(context, gateId),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildCalendarButton(context, gateId),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPastDays(BuildContext context, int? gateId) {
    final widgets = <Widget>[];
    for (int i = 2; i <= 5; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final label = DateHelper.formatDate(date);
      widgets.add(
        HistoryCard.date(
          date: label,
          onTap: () => _navigateToDay(context, label, gateId),
        ),
      );
      if (i < 5) widgets.add(const SizedBox(height: 15));
    }
    return widgets;
  }

  void _navigateToDay(BuildContext context, String dateLabel, int? gateId) {
    Navigator.pushNamed(
      context,
      '/dayEvents',
      arguments: {'dateLabel': dateLabel, 'gateId': gateId},
    );
  }

  Widget _buildCalendarButton(BuildContext context, int? gateId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, '/calendar', arguments: gateId),
        child: Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1565C0), width: 2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_calendar, color: Color(0xFF1565C0), size: 30),
              SizedBox(width: 12),
              Text(
                "ESCOLHER OUTRA DATA",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
