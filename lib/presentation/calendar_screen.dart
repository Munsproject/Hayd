import 'package:flutter/material.dart';
import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/domain/repositories/episode_repository.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final AppDatabase _db;
  late final EpisodeRepository _repo;
  DateTime _viewDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _repo = EpisodeRepository(_db);
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  /// Build a map of 'yyyy-MM-dd' -> type ('hayd' | 'istihada' | 'tuhr' | 'pending')
  Map<String, String> _buildDayMap(List<Episode> episodes) {
    final map = <String, String>{};
    final sorted = [...episodes]..sort((a, b) => a.start.compareTo(b.start));

    for (int i = 0; i < sorted.length; i++) {
      final ep = sorted[i];
      final prev = i > 0 ? sorted[i - 1] : null;
      final end = ep.end ?? DateTime.now();
      final hours = end.difference(ep.start).inHours;
      final tuhrHours = prev?.end != null
          ? ep.start.difference(prev!.end!).inHours
          : 9999;

      final String type;
      if (ep.end == null && hours < 72) {
        type = 'pending';
      } else if (hours < 72 || hours > 240 || tuhrHours < 360) {
        type = 'istihada';
      } else {
        type = 'hayd';
      }

      // Mark bleeding days
      var cursor = _dayOnly(ep.start);
      final endDay = _dayOnly(end);
      while (!cursor.isAfter(endDay)) {
        map[_key(cursor)] = type;
        cursor = cursor.add(const Duration(days: 1));
      }

      // Mark tuhr days after episode
      if (ep.end != null) {
        final next = i < sorted.length - 1 ? sorted[i + 1] : null;
        var t = _dayOnly(ep.end!).add(const Duration(days: 1));
        final stop = next != null ? _dayOnly(next.start) : _dayOnly(DateTime.now());
        while (!t.isAfter(stop)) {
          if (!map.containsKey(_key(t))) map[_key(t)] = 'tuhr';
          t = t.add(const Duration(days: 1));
        }
      }
    }
    return map;
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Color _dayColor(String? type) {
    switch (type) {
      case 'hayd':     return AppTheme.rose;
      case 'istihada': return AppTheme.gold;
      case 'tuhr':     return AppTheme.mint;
      case 'pending':  return AppTheme.lavender;
      default:         return AppTheme.rosePale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        title: const Text('Kalender'),
      ),
      body: StreamBuilder<List<Episode>>(
        stream: _repo.watchEpisodes(),
        builder: (context, snapshot) {
          final episodes = snapshot.data ?? [];
          final dayMap = _buildDayMap(episodes);
          final year = _viewDate.year;
          final month = _viewDate.month;
          final firstWeekday = DateTime(year, month, 1).weekday; // 1 = Monday
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final today = _key(DateTime.now());
          final monthNames = [
            'Januar','Februar','Marts','April','Maj','Juni',
            'Juli','August','September','Oktober','November','December',
          ];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Month navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(() =>
                          _viewDate = DateTime(year, month - 1, 1)),
                    ),
                    Text(
                      '${monthNames[month - 1]} $year',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkPlum,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(() =>
                          _viewDate = DateTime(year, month + 1, 1)),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Weekday headers
                Row(
                  children: ['Ma','Ti','On','To','Fr','Lø','Sø']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.plumLight,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 6),

                // Calendar grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: (firstWeekday - 1) + daysInMonth,
                    itemBuilder: (ctx, idx) {
                      if (idx < firstWeekday - 1) return const SizedBox();
                      final day = idx - (firstWeekday - 1) + 1;
                      final date = DateTime(year, month, day);
                      final k = _key(date);
                      final type = dayMap[k];
                      final isToday = k == today;

                      return Container(
                        decoration: BoxDecoration(
                          color: _dayColor(type),
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(color: AppTheme.darkPlum, width: 2)
                              : null,
                          boxShadow: type != null
                              ? [BoxShadow(
                                  color: _dayColor(type).withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                              color: type != null ? Colors.white : AppTheme.warmGray,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: const [
                    _LegendDot(color: AppTheme.rose,     label: 'Hayd'),
                    _LegendDot(color: AppTheme.gold,     label: 'Istihada'),
                    _LegendDot(color: AppTheme.mint,     label: 'Tuhr'),
                    _LegendDot(color: AppTheme.lavender, label: 'Afventer'),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmGray,
          ),
        ),
      ],
    );
  }
}
