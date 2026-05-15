/// Utilitários para manipulação de datas
class DateHelper {
  DateHelper._();

  /// Nomes dos meses em português
  static const List<String> monthNames = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro",
  ];

  /// Mapa de meses para conversão
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

  /// Retorna a chave de hoje no formato "yyyy-MM-dd"
  static String get todayKey {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// Retorna a chave de ontem no formato "yyyy-MM-dd"
  static String get yesterdayKey {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
  }

  /// Converte label de data para chave no formato "yyyy-MM-dd"
  /// Aceita: "hoje", "ontem", "8 de Maio de 2026"
  static String toDateKey(String label) {
    try {
      final lower = label.toLowerCase().trim();

      if (lower == "hoje") return todayKey;
      if (lower == "ontem") return yesterdayKey;

      // Formato: "8 de Maio de 2026" ou "08 de Maio de 2026"
      final parts = lower.split(" de ");
      final day = parts[0].trim().padLeft(2, '0');
      final month = _monthMap[parts[1].trim()] ?? "01";
      final year = parts[2].trim();
      return "$year-$month-$day";
    } catch (_) {
      return "";
    }
  }

  /// Retorna label curto (dia e mês apenas)
  /// Ex: "8 de Maio de 2026" → "8 de Maio"
  static String shortLabel(String label) {
    try {
      final parts = label.split(" de ");
      return "${parts[0]} de ${parts[1]}";
    } catch (_) {
      return label;
    }
  }

  /// Formata uma data para exibição
  /// Ex: DateTime(2026, 5, 8) → "8 de Maio de 2026"
  static String formatDate(DateTime date) {
    return "${date.day} de ${monthNames[date.month - 1]} de ${date.year}";
  }

  /// Converte DateTime para chave no formato "yyyy-MM-dd"
  static String dateToKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Converte chave "yyyy-MM-dd" para DateTime
  static DateTime keyToDate(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
