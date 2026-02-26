import 'package:flutter/material.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/domain/models/fiqh_ruling.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';

class DebugTestScreen extends StatefulWidget {
  const DebugTestScreen({super.key});

  @override
  State<DebugTestScreen> createState() => _DebugTestScreenState();
}

class _DebugTestScreenState extends State<DebugTestScreen> {
  double _bleedingHours = 40;
  bool _isActiveEpisode = true;
  bool _hasPreviousHayd = false;
  double _tuhrHours = 400;

  static final _anchor = DateTime(2024, 1, 1);

  FiqhCalculatorService _serviceAt(DateTime fakeNow) =>
      FiqhCalculatorService(clock: () => fakeNow);

  FiqhRuling _buildInteractiveRuling() {
    final hours = _bleedingHours.round();
    final start = _anchor;
    final fakeNow = _anchor.add(Duration(hours: hours));
    final s = _serviceAt(fakeNow);
    final prevEnd = _hasPreviousHayd
        ? start.subtract(Duration(hours: _tuhrHours.round()))
        : null;

    if (_isActiveEpisode) {
      return s.calculateCurrentRuling(
        bleedingStart: start,
        previousHaydEnd: prevEnd,
      );
    } else {
      return s.calculateCompletedEpisodeRuling(
        bleedingStart: start,
        bleedingEnd: fakeNow,
        previousHaydEnd: prevEnd,
      );
    }
  }

