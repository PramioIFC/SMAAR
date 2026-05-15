import 'package:flutter/material.dart';

// =============================================================================
// MODELO DE DADOS DO LOG
// =============================================================================

/// Representa um registro de log em um dia específico.
class DayLog {
  final String date; // formato: "yyyy-MM-dd"
  final Color statusColor;
  final String statusLabel;

  const DayLog({
    required this.date,
    required this.statusColor,
    required this.statusLabel,
  });
}

// =============================================================================
// BASE DE DADOS SIMULADA
// Logs registrados de 03/05/2026 a 09/05/2026
// =============================================================================

final List<DayLog> _allLogs = [
  DayLog(
    date: "2026-05-03",
    statusColor: const Color(0xFF4CAF50),
    statusLabel: "Uso normal",
  ),
  DayLog(
    date: "2026-05-04",
    statusColor: const Color(0xFF4CAF50),
    statusLabel: "Uso normal",
  ),
  DayLog(
    date: "2026-05-05",
    statusColor: Colors.orange,
    statusLabel: "Alerta / Atenção",
  ),
  DayLog(
    date: "2026-05-06",
    statusColor: const Color(0xFF4CAF50),
    statusLabel: "Uso normal",
  ),
  DayLog(
    date: "2026-05-07",
    statusColor: const Color(0xFFD32F2F),
    statusLabel: "Problema / Falha",
  ),
  DayLog(
    date: "2026-05-08",
    statusColor: Colors.orange,
    statusLabel: "Alerta / Atenção",
  ),
  DayLog(
    date: "2026-05-09",
    statusColor: const Color(0xFF4CAF50),
    statusLabel: "Uso normal",
  ),
];

/// Retorna o log de um dia específico ou null se não houver registro.
DayLog? _getLogForDay(int year, int month, int day) {
  final key =
      "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  try {
    return _allLogs.firstWhere((log) => log.date == key);
  } catch (_) {
    return null;
  }
}

