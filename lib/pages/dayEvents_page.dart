import 'package:flutter/material.dart';

// =============================================================================
// MODELO DE EVENTO
// =============================================================================

class DayEvent {
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final EventType type;

  const DayEvent({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });
}

enum EventType { normal, info, warning, danger }

// =============================================================================
// BASE DE DADOS DE EVENTOS POR DIA
// Chave: "yyyy-MM-dd"
// =============================================================================

final Map<String, List<DayEvent>> _eventsByDay = {
  "2026-05-03": [
    DayEvent(
      time: "06:30",
      title: "Porteira aberta",
      subtitle: "Aberta remotamente",
      icon: Icons.lock_open_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "06:31",
      title: "Maria autorizou acesso",
      subtitle: "Acesso liberado manualmente",
      icon: Icons.person_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "19:00",
      title: "Fechamento automático",
      subtitle: "Porteira fechada pelo sistema",
      icon: Icons.lock_rounded,
      type: EventType.normal,
    ),
  ],
  "2026-05-04": [
    DayEvent(
      time: "07:00",
      title: "Porteira aberta",
      subtitle: "Abertura programada",
      icon: Icons.lock_open_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "08:10",
      title: "Carro entrou",
      subtitle: "Veículo detectado na entrada",
      icon: Icons.directions_car_rounded,
      type: EventType.info,
    ),
    DayEvent(
      time: "18:30",
      title: "Fechamento automático",
      subtitle: "Porteira fechada pelo sistema",
      icon: Icons.lock_rounded,
      type: EventType.normal,
    ),
  ],
  "2026-05-05": [
    DayEvent(
      time: "07:14",
      title: "Porteira aberta",
      subtitle: "Aberta remotamente",
      icon: Icons.lock_open_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "11:45",
      title: "Falha no sensor",
      subtitle: "Sensor de presença sem resposta",
      icon: Icons.sensors_off_rounded,
      type: EventType.warning,
    ),
    DayEvent(
      time: "11:52",
      title: "Sensor normalizado",
      subtitle: "Sensor voltou a responder",
      icon: Icons.sensors_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "18:44",
      title: "Fechamento automático",
      subtitle: "Porteira fechada pelo sistema",
      icon: Icons.lock_rounded,
      type: EventType.normal,
    ),
  ],
  "2026-05-06": [
    DayEvent(
      time: "07:00",
      title: "Porteira aberta",
      subtitle: "Abertura programada",
      icon: Icons.lock_open_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "10:20",
      title: "Caminhão entrou",
      subtitle: "Veículo de carga detectado",
      icon: Icons.local_shipping_rounded,
      type: EventType.info,
    ),
    DayEvent(
      time: "18:30",
      title: "Fechamento automático",
      subtitle: "Porteira fechada pelo sistema",
      icon: Icons.lock_rounded,
      type: EventType.normal,
    ),
  ],
  "2026-05-07": [
    DayEvent(
      time: "07:00",
      title: "Porteira aberta",
      subtitle: "Abertura programada",
      icon: Icons.lock_open_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "14:30",
      title: "Porteira com defeito",
      subtitle: "Motor sem resposta",
      icon: Icons.warning_rounded,
      type: EventType.danger,
    ),
    DayEvent(
      time: "15:10",
      title: "Técnico acionado",
      subtitle: "Manutenção solicitada",
      icon: Icons.build_rounded,
      type: EventType.warning,
    ),
  ],
  "2026-05-08": [
    DayEvent(
      time: "07:14",
      title: "Porteira aberta",
      subtitle: "Aberta remotamente",
      icon: Icons.lock_open_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "07:15",
      title: "João autorizou acesso",
      subtitle: "Acesso liberado manualmente",
      icon: Icons.verified_user_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "09:52",
      title: "Caminhão entrou",
      subtitle: "Veículo detectado na entrada",
      icon: Icons.local_shipping_rounded,
      type: EventType.info,
    ),
    DayEvent(
      time: "12:03",
      title: "Porteira Sul offline",
      subtitle: "Sem sinal de conexão",
      icon: Icons.wifi_off_rounded,
      type: EventType.warning,
    ),
    DayEvent(
      time: "12:10",
      title: "Reconectada",
      subtitle: "Conexão restabelecida",
      icon: Icons.wifi_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "18:44",
      title: "Fechamento automático",
      subtitle: "Porteira fechada pelo sistema",
      icon: Icons.lock_rounded,
      type: EventType.normal,
    ),
  ],
  "2026-05-09": [
    DayEvent(
      time: "07:00",
      title: "Porteira aberta",
      subtitle: "Abertura programada",
      icon: Icons.lock_open_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "09:15",
      title: "Visita autorizada",
      subtitle: "Acesso liberado pelo morador",
      icon: Icons.person_add_rounded,
      type: EventType.normal,
    ),
    DayEvent(
      time: "18:30",
      title: "Fechamento automático",
      subtitle: "Porteira fechada pelo sistema",
      icon: Icons.lock_rounded,
      type: EventType.normal,
    ),
  ],
};

List<DayEvent> _getEventsForDate(String dateKey) {
  return _eventsByDay[dateKey] ?? [];
}

