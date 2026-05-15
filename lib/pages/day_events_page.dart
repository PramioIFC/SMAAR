import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/repositories/repositories.dart';
import '../widgets/widgets.dart';
import '../utils/date_utils.dart';

class DayEventsPage extends StatefulWidget {
  const DayEventsPage({super.key});

  @override
  State<DayEventsPage> createState() => _DayEventsPageState();
}

class _DayEventsPageState extends State<DayEventsPage> {
  final EventRepository _eventRepository = MockEventRepository();
  List<DayEvent> _events = [];
  bool _isLoading = true;
  late String _dateLabel;
  late String _dateKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dateLabel =
        ModalRoute.of(context)?.settings.arguments as String? ??
        "Data desconhecida";
    _dateKey = DateHelper.toDateKey(_dateLabel);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _eventRepository.getEventsForDateKey(_dateKey);
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _dateKey == DateHelper.todayKey;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isToday),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                  ? EmptyState.noEvents()
                  : _buildTimeline(),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isToday) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
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
                  isToday ? "Hoje" : DateHelper.shortLabel(_dateLabel),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateLabel,
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

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return EventTimelineItem(
          event: _events[index],
          isLast: index == _events.length - 1,
        );
      },
    );
  }

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
}