// =============================================================================
// PÁGINA DO CALENDÁRIO
// =============================================================================

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Mês e ano atualmente exibidos
  late int _currentYear;
  late int _currentMonth;

  // Dia selecionado (pode ser null)
  int? _selectedDay;

  // Nomes dos meses em português
  static const List<String> _monthNames = [
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
  }

  // ── Navegação de mês ──────────────────────────────────────────────────────

  void _previousMonth() {
    setState(() {
      _selectedDay = null;
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDay = null;
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  // ── Selecionar ano via bottom sheet com scroll picker ────────────────────

  void _pickYear() {
    // Intervalo de anos disponíveis: 20 anos antes até 10 depois
    const int minYear = 2000;
    const int maxYear = 2040;
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i);

    // Controller centralizado no ano atual
    final initialIndex = years.indexOf(_currentYear).clamp(0, years.length - 1);
    final scrollController = FixedExtentScrollController(
      initialItem: initialIndex,
    );

    int tempYear = _currentYear;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pill handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    "Selecionar Ano",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Picker com faixa de seleção destacada
                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Faixas de fade superior e inferior
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 70,
                          child: IgnorePointer(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.white, Color(0x00FFFFFF)],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 70,
                          child: IgnorePointer(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.white, Color(0x00FFFFFF)],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Linha de seleção superior
                        Positioned(
                          top: 82,
                          left: 40,
                          right: 40,
                          child: Container(
                            height: 1.5,
                            color: const Color(0xFF4CAF50).withOpacity(0.4),
                          ),
                        ),
                        // Linha de seleção inferior
                        Positioned(
                          bottom: 82,
                          left: 40,
                          right: 40,
                          child: Container(
                            height: 1.5,
                            color: const Color(0xFF4CAF50).withOpacity(0.4),
                          ),
                        ),

                        // ListWheelScrollView (drum roll)
                        ListWheelScrollView.useDelegate(
                          controller: scrollController,
                          itemExtent: 56,
                          diameterRatio: 1.6,
                          perspective: 0.003,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) {
                            setSheetState(() => tempYear = years[i]);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: years.length,
                            builder: (_, i) {
                              final y = years[i];
                              final isCenter = y == tempYear;
                              return AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isCenter ? 32 : 22,
                                  fontWeight: isCenter
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  color: isCenter
                                      ? const Color(0xFF4CAF50)
                                      : Colors.black38,
                                ),
                                child: Center(child: Text(y.toString())),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão confirmar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentYear = tempYear;
                          _selectedDay = null;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Toque em um dia ───────────────────────────────────────────────────────

  void _onDayTapped(int day) {
    setState(() => _selectedDay = day);

    final log = _getLogForDay(_currentYear, _currentMonth, day);

    if (log == null) {
      // Sem registro: mostra SnackBar informativo
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Nenhum registro encontrado para $day de "
            "${_monthNames[_currentMonth - 1]} de $_currentYear.",
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Com registro: navega para /details passando a data formatada
      Navigator.pushNamed(
        context,
        '/dayEvents',
        arguments: "$day de ${_monthNames[_currentMonth - 1]} de $_currentYear",
      );
    }
  }

  // ── Cálculo do calendário ─────────────────────────────────────────────────

  /// Quantos dias tem o mês atual.
  int get _daysInMonth => DateTime(_currentYear, _currentMonth + 1, 0).day;

  /// Deslocamento inicial: weekday do dia 1 (seg=1 … dom=7) → offset 0-based (seg=0).
  int get _startOffset {
    final firstDay = DateTime(_currentYear, _currentMonth, 1);
    return firstDay.weekday - 1; // segunda = 0, domingo = 6
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildMonthNavigator(),
              const SizedBox(height: 10),
              _buildWeekdayHeaders(),
              const SizedBox(height: 6),
              Expanded(flex: 5, child: _buildCalendarGrid()),
              const SizedBox(height: 10),
              _buildLegend(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navegador de mês / tap no título para mudar o ano ────────────────────

  Widget _buildMonthNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: _previousMonth,
        ),
        GestureDetector(
          onTap: _pickYear,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${_monthNames[_currentMonth - 1]} $_currentYear",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  // ── Cabeçalho dos dias da semana ──────────────────────────────────────────

  Widget _buildWeekdayHeaders() {
    const days = ["SEG", "TER", "QUA", "QUI", "SEX", "SÁB", "DOM"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map(
            (d) => SizedBox(
              width: 40,
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Grade do calendário ───────────────────────────────────────────────────

  Widget _buildCalendarGrid() {
    final offset = _startOffset;
    final totalDays = _daysInMonth;
    final totalRows = ((offset + totalDays) / 7).ceil();
    final totalCells = totalRows * 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight = constraints.maxHeight / totalRows;
        final circleSize = (rowHeight * 0.58).clamp(30.0, 44.0);

        return GridView.builder(
          shrinkWrap: false,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            mainAxisExtent: rowHeight,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNumber = index - offset + 1;

            if (index < offset || dayNumber > totalDays) {
              return const SizedBox.shrink();
            }

            final log = _getLogForDay(_currentYear, _currentMonth, dayNumber);
            final isSelected = dayNumber == _selectedDay;

            return _buildDayCell(
              day: dayNumber,
              isSelected: isSelected,
              dotColor: log?.statusColor,
              circleSize: circleSize,
              onTap: () => _onDayTapped(dayNumber),
            );
          },
        );
      },
    );
  }

  // ── Célula de dia ─────────────────────────────────────────────────────────

  Widget _buildDayCell({
    required int day,
    required bool isSelected,
    Color? dotColor,
    required double circleSize,
    required VoidCallback onTap,
  }) {
    final fontSize = (circleSize * 0.45).clamp(13.0, 20.0);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // ── Legenda ───────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(const Color(0xFF4CAF50), "Normal"),
          _buildLegendItem(Colors.orange, "Alerta"),
          _buildLegendItem(const Color(0xFFD32F2F), "Falha"),
          _buildLegendItem(Colors.grey.shade300, "Vazio"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
