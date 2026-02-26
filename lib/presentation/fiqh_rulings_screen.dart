import 'package:flutter/material.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';

class FiqhRulingsScreen extends StatelessWidget {
  const FiqhRulingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        title: const Text('Islamiske Regler · Hanafi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: const [
          _Section(
            title: '🩸 Hayd – Grundregler',
            color: AppTheme.roseLight,
            borderColor: AppTheme.rose,
            items: [
              _RuleItem('Minimumvarighed: 72 timer (3 dage)'),
              _RuleItem('Maksimumsvarighed: 240 timer (10 dage)'),
              _RuleItem('Minimumsalder for Hayd: 9 år (islamisk/hijri kalender)'),
              _RuleItem('Minimum tuhr (renhed) mellem to Hayd: 360 timer (15 dage)'),
              _RuleItem('Blod under 72 timer → Istihada (efter ophør)'),
              _RuleItem('Blod over 240 timer → returnér til norm (ʿĀdah)'),
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: '🌸 Norm (ʿĀdah) – Etablering & Ændring',
            color: AppTheme.lavLight,
            borderColor: AppTheme.lavender,
            items: [
              _RuleItem('Norm etableres ved én komplet gyldig cyklus (hayd + tuhr)'),
              _RuleItem('Kun gyldigt blod og gyldig tuhr kan bruges som norm'),
              _RuleItem('Norm bruges ved ugyldig blødning/tuhr som reference'),
              _RuleItem('Pladsændring: menstruation kommer senere end forventet → tuhr-norm ændres'),
              _RuleItem('Pladsændring: menstruation kommer tidligt (men ≥15d tuhr) → tuhr-norm ændres'),
              _RuleItem('Talændring: blødning stopper på andet antal dage (3–10) → hayd-norm ændres'),
              _RuleItem('Blødning over 10 dage: hayd tæller kun inden for normtid, resten Istihada'),
              _RuleItem('Eks: 6d hayd + 17d tuhr + 9d hayd → ny norm: 9d hayd / 17d tuhr'),
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: '⚠️ Istihada – Uregelmæssig Blødning',
            color: AppTheme.goldLight,
            borderColor: AppTheme.gold,
            items: [
              _RuleItem('Blødning < 72 timer efter ophør: Istihada'),
              _RuleItem('Blødning > 240 timer: overskydende dage = Istihada'),
              _RuleItem('Utilstrækkelig tuhr (< 15 dage) siden sidst: Istihada'),
              _RuleItem('Under Istihada: salah og faste skyldes'),
              _RuleItem('Under Istihada: wudu fornyes ved hver salah (maʿdhūr-regel)'),
              _RuleItem('Under Istihada: tawaf er tilladt med wudu'),
              _RuleItem('Under Istihada: intimitet med ægtefælle er tilladt'),
              _RuleItem('Under Istihada: Koranlæsning er tilladt'),
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: '🚫 Forbudt Under Hayd',
            color: AppTheme.roseLight,
            borderColor: AppTheme.rose,
            items: [
              _RuleItem('Salah (bøn) er forbudt – skyldes ikke efter hayd'),
              _RuleItem('Faste er forbudt – skyldes for de missede dage'),
              _RuleItem('Koranlæsning (recitation/tilāwah) er forbudt'),
              _RuleItem('Berøring af mushaf (Koranens sider) er forbudt'),
              _RuleItem('Tawaf (omgang om Kaʿbaen) er forbudt'),
              _RuleItem('Ophold i bedeområde / iʿtikāf er forbudt'),
              _RuleItem('Seksuel intimitet med ægtefælle er forbudt (hele hayd-perioden)'),
              _RuleItem('Intimitet forbudt til norm-perioden er fuldt udløbet, selv om blødning stopper tidligt'),
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: '✅ Tilladt Under Hayd',
            color: AppTheme.mintLight,
            borderColor: AppTheme.mint,
            items: [
              _RuleItem('Recitation med intention om duʿā er tilladt (fx Āyat ul-Kursī og Quls)'),
              _RuleItem('Dhikr, duʿā, istighfār, takbīr'),
              _RuleItem('Lytte til Koranen'),
              _RuleItem('Lære Koranen udenad (hifẓ)'),
              _RuleItem('Al anden dagligdags aktivitet'),
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: '🌙 Speciel Regel: Hayd-tid / Periode kortere end norm',
            color: Color(0xFFEEF4FF),
            borderColor: Color(0xFF7BA7D4),
            items: [
              _RuleItem('Koranlæsning er forbudt under hayd'),
              _RuleItem('Recitation med intention om duʿā er tilladt (Āyat ul-Kursī, Quls)'),
              _RuleItem('Salah er forbudt i hele hayd-perioden (uanset om blødning stopper tidligt)'),
              _RuleItem('Intimitet forbudt til norm-perioden er FULDT udløbet'),
              _RuleItem('Faste skyldes — selv hvis blødning stopper tidligt'),
              _RuleItem('Kvinden venter til norm-tid er gået + ghusl før salah og intimitet'),
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: '🤱 Nifas – Barselblødning',
            color: AppTheme.lavLight,
            borderColor: AppTheme.plumLight,
            items: [
              _RuleItem('Maksimumvarighed: 960 timer (40 dage)'),
              _RuleItem('Intet minimum for Nifas (selv 1 dag er gyldigt)'),
              _RuleItem('Regler svarer til Hayd (salah, faste, intimitet forbudt)'),
              _RuleItem('Blødning over 40 dage → Istihada'),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final List<_RuleItem> items;

  const _Section({
    required this.title,
    required this.color,
    required this.borderColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.darkPlum,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => item.build()),
        ],
      ),
    );
  }
}

class _RuleItem {
  final String text;

  const _RuleItem(this.text);

  Widget build() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppTheme.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.darkPlum,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