// =============================================================================
// PÁGINA DE EVENTOS DO DIA
// Recebe como argumento a data formatada: "8 de Maio de 2026"
// =============================================================================

class DayEventsPage extends StatelessWidget {
  const DayEventsPage({super.key});

  // Converte "8 de Maio de 2026" → "2026-05-08" para buscar os eventos
  static const Map<String, String> _monthMap = {
    "janeiro": "01",
    "fevereiro": "02",
    "março": "03",
    "abril": "04",
    "maio": "05",
    "junho": "06",
    "julho": "07",
    "agosto": "08",
    "setembro": "09",
    "outubro": "10",
    "novembro": "11",
    "dezembro": "12",
  };

  String _toDateKey(String label) {
    try {
      final lower = label.toLowerCase().trim();

      // Trata "hoje" e "ontem" dinamicamente
      final now = DateTime.now();
      if (lower == "hoje") {
        return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      }
      if (lower == "ontem") {
        final yesterday = now.subtract(const Duration(days: 1));
        return "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
      }

      // Formato padrão: "8 de Maio de 2026" ou "08 de Maio de 2026"
      final parts = lower.split(" de ");
      final day = parts[0].trim().padLeft(2, '0');
      final month = _monthMap[parts[1].trim()] ?? "01";
      final year = parts[2].trim();
      return "$year-$month-$day";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Argumento passado pelo Navigator: ex. "8 de Maio de 2026"
    final String dateLabel =
        ModalRoute.of(context)?.settings.arguments as String? ??
        "Data desconhecida";

    final String dateKey = _toDateKey(dateLabel);
    final List<DayEvent> events = _getEventsForDate(dateKey);

    // Verifica se é hoje
    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final bool isToday = dateKey == todayKey;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isToday, dateLabel),
            Expanded(
              child: events.isEmpty
                  ? _buildEmpty(context)
                  : _buildTimeline(context, events),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  // ── Cabeçalho ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isToday, String dateLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          // Botão voltar
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 26,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? "Hoje" : _shortLabel(dateLabel),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Usa só o dia e mês como título curto se não for hoje
  String _shortLabel(String label) {
    try {
      final parts = label.split(" de ");
      return "${parts[0]} de ${parts[1]}";
    } catch (_) {
      return label;
    }
  }

  // ── Timeline ──────────────────────────────────────────────────────────────

  Widget _buildTimeline(BuildContext context, List<DayEvent> events) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;
        return _buildEventRow(event, isLast);
      },
    );
  }

  Widget _buildEventRow(DayEvent event, bool isLast) {
    final colors = _colorsForType(event.type);

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
                // Linha conectora (não aparece no último item)
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

  // ── Estado vazio ──────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
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
              Icons.calendar_today_rounded,
              size: 38,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Nenhum evento",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Não há registros para este dia.",
            style: TextStyle(fontSize: 16, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  // ── Botão inferior ────────────────────────────────────────────────────────

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/calendar'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: Colors.white,
          ),
          icon: const Icon(
            Icons.calendar_month_rounded,
            color: Color(0xFF185FA5),
            size: 24,
          ),
          label: const Text(
            "Ver outro dia",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF185FA5),
            ),
          ),
        ),
      ),
    );
  }

  // ── Paleta de cores por tipo de evento ────────────────────────────────────

  _EventColors _colorsForType(EventType type) {
    switch (type) {
      case EventType.normal:
        return _EventColors(
          iconBg: const Color(0xFF1D9E75),
          cardBg: const Color(0xFFF4FAF7),
          cardBorder: const Color(0xFFB8E0CF),
          timeColor: const Color(0xFF0F6E56),
          titleColor: const Color(0xFF085041),
          subtitleColor: const Color(0xFF3B6D50),
        );
      case EventType.info:
        return _EventColors(
          iconBg: const Color(0xFF185FA5),
          cardBg: const Color(0xFFF0F5FB),
          cardBorder: const Color(0xFFB5D4F4),
          timeColor: const Color(0xFF185FA5),
          titleColor: const Color(0xFF0C447C),
          subtitleColor: const Color(0xFF2A6FA8),
        );
      case EventType.warning:
        return _EventColors(
          iconBg: const Color(0xFFBA7517),
          cardBg: const Color(0xFFFEF8EE),
          cardBorder: const Color(0xFFFAC775),
          timeColor: const Color(0xFF854F0B),
          titleColor: const Color(0xFF633806),
          subtitleColor: const Color(0xFFBA7517),
        );
      case EventType.danger:
        return _EventColors(
          iconBg: const Color(0xFFA32D2D),
          cardBg: const Color(0xFFFDF3F3),
          cardBorder: const Color(0xFFF7C1C1),
          timeColor: const Color(0xFFA32D2D),
          titleColor: const Color(0xFF791F1F),
          subtitleColor: const Color(0xFFA32D2D),
        );
    }
  }
}

// ── Auxiliar de cores ──────────────────────────────────────────────────────

class _EventColors {
  final Color iconBg;
  final Color cardBg;
  final Color cardBorder;
  final Color timeColor;
  final Color titleColor;
  final Color subtitleColor;

  const _EventColors({
    required this.iconBg,
    required this.cardBg,
    required this.cardBorder,
    required this.timeColor,
    required this.titleColor,
    required this.subtitleColor,
  });
}
