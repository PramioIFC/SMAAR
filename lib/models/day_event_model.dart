import 'package:flutter/material.dart';

/// Tipos de evento para estilização
enum EventType { normal, info, warning, danger }

/// Modelo de Evento do Dia
/// Preparado para integração com PostgreSQL
class DayEvent {
  final int? id;
  final int? gateId;
  final DateTime date;
  final String time;
  final String title;
  final String subtitle;
  final String iconName;
  final EventType type;

  const DayEvent({
    this.id,
    this.gateId,
    required this.date,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.type,
  });

  /// Retorna o IconData baseado no nome do ícone
  IconData get icon {
    switch (iconName) {
      case 'lock_open':
        return Icons.lock_open_rounded;
      case 'lock':
        return Icons.lock_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'verified_user':
        return Icons.verified_user_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      case 'sensors_off':
        return Icons.sensors_off_rounded;
      case 'sensors':
        return Icons.sensors_rounded;
      case 'wifi_off':
        return Icons.wifi_off_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'build':
        return Icons.build_rounded;
      case 'person_add':
        return Icons.person_add_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  /// Cria uma instância a partir de um Map (para PostgreSQL/JSON)
  /// Lê um RegistroPorteira do backend:
  /// {"id", "porteira", "status": "aberto"|"fechado", "data": "yyyy-MM-dd", "hora": "HH:mm:ss"}
  factory DayEvent.fromRegistroJson(Map<String, dynamic> json) {
    final isClosed   = (json['status'] as String) == 'fechado';
    final horaStr    = (json['hora'] as String).substring(0, 5); // "HH:mm"
    return DayEvent(
      id:       json['id']       as int?,
      gateId:   json['porteira'] as int?,
      date:     DateTime.parse(json['data'] as String),
      time:     horaStr,
      title:    isClosed ? 'Porteira fechada' : 'Porteira aberta',
      subtitle: isClosed ? 'Fechamento registrado' : 'Abertura registrada',
      iconName: isClosed ? 'lock' : 'lock_open',
      type:     isClosed ? EventType.normal : EventType.danger,
    );
  }

  factory DayEvent.fromMap(Map<String, dynamic> map) {
    return DayEvent(
      id: map['id'] as int?,
      gateId: map['gate_id'] as int?,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      iconName: map['icon_name'] as String,
      type: EventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EventType.normal,
      ),
    );
  }

  /// Converte para Map (para inserção no PostgreSQL)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (gateId != null) 'gate_id': gateId,
      'date': date.toIso8601String().split('T').first,
      'time': time,
      'title': title,
      'subtitle': subtitle,
      'icon_name': iconName,
      'type': type.name,
    };
  }

  /// Cria uma cópia com valores alterados
  DayEvent copyWith({
    int? id,
    int? gateId,
    DateTime? date,
    String? time,
    String? title,
    String? subtitle,
    String? iconName,
    EventType? type,
  }) {
    return DayEvent(
      id: id ?? this.id,
      gateId: gateId ?? this.gateId,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'DayEvent(id: $id, date: $date, time: $time, title: $title)';
}

/// Cores para estilização dos eventos
class EventColors {
  final Color iconBg;
  final Color cardBg;
  final Color cardBorder;
  final Color timeColor;
  final Color titleColor;
  final Color subtitleColor;

  const EventColors({
    required this.iconBg,
    required this.cardBg,
    required this.cardBorder,
    required this.timeColor,
    required this.titleColor,
    required this.subtitleColor,
  });

  /// Retorna as cores baseadas no tipo de evento
  static EventColors forType(EventType type) {
    switch (type) {
      case EventType.normal:
        return const EventColors(
          iconBg: Color(0xFF1D9E75),
          cardBg: Color(0xFFF4FAF7),
          cardBorder: Color(0xFFB8E0CF),
          timeColor: Color(0xFF0F6E56),
          titleColor: Color(0xFF085041),
          subtitleColor: Color(0xFF3B6D50),
        );
      case EventType.info:
        return const EventColors(
          iconBg: Color(0xFF185FA5),
          cardBg: Color(0xFFF0F5FB),
          cardBorder: Color(0xFFB5D4F4),
          timeColor: Color(0xFF185FA5),
          titleColor: Color(0xFF0C447C),
          subtitleColor: Color(0xFF2A6FA8),
        );
      case EventType.warning:
        return const EventColors(
          iconBg: Color(0xFFBA7517),
          cardBg: Color(0xFFFEF8EE),
          cardBorder: Color(0xFFFAC775),
          timeColor: Color(0xFF854F0B),
          titleColor: Color(0xFF633806),
          subtitleColor: Color(0xFFBA7517),
        );
      case EventType.danger:
        return const EventColors(
          iconBg: Color(0xFFA32D2D),
          cardBg: Color(0xFFFDF3F3),
          cardBorder: Color(0xFFF7C1C1),
          timeColor: Color(0xFFA32D2D),
          titleColor: Color(0xFF791F1F),
          subtitleColor: Color(0xFFA32D2D),
        );
    }
  }
}
