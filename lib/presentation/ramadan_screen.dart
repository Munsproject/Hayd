import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/domain/services/cycle_analyzer_service.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/domain/services/ramadan_service.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';

/// Settings passed back to the caller when the screen is closed.
class RamadanSettings {
  final bool isEnabled;
  final DateTime ramadanStart;
  final int durationDays;
  final int fajrHour;
  final int fajrMinute;
  final int maghrebHour;
  final int maghrebMinute;

  const RamadanSettings({
    required this.isEnabled,
    required this.ramadanStart,
    required this.durationDays,
    this.fajrHour = 4,
    this.fajrMinute = 0,
    this.maghrebHour = 20,
    this.maghrebMinute = 0,
  });
}

class RamadanScreen extends StatefulWidget {
  final RamadanSettings settings;
  final List<Episode> episodes;

  const RamadanScreen({
    super.key,
    required this.settings,
    required this.episodes,
  });

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  late bool _isEnabled;
  late DateTime _ramadanStart;
  late int _durationDays;
  late int _fajrHour;
  late int _fajrMinute;
  late int _maghrebHour;
  late int _maghrebMinute;

  final _analyzer = CycleAnalyzerService(FiqhCalculatorService());
  final _ramadanService = RamadanService();

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.settings.isEnabled;
    _ramadanStart = widget.settings.ramadanStart;
    _durationDays = widget.settings.durationDays;
    _fajrHour = widget.settings.fajrHour;
    _fajrMinute = widget.settings.fajrMinute;
    _maghrebHour = widget.settings.maghrebHour;
    _maghrebMinute = widget.settings.maghrebMinute;
  }

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  List<MissedFastDay> get _missedDays => _ramadanService.missedFastingDays(
    cycles: _analyzer.analyzeCycles(widget.episodes),
    ramadanStart: _ramadanStart,
    durationDays: _durationDays,
    fajrHour: _fajrHour,
    fajrMinute: _fajrMinute,
    maghrebHour: _maghrebHour,
    maghrebMinute: _maghrebMinute,
  );

  int get _elapsed => _ramadanService.elapsedDays(
    ramadanStart: _ramadanStart,
    durationDays: _durationDays,
  );
  DateTime get _ramadanEnd => _ramadanStart.add(Duration(days: _durationDays));

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ramadanEnd,
      firstDate: _ramadanStart.add(const Duration(days: 1)),
      lastDate: DateTime(2030),
      helpText: 'Vælg Ramadan slutdato',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.plum,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final days = picked.difference(_ramadanStart).inDays;
      if (days >= 1) setState(() => _durationDays = days);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ramadanStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Vælg Ramadan startdato',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.plum,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _ramadanStart = picked);
    }
  }

  Future<void> _pickFajrTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _fajrHour, minute: _fajrMinute),
      helpText: 'Vælg Fajr tid',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.plum,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() { _fajrHour = picked.hour; _fajrMinute = picked.minute; });
    }
  }

  Future<void> _pickMaghrebTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _maghrebHour, minute: _maghrebMinute),
      helpText: 'Vælg Maghreb tid',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.plum,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() { _maghrebHour = picked.hour; _maghrebMinute = picked.minute; });
    }
  }

  void _pop() {
    Navigator.of(context).pop(
      RamadanSettings(
        isEnabled: _isEnabled,
        ramadanStart: _ramadanStart,
        durationDays: _durationDays,
        fajrHour: _fajrHour,
        fajrMinute: _fajrMinute,
        maghrebHour: _maghrebHour,
        maghrebMinute: _maghrebMinute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: AppTheme.ivory,
        appBar: AppBar(
          title: const Text('Ramadan Tilstand'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _pop,
          ),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Enable toggle ───────────────────────────────────────────────
            _Card(
              child: Row(
                children: [
                  const Icon(
                    Icons.nights_stay_outlined,
                    color: AppTheme.plum,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ramadan Tilstand',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkPlum,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tæller faste dage som skyldes',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.warmGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isEnabled,
                    onChanged: (v) => setState(() => _isEnabled = v),
                    activeThumbColor: AppTheme.plum,
                    activeTrackColor: AppTheme.plumLight,
                  ),
                ],
              ),
            ),

            if (_isEnabled) ...[
              const SizedBox(height: 16),

              // ── Configuration ─────────────────────────────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ramadan Indstillinger',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkPlum,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Start date row
                    Row(
                      children: [
                        const Icon(Icons.event, size: 18, color: AppTheme.plum),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Startdato',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickStartDate,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.plum,
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_ramadanStart),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Slutdato',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickEndDate,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.plum,
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_ramadanEnd),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    // Duration row (computed from start → end)
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 18,
                          color: AppTheme.plum,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Varighed',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '$_durationDays dage',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.plum,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    // Prayer times
                    const Text(
                      'Bedestider',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkPlum,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.wb_twilight, size: 16, color: AppTheme.gold),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Fajr', style: TextStyle(fontSize: 13))),
                        TextButton(
                          onPressed: _pickFajrTime,
                          style: TextButton.styleFrom(foregroundColor: AppTheme.plum),
                          child: Text(
                            _fmt(_fajrHour, _fajrMinute),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.nights_stay_outlined, size: 16, color: AppTheme.plum),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Maghreb', style: TextStyle(fontSize: 13))),
                        TextButton(
                          onPressed: _pickMaghrebTime,
                          style: TextButton.styleFrom(foregroundColor: AppTheme.plum),
                          child: Text(
                            _fmt(_maghrebHour, _maghrebMinute),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Blødning der starter efter Maghreb ugyldiggør ikke fasten — den dag tæller ikke som savnet.',
                      style: TextStyle(fontSize: 10, color: AppTheme.warmGray, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Stats ────────────────────────────────────────────────────
              _StatsCard(
                missedDays: _missedDays,
                elapsed: _elapsed,
                durationDays: _durationDays,
                ramadanStart: _ramadanStart,
              ),

              const SizedBox(height: 16),

              // ── Missed days list ──────────────────────────────────────────
              if (_missedDays.isNotEmpty) ...[
                const _SectionHeader('Savnede fasteDage'),
                const SizedBox(height: 8),
                ..._missedDays.map((d) => _MissedDayTile(missed: d)),
              ] else ...[
                _Card(
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: AppTheme.mint, size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Ingen savnede faster registreret endnu.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.warmGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            if (!_isEnabled) ...[
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Aktiver Ramadan Tilstand for at\ntælle savnede faster.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.warmGray),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Stats Card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final List<MissedFastDay> missedDays;
  final int elapsed;
  final int durationDays;
  final DateTime ramadanStart;

  const _StatsCard({
    required this.missedDays,
    required this.elapsed,
    required this.durationDays,
    required this.ramadanStart,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = missedDays.length; // days still to make up
    final ramadanEnd = ramadanStart.add(Duration(days: durationDays - 1));
    final isOver = DateTime.now().isAfter(ramadanEnd);
    final progress = elapsed / durationDays;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Oversigt',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkPlum,
            ),
          ),
          const SizedBox(height: 14),

          // Big missed count
          Center(
            child: Column(
              children: [
                Text(
                  '$remaining',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.rose,
                  ),
                ),
                const Text(
                  'dage skal erstattes',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.warmGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.roseLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.plum),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$elapsed af $durationDays dage forløbet',
                style: const TextStyle(fontSize: 10, color: AppTheme.warmGray),
              ),
              if (isOver)
                const Text(
                  'Ramadan afsluttet',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.mint,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '${durationDays - elapsed} dage tilbage',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.warmGray,
                  ),
                ),
            ],
          ),

          const Divider(height: 20),

          // Stat rows
          _StatRow(
            icon: Icons.water_drop,
            label: 'Blødningsdage i Ramadan',
            value: '${missedDays.length}',
            color: AppTheme.rose,
          ),
          _StatRow(
            icon: Icons.calendar_today,
            label: 'Ramadan startdato',
            value: DateFormat('dd/MM/yyyy').format(ramadanStart),
            color: AppTheme.plum,
          ),
          _StatRow(
            icon: Icons.event_available,
            label: 'Ramadan slutdato',
            value: DateFormat('dd/MM/yyyy').format(ramadanEnd),
            color: AppTheme.plum,
          ),
        ],
      ),
    );
  }
}

// ── Missed Day Tile ───────────────────────────────────────────────────────────

class _MissedDayTile extends StatelessWidget {
  final MissedFastDay missed;

  const _MissedDayTile({required this.missed});

  @override
  Widget build(BuildContext context) {
    final isHayd = missed.bleedingType == BleedingType.hayd;
    final color = isHayd ? AppTheme.rose : AppTheme.gold;
    final label = isHayd ? 'Hayd' : 'Istihada';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop, color: color, size: 16),
          const SizedBox(width: 10),
          Text(
            DateFormat('EEEE d. MMMM yyyy', 'da').format(missed.date),
            style: const TextStyle(fontSize: 13, color: AppTheme.darkPlum),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.plum.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkPlum,
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
