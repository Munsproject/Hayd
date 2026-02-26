import 'package:flutter_test/flutter_test.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';

void main() {
  // Helper: create a service with a fixed "now"
  FiqhCalculatorService serviceAt(DateTime fakeNow) =>
      FiqhCalculatorService(clock: () => fakeNow);

  // Fixed anchor date for all tests
  final anchor = DateTime(2024, 1, 1, 0, 0);

  // ── isValidHayd ─────────────────────────────────────────────────────────────

  group('isValidHayd', () {
    test('returns false when completed bleeding < 72h', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 50));
      final s = serviceAt(end);
      expect(s.isValidHayd(bleedingStart: start, bleedingEnd: end), isFalse);
    });

    test('returns true when bleeding is exactly 72h', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 72));
      final s = serviceAt(end);
      expect(s.isValidHayd(bleedingStart: start, bleedingEnd: end), isTrue);
    });

    test('returns true at 120h (5 days)', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 120));
      final s = serviceAt(end);
      expect(s.isValidHayd(bleedingStart: start, bleedingEnd: end), isTrue);
    });

    test('returns true at exactly 240h (max)', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 240));
      final s = serviceAt(end);
      expect(s.isValidHayd(bleedingStart: start, bleedingEnd: end), isTrue);
    });

    test('returns false when bleeding > 240h', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 241));
      final s = serviceAt(end);
      expect(s.isValidHayd(bleedingStart: start, bleedingEnd: end), isFalse);
    });

    test('returns false when tuhr < 360h since last Hayd', () {
      final prevEnd = anchor;
      final start = prevEnd.add(const Duration(hours: 200)); // only 200h tuhr
      final end = start.add(const Duration(hours: 100));
      final s = serviceAt(end);
      expect(
        s.isValidHayd(
            bleedingStart: start, bleedingEnd: end, previousHaydEnd: prevEnd),
        isFalse,
      );
    });

    test('returns true when tuhr is exactly 360h', () {
      final prevEnd = anchor;
      final start = prevEnd.add(const Duration(hours: 360));
      final end = start.add(const Duration(hours: 80));
      final s = serviceAt(end);
      expect(
        s.isValidHayd(
            bleedingStart: start, bleedingEnd: end, previousHaydEnd: prevEnd),
        isTrue,
      );
    });

    test('returns false when no bleedingEnd and duration < 72h', () {
      // active episode only 40h in — not valid yet
      final start = anchor;
      final fakeNow = anchor.add(const Duration(hours: 40));
      final s = serviceAt(fakeNow);
      expect(s.isValidHayd(bleedingStart: start), isFalse);
    });
  });

  // ── calculateCurrentRuling ───────────────────────────────────────────────────

  group('calculateCurrentRuling', () {
    test('< 72h: inHayd state (watching period) with correct hour count', () {
      final start = anchor;
      final fakeNow = anchor.add(const Duration(hours: 40));
      final s = serviceAt(fakeNow);
      final ruling = s.calculateCurrentRuling(bleedingStart: start);
      expect(ruling.purityState, PurityState.inHayd);
      expect(ruling.salahProhibited, isTrue);
      expect(ruling.durationHours, 40);
    });

    test('72h: transitions to valid Hayd', () {
      final start = anchor;
      final fakeNow = anchor.add(const Duration(hours: 72));
      final s = serviceAt(fakeNow);
      final ruling = s.calculateCurrentRuling(bleedingStart: start);
      expect(ruling.bleedingType, BleedingType.hayd);
      expect(ruling.purityState, PurityState.inHayd);
    });

    test('80h with sufficient tuhr: valid Hayd', () {
      final start = anchor;
      final fakeNow = anchor.add(const Duration(hours: 80));
      final s = serviceAt(fakeNow);
      final ruling = s.calculateCurrentRuling(bleedingStart: start);
      expect(ruling.bleedingType, BleedingType.hayd);
    });

    test('> 240h: classified as Istihada', () {
      final start = anchor;
      final fakeNow = anchor.add(const Duration(hours: 250));
      final s = serviceAt(fakeNow);
      final ruling = s.calculateCurrentRuling(bleedingStart: start);
      expect(ruling.bleedingType, BleedingType.istihada);
      expect(ruling.salahProhibited, isFalse);
    });

    test('80h but insufficient tuhr (200h): Istihada', () {
      final prevEnd = anchor;
      final start = prevEnd.add(const Duration(hours: 200));
      final fakeNow = start.add(const Duration(hours: 80));
      final s = serviceAt(fakeNow);
      final ruling = s.calculateCurrentRuling(
        bleedingStart: start,
        previousHaydEnd: prevEnd,
      );
      expect(ruling.bleedingType, BleedingType.istihada);
    });
  });

  // ── calculateCompletedEpisodeRuling ──────────────────────────────────────────

  group('calculateCompletedEpisodeRuling', () {
    test('50h episode → Istihada, now in Tuhr', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 50));
      final s = serviceAt(end);
      final ruling = s.calculateCompletedEpisodeRuling(
          bleedingStart: start, bleedingEnd: end);
      expect(ruling.bleedingType, BleedingType.istihada);
      expect(ruling.purityState, PurityState.tuhr);
    });

    test('80h episode → valid Hayd, now in Tuhr', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 80));
      final s = serviceAt(end);
      final ruling = s.calculateCompletedEpisodeRuling(
          bleedingStart: start, bleedingEnd: end);
      expect(ruling.bleedingType, BleedingType.hayd);
      expect(ruling.purityState, PurityState.tuhr);
      expect(ruling.salahProhibited, isFalse);
    });

    test('241h episode → Istihada (exceeds max)', () {
      final start = anchor;
      final end = anchor.add(const Duration(hours: 241));
      final s = serviceAt(end);
      final ruling = s.calculateCompletedEpisodeRuling(
          bleedingStart: start, bleedingEnd: end);
      expect(ruling.bleedingType, BleedingType.istihada);
    });

    test('80h episode but tuhr only 200h → Istihada', () {
      final prevEnd = anchor;
      final start = prevEnd.add(const Duration(hours: 200));
      final end = start.add(const Duration(hours: 80));
      final s = serviceAt(end);
      final ruling = s.calculateCompletedEpisodeRuling(
        bleedingStart: start,
        bleedingEnd: end,
        previousHaydEnd: prevEnd,
      );
      expect(ruling.bleedingType, BleedingType.istihada);
    });
  });

  // ── getTuhrRuling ────────────────────────────────────────────────────────────

  group('getTuhrRuling', () {
    test('reports correct tuhr duration in hours', () {
      final end = anchor;
      final fakeNow = anchor.add(const Duration(hours: 200));
      final s = serviceAt(fakeNow);
      final ruling = s.getTuhrRuling(lastBleedingEnd: end);
      expect(ruling.durationHours, 200);
      expect(ruling.purityState, PurityState.tuhr);
      expect(ruling.salahProhibited, isFalse);
      expect(ruling.fastingProhibited, isFalse);
    });

    test('all ibadah permitted during Tuhr', () {
      final end = anchor;
      final fakeNow = anchor.add(const Duration(hours: 400));
      final s = serviceAt(fakeNow);
      final ruling = s.getTuhrRuling(lastBleedingEnd: end);
      expect(ruling.quranRecitationProhibited, isFalse);
      expect(ruling.intimacyForbiddenUntilNorm, isFalse);
    });
  });

  // ── formatDuration ───────────────────────────────────────────────────────────

  group('formatDuration', () {
    test('less than 24h shows only hours', () {
      final s = serviceAt(anchor);
      expect(s.formatDuration(10), '10 timer');
    });

    test('exact days shows only days', () {
      final s = serviceAt(anchor);
      expect(s.formatDuration(48), '2 dage');
    });

    test('days with remaining hours shows both', () {
      final s = serviceAt(anchor);
      expect(s.formatDuration(50), '2 dage, 2 timer');
    });
  });
}
