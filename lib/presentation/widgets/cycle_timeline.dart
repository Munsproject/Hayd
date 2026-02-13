import 'package:flutter/material.dart';
import 'package:hayd_kalender/domain/models/cycle.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:intl/intl.dart';

/// Widget to display cycles in a timeline format
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
            "Ingen cyklusser endnu.\nStart med at registrere blødning.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Show cycles in reverse order (newest first)
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

/// Individual cycle item in the timeline
class _CycleTimelineItem extends StatelessWidget {
  final Cycle cycle;

  const _CycleTimelineItem({required this.cycle});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getBleedingColor() {
    return cycle.isValidHayd ? Colors.red : Colors.orange;
  }

  IconData _getBleedingIcon() {
    return cycle.isValidHayd ? Icons.water_drop : Icons.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bleeding period header
            Row(
              children: [
                Icon(
                  _getBleedingIcon(),
                  color: _getBleedingColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  cycle.isValidHayd ? "Hayd" : "Istihada",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getBleedingColor(),
                  ),
                ),
                const Spacer(),
                Text(
                  "${(cycle.bleedingDurationHours / 24).toStringAsFixed(1)} dage",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Bleeding dates
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "${_formatDate(cycle.bleedingStart)} - ${cycle.bleedingEnd != null ? _formatDate(cycle.bleedingEnd!) : 'Aktiv'}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            // Tuhr period (if exists)
            if (cycle.tuhrDurationHours != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Tuhr (Renhed)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${(cycle.tuhrDurationHours! / 24).toStringAsFixed(1)} dage",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            // Total cycle info (if complete)
            if (cycle.isComplete) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.repeat, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Total cyklus: ${cycle.totalCycleLengthDays!.toStringAsFixed(1)} dage",
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}