  List<_ScenarioData> _buildScenarios() {
    final anchor = _anchor;

    FiqhRuling currentAt(int hours, {int? tuhrHours}) {
      final fakeNow = anchor.add(Duration(hours: hours));
      final s = _serviceAt(fakeNow);
      final prevEnd =
          tuhrHours != null ? anchor.subtract(Duration(hours: tuhrHours)) : null;
      return s.calculateCurrentRuling(
          bleedingStart: anchor, previousHaydEnd: prevEnd);
    }

    FiqhRuling completedAt(int hours, {int? tuhrHours}) {
      final end = anchor.add(Duration(hours: hours));
      final s = _serviceAt(end);
      final prevEnd =
          tuhrHours != null ? anchor.subtract(Duration(hours: tuhrHours)) : null;
      return s.calculateCompletedEpisodeRuling(
          bleedingStart: anchor, bleedingEnd: end, previousHaydEnd: prevEnd);
    }

    FiqhRuling tuhrAt(int hoursSinceEnd) {
      final fakeNow = anchor.add(Duration(hours: hoursSinceEnd));
      return _serviceAt(fakeNow).getTuhrRuling(lastBleedingEnd: anchor);
    }

    return [
      // ── Active episodes ──────────────────────────────────────────────────────
      _ScenarioData(
        category: 'Aktiv episode',
        name: '40h — Afventer (under minimum)',
        inputDesc: '40 timer blødning, ingen tidligere Hayd',
        ruling: currentAt(40),
      ),
      _ScenarioData(
        category: 'Aktiv episode',
        name: '72h — Gyldig Hayd begynder (præcis grænse)',
        inputDesc: '72 timer blødning — præcis ved minimum',
        ruling: currentAt(72),
      ),
      _ScenarioData(
        category: 'Aktiv episode',
        name: '80h — Gyldig Hayd',
        inputDesc: '80 timer blødning, tilstrækkelig tuhr',
        ruling: currentAt(80),
      ),
      _ScenarioData(
        category: 'Aktiv episode',
        name: '240h — Gyldig Hayd (præcis maksimum)',
        inputDesc: '240 timer blødning — præcis ved grænsen',
        ruling: currentAt(240),
      ),
      _ScenarioData(
        category: 'Aktiv episode',
        name: '250h — Istihada (over maksimum)',
        inputDesc: '250 timer blødning, over 240h grænse',
        ruling: currentAt(250),
      ),
      _ScenarioData(
        category: 'Aktiv episode',
        name: '80h — Istihada (utilstrækkelig tuhr)',
        inputDesc: '80h blødning, men kun 200h tuhr siden sidst Hayd',
        ruling: currentAt(80, tuhrHours: 200),
      ),
      _ScenarioData(
        category: 'Aktiv episode',
        name: '80h — Gyldig Hayd (præcis nok tuhr)',
        inputDesc: '80h blødning, præcis 360h tuhr siden sidst',
        ruling: currentAt(80, tuhrHours: 360),
      ),
      // ── Completed episodes ───────────────────────────────────────────────────
      _ScenarioData(
        category: 'Afsluttet episode',
        name: '50h — Istihada (for kort)',
        inputDesc: 'Episode varer 50h — under 72h minimum',
        ruling: completedAt(50),
      ),
      _ScenarioData(
        category: 'Afsluttet episode',
        name: '72h — Gyldig Hayd (præcis minimum)',
        inputDesc: 'Episode varer præcis 72h',
        ruling: completedAt(72),
      ),
      _ScenarioData(
        category: 'Afsluttet episode',
        name: '120h — Gyldig Hayd (5 dage)',
        inputDesc: 'Episode varer 120h',
        ruling: completedAt(120),
      ),
      _ScenarioData(
        category: 'Afsluttet episode',
        name: '240h — Gyldig Hayd (præcis maksimum)',
        inputDesc: 'Episode varer præcis 240h',
        ruling: completedAt(240),
      ),
      _ScenarioData(
        category: 'Afsluttet episode',
        name: '241h — Istihada (over maksimum)',
        inputDesc: 'Episode varer 241h — over 240h grænse',
        ruling: completedAt(241),
      ),
      _ScenarioData(
        category: 'Afsluttet episode',
        name: '80h — Istihada (tuhr kun 200h)',
        inputDesc: '80h episode, men tuhr var kun 200h (kræves 360h)',
        ruling: completedAt(80, tuhrHours: 200),
      ),
      _ScenarioData(
        category: 'Afsluttet episode',
        name: '80h — Gyldig Hayd (tuhr præcis 360h)',
        inputDesc: '80h episode, tuhr var præcis 360h',
        ruling: completedAt(80, tuhrHours: 360),
      ),
      // ── Tuhr ────────────────────────────────────────────────────────────────
      _ScenarioData(
        category: 'Tuhr (renhed)',
        name: '200h — Tuhr (under tuhr-minimum)',
        inputDesc: '200h siden blødning stoppede',
        ruling: tuhrAt(200),
      ),
      _ScenarioData(
        category: 'Tuhr (renhed)',
        name: '360h — Tuhr (præcis minimum)',
        inputDesc: '360h siden blødning stoppede — ny Hayd mulig',
        ruling: tuhrAt(360),
      ),
      _ScenarioData(
        category: 'Tuhr (renhed)',
        name: '600h — Lang tuhr (25 dage)',
        inputDesc: '600h siden blødning stoppede',
        ruling: tuhrAt(600),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = _buildScenarios();
    final interactiveRuling = _buildInteractiveRuling();
    final categories = <String>[];
    for (final s in scenarios) {
      if (!categories.contains(s.category)) categories.add(s.category);
    }

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        title: const Text('Fiqh Test Scenarier'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(text: 'Interaktiv test'),
          const SizedBox(height: 8),
          _InteractiveCard(
            bleedingHours: _bleedingHours,
            isActiveEpisode: _isActiveEpisode,
            hasPreviousHayd: _hasPreviousHayd,
            tuhrHours: _tuhrHours,
            ruling: interactiveRuling,
            onBleedingHoursChanged: (v) => setState(() => _bleedingHours = v),
            onIsActiveChanged: (v) => setState(() => _isActiveEpisode = v),
            onHasPreviousHaydChanged: (v) => setState(() => _hasPreviousHayd = v),
            onTuhrHoursChanged: (v) => setState(() => _tuhrHours = v),
          ),
          const SizedBox(height: 24),
          _SectionHeader(
              text: 'Foruddefinerede scenarier (${scenarios.length})'),
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmGray,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            for (final s
                in scenarios.where((s) => s.category == category))
              _ScenarioCard(scenario: s),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _ScenarioData {
  final String category;
  final String name;
  final String inputDesc;
  final FiqhRuling ruling;

  const _ScenarioData({
    required this.category,
    required this.name,
    required this.inputDesc,
    required this.ruling,
  });
}

// ── Interactive Card ──────────────────────────────────────────────────────────

class _InteractiveCard extends StatelessWidget {
  final double bleedingHours;
  final bool isActiveEpisode;
  final bool hasPreviousHayd;
  final double tuhrHours;
  final FiqhRuling ruling;
  final ValueChanged<double> onBleedingHoursChanged;
  final ValueChanged<bool> onIsActiveChanged;
  final ValueChanged<bool> onHasPreviousHaydChanged;
  final ValueChanged<double> onTuhrHoursChanged;

  const _InteractiveCard({
    required this.bleedingHours,
    required this.isActiveEpisode,
    required this.hasPreviousHayd,
    required this.tuhrHours,
    required this.ruling,
    required this.onBleedingHoursChanged,
    required this.onIsActiveChanged,
    required this.onHasPreviousHaydChanged,
    required this.onTuhrHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hours = bleedingHours.round();
    final days = hours ~/ 24;
    final remH = hours % 24;
    final durationLabel =
        days > 0 ? '$days dag(e) $remH t  ($hours t total)' : '$hours timer';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.plum.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bleeding duration slider
          Row(
            children: [
              const Text('Blødningsvarighed',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(durationLabel,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.plum,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: bleedingHours,
            min: 0,
            max: 300,
            divisions: 300,
            activeColor: AppTheme.rose,
            onChanged: onBleedingHoursChanged,
          ),
          // Threshold chips
          Row(
            children: [
              _ThresholdChip(
                  label: '72h min',
                  active: hours >= 72,
                  activeColor: AppTheme.mint),
              const SizedBox(width: 8),
              _ThresholdChip(
                  label: '240h max overskredet',
                  active: hours > 240,
                  activeColor: AppTheme.rose),
            ],
          ),
          const SizedBox(height: 12),
          // Toggles
          Row(
            children: [
              Expanded(
                child: _ToggleRow(
                  label: 'Aktiv episode',
                  value: isActiveEpisode,
                  onChanged: onIsActiveChanged,
                ),
              ),
              Expanded(
                child: _ToggleRow(
                  label: 'Har tidl. Hayd',
                  value: hasPreviousHayd,
                  onChanged: onHasPreviousHaydChanged,
                ),
              ),
            ],
          ),
          // Tuhr slider (only when has previous hayd)
          if (hasPreviousHayd) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Tuhr siden sidst',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${tuhrHours.round()} t',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.mint,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: tuhrHours,
              min: 0,
              max: 500,
              divisions: 500,
              activeColor: AppTheme.mint,
              onChanged: onTuhrHoursChanged,
            ),
            _ThresholdChip(
                label: '360h tuhr minimum nået',
                active: tuhrHours >= 360,
                activeColor: AppTheme.mint),
          ],
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          _RulingResult(ruling: ruling),
        ],
      ),
    );
  }
}

// ── Scenario Card ─────────────────────────────────────────────────────────────

class _ScenarioCard extends StatelessWidget {
  final _ScenarioData scenario;

  const _ScenarioCard({required this.scenario});

  @override
  Widget build(BuildContext context) {
    final typeColor = _rulingColor(scenario.ruling);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  scenario.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkPlum),
                ),
              ),
              const SizedBox(width: 8),
              _TypeBadge(ruling: scenario.ruling),
            ],
          ),
          const SizedBox(height: 3),
          Text(scenario.inputDesc,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.warmGray)),
          const SizedBox(height: 10),
          _RulingResult(ruling: scenario.ruling),
        ],
      ),
    );
  }

  Color _rulingColor(FiqhRuling r) {
    if (r.purityState == PurityState.tuhr) return AppTheme.mint;
    return r.bleedingType == BleedingType.hayd ? AppTheme.rose : AppTheme.gold;
  }
}

