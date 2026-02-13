import 'package:flutter/material.dart';
import 'package:hayd_kalender/domain/models/fiqh_ruling.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:intl/intl.dart';

/// Widget to display the current fiqh status
class StatusCard extends StatelessWidget {
  final FiqhRuling? ruling;
  final DateTime? currentBleedingStart;

  const StatusCard({
    super.key,
    this.ruling,
    this.currentBleedingStart,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getStatusTitle() {
    if (ruling == null) return "Status: Tuhr";

    switch (ruling!.purityState) {
      case PurityState.tuhr:
        return "Status: Tuhr (Renhed)";
      case PurityState.inHayd:
        return "Status: Hayd (Menstruation)";
      case PurityState.inIstihada:
        return "Status: Istihada (Irregulær blødning)";
      case PurityState.inNifas:
        return "Status: Nifas";
    }
  }

  Color _getStatusColor() {
    if (ruling == null) return Colors.green;

    switch (ruling!.purityState) {
      case PurityState.tuhr:
        return Colors.green;
      case PurityState.inHayd:
        return Colors.red;
      case PurityState.inIstihada:
        return Colors.orange;
      case PurityState.inNifas:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    if (ruling == null) return Icons.check_circle;

    switch (ruling!.purityState) {
      case PurityState.tuhr:
        return Icons.check_circle;
      case PurityState.inHayd:
        return Icons.water_drop;
      case PurityState.inIstihada:
        return Icons.warning;
      case PurityState.inNifas:
        return Icons.water_drop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: _getStatusColor().withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusTitle(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Current bleeding info
            if (currentBleedingStart != null) ...[
              Text(
                "Blødning startede: ${_formatDate(currentBleedingStart!)}",
                style: const TextStyle(fontSize: 14),
              ),
              if (ruling?.durationHours != null) ...[
                const SizedBox(height: 4),
                Text(
                  "Varighed: ${ruling!.durationHours} timer (${(ruling!.durationHours! / 24).toStringAsFixed(1)} dage)",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Religious obligations
            Row(
              children: [
                Expanded(
                  child: _ObligationChip(
                    label: "Salah",
                    isProhibited: ruling?.salahProhibited ?? false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ObligationChip(
                    label: "Faste",
                    isProhibited: ruling?.fastingProhibited ?? false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Explanation
            if (ruling?.explanation != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ruling!.explanation,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small chip to show obligation status
class _ObligationChip extends StatelessWidget {
  final String label;
  final bool isProhibited;

  const _ObligationChip({
    required this.label,
    required this.isProhibited,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isProhibited
            ? Colors.red.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isProhibited ? Colors.red : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProhibited ? Icons.close : Icons.check,
            size: 16,
            color: isProhibited ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isProhibited ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}