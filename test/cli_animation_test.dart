import 'package:cli_animation/lib.dart';
import 'package:test/test.dart';

void main() {
  group('BlackHoleAnimation tests', () {
    test('initializes with default and custom parameters', () {
      final defaultHole = BlackHoleAnimation();
      expect(defaultHole.rows, equals(11));
      expect(defaultHole.cols, equals(45));
      expect(defaultHole.height, equals(11));
      expect(defaultHole.showJets, isTrue);

      final customHole = BlackHoleAnimation(
        rows: 8,
        cols: 30,
        showJets: false,
        color: AnsiColor.yellow,
      );
      expect(customHole.rows, equals(8));
      expect(customHole.cols, equals(30));
      expect(customHole.height, equals(8));
      expect(customHole.showJets, isFalse);
    });

    test('tick runs cleanly without errors', () {
      final hole = BlackHoleAnimation(rows: 7, cols: 25);
      expect(() => hole.tick(), returnsNormally);
      expect(() => hole.tick(), returnsNormally);
    });

    test('integrates with AnimationGroup correctly', () {
      final hole = BlackHoleAnimation(rows: 9, cols: 35);
      final helix = DnaHelixAnimation(rows: 6);
      final group = AnimationGroup([helix, hole]);

      expect(helix.height, equals(6));
      expect(hole.height, equals(9));
      expect(group.animations.length, equals(2));
    });
  });

  group('NewtonsCradleAnimation tests', () {
    test('initializes with default and custom parameters', () {
      final defaultCradle = NewtonsCradleAnimation();
      expect(defaultCradle.balls, equals(5));
      expect(defaultCradle.stringLength, equals(4));
      expect(defaultCradle.height, equals(6));

      final customCradle = NewtonsCradleAnimation(
        balls: 3,
        stringLength: 3,
        color: AnsiColor.green,
      );
      expect(customCradle.balls, equals(3));
      expect(customCradle.stringLength, equals(3));
      expect(customCradle.height, equals(5));
    });

    test('tick runs and renders swings', () {
      final cradle = NewtonsCradleAnimation();
      for (var i = 0; i < 20; i++) {
        expect(() => cradle.tick(), returnsNormally);
      }
    });

    test('integrates with AnimationGroup', () {
      final cradle = NewtonsCradleAnimation(stringLength: 4);
      final group = AnimationGroup([cradle]);
      expect(cradle.height, equals(6));
      expect(group.animations.first, equals(cradle));
    });
  });
}
