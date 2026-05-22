import 'package:flutter/material.dart';

/// Status do log do dia
enum LogStatus { normal, warning, danger }

/// Modelo de Log do Calendário
/// Preparado para integração com PostgreSQL
class DayLog {
  final int? id;
  final int? gateId;
  final DateTime date;
  final LogStatus status;
  final String? description;

  const DayLog({
    this.id,
    this.gateId,
    required this.date,
    required this.status,
    this.description,
  });

  /// Chave da data no formato "yyyy-MM-dd"
  String get dateKey {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Cor do status
  Color get statusColor {
    switch (status) {
      case LogStatus.normal:
        return const Color(0xFF4CAF50);
      case LogStatus.warning:
        return Colors.orange;
      case LogStatus.danger:
        return const Color(0xFFD32F2F);
    }
  }

  /// Label do status
  String get statusLabel {
    switch (status) {
      case LogStatus.normal:
        return "Uso normal";
      case LogStatus.warning:
        return "Alerta / Atenção";
      case LogStatus.danger:
        return "Problema / Falha";
    }
  }

  /// Cria uma instância a partir de um Map (para PostgreSQL/JSON)
  factory DayLog.fromMap(Map<String, dynamic> map) {
    return DayLog(
      id: map['id'] as int?,
      gateId: map['gate_id'] as int?,
      date: DateTime.parse(map['date'] as String),
      status: LogStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LogStatus.normal,
      ),
      description: map['description'] as String?,
    );
  }

  /// Converte para Map (para inserção no PostgreSQL)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (gateId != null) 'gate_id': gateId,
      'date': date.toIso8601String().split('T').first,
      'status': status.name,
      'description': description,
    };
  }

  /// Cria uma cópia com valores alterados
  DayLog copyWith({
    int? id,
    int? gateId,
    DateTime? date,
    LogStatus? status,
    String? description,
  }) {
    return DayLog(
      id: id ?? this.id,
      gateId: gateId ?? this.gateId,
      date: date ?? this.date,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'DayLog(id: $id, date: $dateKey, status: $status)';
}
