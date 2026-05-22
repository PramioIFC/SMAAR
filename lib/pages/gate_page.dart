import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class GatePage extends StatelessWidget {
  const GatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final Gate gate;

    if (args is Gate) {
      gate = args;
    } else {
      gate = Gate(
        name: args as String? ?? "Porteira",
        limitTimeStart: "00:00",
        limitTimeEnd: "00:00",
        isClosed: true,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          gate.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildStatusSection(gate),
              const SizedBox(height: 15),
              _buildActivityCard(gate),
              const SizedBox(height: 15),
              _buildActionButtons(),
              const SizedBox(height: 15),
              _buildHistoryButton(context, gate),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(Gate gate) {
    final statusColor =
        gate.isClosed ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F);
    final statusText = gate.isClosed ? "FECHADA" : "ABERTA";

    return Column(
      children: [
        Text(
          "STATUS DA PORTEIRA",
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            gate.isClosed ? Icons.lock_outline : Icons.lock_open,
            color: Colors.white,
            size: 90,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Gate gate) {
    final hasActivity =
        gate.lastActivity != null || gate.lastActivityDescription != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Última atividade:",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          if (!hasActivity)
            const Text(
              "Nenhuma atividade registrada",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black),
                children: [
                  if (gate.lastActivity != null)
                    TextSpan(
                      text:
                          "${gate.lastActivity!.hour.toString().padLeft(2, '0')}:${gate.lastActivity!.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (gate.lastActivityDescription != null)
                    TextSpan(
                      text: gate.lastActivity != null
                          ? " - ${gate.lastActivityDescription}"
                          : gate.lastActivityDescription,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            label: "ABRIR",
            icon: Icons.unarchive_outlined,
            color: const Color(0xFF4CAF50),
            onTap: () {
              // TODO: Implementar abertura da porteira
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ActionButton(
            label: "FECHAR",
            icon: Icons.lock_person_outlined,
            color: const Color(0xFFD32F2F),
            onTap: () {
              // TODO: Implementar fechamento da porteira
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryButton(BuildContext context, Gate gate) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/history', arguments: gate.id),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black26, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Color(0xFF1976D2), size: 28),
            SizedBox(width: 10),
            Text(
              "HISTÓRICO",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
