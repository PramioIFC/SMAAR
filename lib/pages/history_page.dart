import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  // Altere para DetailsPage ou DayEventsPage conforme o arquivo
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página em Construção")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Voltar"),
        ),
      ),
    );
  }
}
