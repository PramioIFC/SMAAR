class Gate {
  final int? id;
  final String name;
  final String limitTimeStart;
  final String limitTimeEnd;
  final bool isClosed;

  const Gate({
    this.id,
    required this.name,
    required this.limitTimeStart,
    required this.limitTimeEnd,
    required this.isClosed,
  });

  String get limitTimeFormatted => '$limitTimeStart–$limitTimeEnd';

  /// Lê o JSON do endpoint `/api/porteiras/` (PorteiraSerializer Django)
  factory Gate.fromApiJson(Map<String, dynamic> json) {
    return Gate(
      id:             json['id'] as int?,
      name:           json['nome'] as String,
      limitTimeStart: (json['limite_abertura']   as String?) ?? '',
      limitTimeEnd:   (json['limite_fechamento'] as String?) ?? '',
      isClosed:       (json['status'] as String?) == 'fechado',
    );
  }

  /// Corpo para POST /api/porteiras/
  Map<String, dynamic> toCreateJson() => {
    'nome':               name,
    'status':             isClosed ? 'fechado' : 'aberto',
    'limite_abertura':    limitTimeStart,
    'limite_fechamento':  limitTimeEnd,
  };

  Gate copyWith({int? id, String? name, String? limitTimeStart,
      String? limitTimeEnd, bool? isClosed}) {
    return Gate(
      id:             id             ?? this.id,
      name:           name           ?? this.name,
      limitTimeStart: limitTimeStart ?? this.limitTimeStart,
      limitTimeEnd:   limitTimeEnd   ?? this.limitTimeEnd,
      isClosed:       isClosed       ?? this.isClosed,
    );
  }

  @override
  String toString() => 'Gate(id: $id, name: $name, isClosed: $isClosed)';
}