// ── Ruling Result block ───────────────────────────────────────────────────────

class _RulingResult extends StatelessWidget {
  final FiqhRuling ruling;

  const _RulingResult({required this.ruling});

  @override
  Widget build(BuildContext context) {
    final perms = [
      (label: 'Salah', allowed: !ruling.salahProhibited),
      (label: 'Faste', allowed: !ruling.fastingProhibited),
      (label: 'Quran', allowed: !ruling.quranRecitationProhibited),
      (label: 'Intimitet', allowed: !ruling.intimacyForbiddenUntilNorm),
      (label: "Duʿā", allowed: ruling.duaRecitationAllowed),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: perms.map((p) {
            final color = p.allowed ? AppTheme.mint : AppTheme.rose;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(p.allowed ? Icons.check : Icons.close,
                      size: 10, color: color),
                  const SizedBox(width: 4),
                  Text(p.label,
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          ruling.explanation,
          style: const TextStyle(
              fontSize: 10, color: AppTheme.warmGray, height: 1.4),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Type Badge ────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final FiqhRuling ruling;

  const _TypeBadge({required this.ruling});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (ruling.purityState == PurityState.tuhr) {
      label = 'Tuhr';
      color = AppTheme.mint;
    } else if (ruling.bleedingType == BleedingType.hayd) {
      label = 'Hayd';
      color = AppTheme.rose;
    } else {
      label = 'Istihada';
      color = AppTheme.gold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.darkPlum),
    );
  }
}

class _ThresholdChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;

  const _ThresholdChip(
      {required this.label,
      required this.active,
      required this.activeColor});

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : Colors.grey.shade400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? activeColor.withValues(alpha: 0.12) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow(
      {required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 11))),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.plum,
          activeTrackColor: AppTheme.plumLight,
        ),
      ],
    );
  }
}
