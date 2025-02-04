import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/marker.dart';
import '../providers/marker_provider.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedMonth = DateTime.now();
  String? _selectedMarkerId;

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    final daysInMonth = <DateTime>[];
    
    // Add days from previous month to start on the correct weekday
    final firstWeekday = firstDay.weekday;
    if (firstWeekday > 1) {
      final daysToAdd = firstWeekday - 1;
      final lastDayPrevMonth = firstDay.subtract(const Duration(days: 1));
      for (var i = daysToAdd - 1; i >= 0; i--) {
        daysInMonth.add(lastDayPrevMonth.subtract(Duration(days: i)));
      }
    }
    
    // Add all days in the current month
    for (var i = 1; i <= lastDay.day; i++) {
      daysInMonth.add(DateTime(_selectedMonth.year, _selectedMonth.month, i));
    }
    
    // Add days from next month to complete the last week
    final remainingDays = 7 - (daysInMonth.length % 7);
    if (remainingDays < 7) {
      final firstDayNextMonth = lastDay.add(const Duration(days: 1));
      for (var i = 0; i < remainingDays; i++) {
        daysInMonth.add(firstDayNextMonth.add(Duration(days: i)));
      }
    }
    
    return daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                Consumer<MarkerProvider>(
                  builder: (context, provider, child) {
                    final markers = provider.markers;
                    return DropdownButton<String>(
                      value: _selectedMarkerId,
                      hint: const Text('Select Marker'),
                      items: markers.map((marker) {
                        return DropdownMenuItem(
                          value: marker.id,
                          child: Text(marker.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedMarkerId = value);
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: Text('Mon', textAlign: TextAlign.center)),
                Expanded(child: Text('Tue', textAlign: TextAlign.center)),
                Expanded(child: Text('Wed', textAlign: TextAlign.center)),
                Expanded(child: Text('Thu', textAlign: TextAlign.center)),
                Expanded(child: Text('Fri', textAlign: TextAlign.center)),
                Expanded(child: Text('Sat', textAlign: TextAlign.center)),
                Expanded(child: Text('Sun', textAlign: TextAlign.center)),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<MarkerProvider>(
              builder: (context, provider, child) {
                final days = _getDaysInMonth();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isCurrentMonth = day.month == _selectedMonth.month;
                    
                    String? value;
                    if (_selectedMarkerId != null && isCurrentMonth) {
                      final values = provider.getValuesForDate(
                        _selectedMarkerId!,
                        day,
                      );
                      if (values.isNotEmpty) {
                        value = values.first.value;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isCurrentMonth
                            ? Colors.white
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: isCurrentMonth
                                  ? Colors.black87
                                  : Colors.black38,
                            ),
                          ),
                          if (value != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              value,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
