import 'package:flutter/material.dart';
import 'package:hayd_kalender/domain/models/cycle.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';
import 'package:intl/intl.dart';

class CycleTimeline extends StatelessWidget {
  final List<Cycle> cycles;

  const CycleTimeline({
    super.key,
    required this.cycles,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (cycles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Ingen cyklusser endnu.\nStart med at registrere blødning.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppTheme.warmGray),
          ),
        ),
      );
    }

    final reversedCycles = cycles.reversed.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedCycles.length,
      itemBuilder: (context, index) {
        final cycle = reversedCycles[index];
        return _CycleTimelineItem(cycle: cycle);
      },
    );
  }
}

class _CycleTimelineItem extends StatelessWidget {
  final Cycle cycle;

  const _CycleTimelineItem({required this.cycle});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color get _bleedingColor =>
      cycle.isValidHayd ? AppTheme.rose : AppTheme.gold;

  IconData get _bleedingIcon =>
      cycle.isValidHayd ? Icons.water_drop : Icons.warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _bleedingColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.plum.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bleeding header
          Row(
            children: [
              Icon(_bleedingIcon, color: _bleedingColor, size: 18),
              const SizedBox(width: 8),
              Text(
                cycle.isValidHayd ? 'Hayd' : 'Istihada',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _bleedingColor,
                ),
              ),
              const Spacer(),
              Text(
                '${(cycle.bleedingDurationHours / 24).toStringAsFixed(1)} dage',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkPlum,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppTheme.warmGray),
              const SizedBox(width: 5),
              Text(
                '${_formatDate(cycle.bleedingStart)} — '
                '${cycle.bleedingEnd != null ? _formatDate(cycle.bleedingEnd!) : "Aktiv"}',
                style: const TextStyle(fontSize: 12, color: AppTheme.warmGray),
              ),
            ],
          ),

          // Tuhr period
          if (cycle.tuhrDurationHours != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.mint, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Tuhr (Renhed)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mint,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(cycle.tuhrDurationHours! / 24).toStringAsFixed(1)} dage',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkPlum,
                  ),
                ),
              ],
            ),
          ],

          // Total cycle
          if (cycle.isComplete) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.rosePale,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.repeat, size: 14, color: AppTheme.plumLight),
                  const SizedBox(width: 6),
                  Text(
                    'Total cyklus: ${cycle.totalCycleLengthDays!.toStringAsFixed(1)} dage',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.plum,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
