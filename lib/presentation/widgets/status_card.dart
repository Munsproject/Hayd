import 'package:flutter/material.dart';
import 'package:hayd_kalender/domain/models/fiqh_ruling.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';
import 'package:intl/intl.dart';

/// Widget to display the current fiqh status and rulings grid
class StatusCard extends StatelessWidget {
  final FiqhRuling? ruling;
  final DateTime? currentBleedingStart;
  final int? normHaydDays;

  const StatusCard({
    super.key,
    this.ruling,
    this.currentBleedingStart,
    this.normHaydDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusBanner(
          ruling: ruling,
          bleedingStart: currentBleedingStart,
          normHaydDays: normHaydDays,
        ),
        const SizedBox(height: 12),
        _RulingsGrid(ruling: ruling),
      ],
    );
  }
}

// ── Status Banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final FiqhRuling? ruling;
  final DateTime? bleedingStart;
  final int? normHaydDays;

  const _StatusBanner({this.ruling, this.bleedingStart, this.normHaydDays});

  Color get _bgColor {
    if (ruling == null) return AppTheme.mint;
    switch (ruling!.purityState) {
      case PurityState.inHayd:     return AppTheme.rose;
      case PurityState.inIstihada: return AppTheme.gold;
      case PurityState.inNifas:    return AppTheme.rose;
      default:                     return AppTheme.mint;
    }
  }

  String get _title {
    if (ruling == null) return 'Tuhr · Renhed';
    switch (ruling!.purityState) {
      case PurityState.inHayd:     return 'Hayd · Menstruation';
      case PurityState.inIstihada: return 'Istihada';
      case PurityState.inNifas:    return 'Nifas';
      default:                     return 'Tuhr · Renhed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = ruling?.durationHours ?? 0;
    final days = hours ~/ 24;
    final remHours = hours % 24;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bgColor, _bgColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _bgColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hours > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Dag ${days + 1}  ($days d $remHours t)  ·  Norm: ${normHaydDays ?? "?"} dage',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          if (ruling?.explanation != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ruling!.explanation,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Rulings Grid ──────────────────────────────────────────────────────────────

class _RulingsGrid extends StatelessWidget {
  final FiqhRuling? ruling;

  const _RulingsGrid({this.ruling});

  bool get _inHayd =>
      ruling?.purityState == PurityState.inHayd ||
      ruling?.purityState == PurityState.inNifas;

  bool get _inIstihada => ruling?.purityState == PurityState.inIstihada;

  bool get _inTuhr => !_inHayd && !_inIstihada;

  @override
  Widget build(BuildContext context) {
    final items = [
      _RulingItem(
        icon: Icons.mosque_outlined,
        label: 'Salah',
        allowed: !(ruling?.salahProhibited ?? false),
        subLabel: _inHayd ? 'skyldes ikke' : 'skyldes',
      ),
      _RulingItem(
        icon: Icons.no_food_outlined,
        label: 'Faste',
        allowed: !(ruling?.fastingProhibited ?? false),
        subLabel: _inHayd ? 'skyldes' : 'skyldes ikke',
      ),
      _RulingItem(
        icon: Icons.menu_book_outlined,
        label: 'Koranlæsn.',
        allowed: !(ruling?.quranRecitationProhibited ?? false),
        subLabel: _inHayd ? 'forbudt' : 'tilladt',
      ),
      _RulingItem(
        icon: Icons.auto_stories_outlined,
        label: "Duʿā-rec.",
        allowed: ruling?.duaRecitationAllowed ?? true,
        subLabel: 'tilladt',
      ),
      _RulingItem(
        icon: Icons.touch_app_outlined,
        label: 'Berøring',
        allowed: _inTuhr || _inIstihada,
        subLabel: _inHayd ? 'forbudt' : 'tilladt',
      ),
      _RulingItem(
        icon: Icons.favorite_outline,
        label: 'Intimitet',
        allowed: !(ruling?.intimacyForbiddenUntilNorm ?? false),
        subLabel: _inHayd ? 'forbudt' : 'tilladt',
      ),
      _RulingItem(
        icon: Icons.rotate_right_outlined,
        label: 'Tawaf',
        allowed: _inTuhr || _inIstihada,
        subLabel: _inHayd ? 'forbudt' : 'tilladt',
      ),
      _RulingItem(
        icon: Icons.nights_stay_outlined,
        label: 'Bedeområde',
        allowed: _inTuhr,
        subLabel: _inHayd || _inIstihada ? 'forbudt' : 'tilladt',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.plum.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: items.map((item) => item.build()).toList(),
      ),
    );
  }
}

// ── Single Ruling Badge ───────────────────────────────────────────────────────

class _RulingItem {
  final IconData icon;
  final String label;
  final bool allowed;
  final String subLabel;

  const _RulingItem({
    required this.icon,
    required this.label,
    required this.allowed,
    required this.subLabel,
  });

  Widget build() {
    final color = allowed ? AppTheme.mint : AppTheme.rose;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, size: 26, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    allowed ? Icons.check : Icons.close,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkPlum,
          ),
        ),
        Text(
          subLabel,
          style: const TextStyle(
            fontSize: 9,
            color: AppTheme.warmGray,
          ),
        ),
      ],
    );
  }
}
