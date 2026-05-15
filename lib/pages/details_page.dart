import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  // Altere para DetailsPage ou DayEventsPage conforme o arquivo
  const DetailsPage({super.key});

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
