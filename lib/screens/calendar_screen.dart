import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/calendar_event_model.dart';
import '../services/calendar_service.dart';
import '../utils/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _calendarService = CalendarService();
  bool _loading = true;
  String? _error;
  List<CalendarEventModel> _events = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _calendarService.getEvents();
      setState(() => _events = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  List<CalendarEventModel> _eventsForDay(DateTime day) {
    return _events.where((e) {
      final start = DateTime.parse(e.startDate);
      final end = DateTime.parse(e.endDate);
      final d = DateTime(day.year, day.month, day.day);
      return !d.isBefore(start) && d.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _selectedDay != null ? _eventsForDay(_selectedDay!) : <CalendarEventModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Tim', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary)))
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: TableCalendar<CalendarEventModel>(
                            firstDay: DateTime.utc(2024, 1, 1),
                            lastDay: DateTime.utc(2027, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            eventLoader: _eventsForDay,
                            calendarFormat: CalendarFormat.month,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            calendarStyle: const CalendarStyle(
                              todayDecoration: BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                              selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              markerDecoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                              markersMaxCount: 3,
                              outsideDaysVisible: false,
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Legend
                        Row(
                          children: [
                            _legendDot(AppColors.annualLeave, 'Annual'),
                            const SizedBox(width: 14),
                            _legendDot(AppColors.sickLeave, 'Sick'),
                            const SizedBox(width: 14),
                            _legendDot(AppColors.personalLeave, 'Personal'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Text(
                          _selectedDay != null ? 'Cuti pada ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}' : 'Pilih tanggal',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),

                        if (selectedEvents.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('Tidak ada cuti tim pada tanggal ini.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          )
                        else
                          ...selectedEvents.map((e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: _hexToColor(e.color), shape: BoxShape.circle)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        e.title,
                                        style: TextStyle(fontSize: 13, fontWeight: e.isMine ? FontWeight.bold : FontWeight.w500),
                                      ),
                                    ),
                                    Text(e.leaveType, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
