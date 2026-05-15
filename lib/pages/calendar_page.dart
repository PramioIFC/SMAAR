import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/repositories/repositories.dart';
import '../widgets/widgets.dart';
import '../utils/date_utils.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final LogRepository _logRepository = MockLogRepository();

  late int _currentYear;
  late int _currentMonth;
  int? _selectedDay;
  Map<String, DayLog> _logsForMonth = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    _loadLogsForMonth();
  }

  Future<void> _loadLogsForMonth() async {
    final logs = await _logRepository.getLogsForMonth(
      _currentYear,
      _currentMonth,
    );
    setState(() {
      _logsForMonth = logs;
    });
  }

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
    _loadLogsForMonth();
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
    _loadLogsForMonth();
  }

  void _pickYear() {
    const int minYear = 2000;
    const int maxYear = 2040;
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i);
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
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Selecionar Ano",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: ListWheelScrollView.useDelegate(
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
                  ),
                  const SizedBox(height: 24),
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
                        _loadLogsForMonth();
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

  void _onDayTapped(int day) {
    setState(() => _selectedDay = day);

    final dateKey =
        "$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
    final log = _logsForMonth[dateKey];

    if (log == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Nenhum registro encontrado para $day de "
            "${DateHelper.monthNames[_currentMonth - 1]} de $_currentYear.",
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
      Navigator.pushNamed(
        context,
        '/dayEvents',
        arguments:
            "$day de ${DateHelper.monthNames[_currentMonth - 1]} de $_currentYear",
      );
    }
  }

  int get _daysInMonth => DateTime(_currentYear, _currentMonth + 1, 0).day;

  int get _startOffset {
    final firstDay = DateTime(_currentYear, _currentMonth, 1);
    return firstDay.weekday - 1;
  }

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
              const LegendContainer(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

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
                "${DateHelper.monthNames[_currentMonth - 1]} $_currentYear",
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

            final dateKey =
                "$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}";
            final log = _logsForMonth[dateKey];
            final isSelected = dayNumber == _selectedDay;

            return CalendarDayCell(
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
}
