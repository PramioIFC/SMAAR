/// Modelo de Porteira
/// Preparado para integração com PostgreSQL
class Gate {
  final int? id;
  final String name;
  final String limitTimeStart;
  final String limitTimeEnd;
  final bool isClosed;
  final DateTime? lastActivity;
  final String? lastActivityDescription;

  const Gate({
    this.id,
    required this.name,
    required this.limitTimeStart,
    required this.limitTimeEnd,
    required this.isClosed,
    this.lastActivity,
    this.lastActivityDescription,
  });

  /// Formato de exibição do horário limite
  String get limitTimeFormatted => "$limitTimeStart-$limitTimeEnd";

  /// Cria uma instância a partir de um Map (para PostgreSQL/JSON)
  factory Gate.fromMap(Map<String, dynamic> map) {
    return Gate(
      id: map['id'] as int?,
      name: map['name'] as String,
      limitTimeStart: map['limit_time_start'] as String,
      limitTimeEnd: map['limit_time_end'] as String,
      isClosed: map['is_closed'] as bool,
      lastActivity: map['last_activity'] != null
          ? DateTime.parse(map['last_activity'] as String)
          : null,
      lastActivityDescription: map['last_activity_description'] as String?,
    );
  }

  /// Converte para Map (para inserção no PostgreSQL)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'limit_time_start': limitTimeStart,
      'limit_time_end': limitTimeEnd,
      'is_closed': isClosed,
      'last_activity': lastActivity?.toIso8601String(),
      'last_activity_description': lastActivityDescription,
    };
  }

  /// Cria uma cópia com valores alterados
  Gate copyWith({
    int? id,
    String? name,
    String? limitTimeStart,
    String? limitTimeEnd,
    bool? isClosed,
    DateTime? lastActivity,
    String? lastActivityDescription,
  }) {
    return Gate(
      id: id ?? this.id,
      name: name ?? this.name,
      limitTimeStart: limitTimeStart ?? this.limitTimeStart,
      limitTimeEnd: limitTimeEnd ?? this.limitTimeEnd,
      isClosed: isClosed ?? this.isClosed,
      lastActivity: lastActivity ?? this.lastActivity,
      lastActivityDescription:
          lastActivityDescription ?? this.lastActivityDescription,
    );
  }

  @override
  String toString() => 'Gate(id: $id, name: $name, isClosed: $isClosed)';
}
