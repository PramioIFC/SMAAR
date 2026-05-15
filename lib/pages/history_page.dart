import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fundo claro
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

            // Lista de Datas
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Card HOJE
                  _buildHistoryCard(
                    context,
                    title: "Hoje",
                    subtitle: "08 de Maio de 2026",
                    bgColor: const Color(0xFFE8F5E9), // Verde claro
                    contentColor: const Color(0xFF2E7D32), // Verde escuro
                    hasBorder: false,
                  ),
                  const SizedBox(height: 15),

                  // Card ONTEM
                  _buildHistoryCard(
                    context,
                    title: "Ontem",
                    subtitle: "07 de Maio de 2026",
                    bgColor: const Color(0xFFE3F2FD), // Azul claro
                    contentColor: const Color(0xFF1565C0), // Azul escuro
                    hasBorder: false,
                  ),
                  const SizedBox(height: 15),

                  // Cards Comuns
                  _buildHistoryCard(
                    context,
                    title: "06 de Maio de 2026",
                    bgColor: Colors.white,
                    contentColor: Colors.black87,
                    hasBorder: true,
                  ),
                  const SizedBox(height: 15),

                  _buildHistoryCard(
                    context,
                    title: "05 de Maio de 2026",
                    bgColor: Colors.white,
                    contentColor: Colors.black87,
                    hasBorder: true,
                  ),
                  const SizedBox(height: 15),

                  _buildHistoryCard(
                    context,
                    title: "04 de Maio de 2026",
                    bgColor: Colors.white,
                    contentColor: Colors.black87,
                    hasBorder: true,
                  ),
                  const SizedBox(height: 15),

                  _buildHistoryCard(
                    context,
                    title: "03 de Maio de 2026",
                    bgColor: Colors.white,
                    contentColor: Colors.black87,
                    hasBorder: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Botão inferior fixo
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/calendar');
                },
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_calendar,
                        color: Color(0xFF1565C0),
                        size: 30,
                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para gerar os cards padronizados
  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Color bgColor,
    required Color contentColor,
    required bool hasBorder,
  }) {
    return GestureDetector(
      // Ao clicar, envia o título (data) para a próxima página de eventos do dia
      onTap: () => Navigator.pushNamed(context, '/dayEvents', arguments: title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: hasBorder
              ? Border.all(color: Colors.black12, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_note, // Ícone de calendário
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
                  // Renderiza o subtítulo apenas se ele existir (Hoje/Ontem)
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
              Icons.arrow_forward_ios, // Setinha indicando navegação
              color: contentColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
