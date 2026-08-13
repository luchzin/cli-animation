import '../animation.dart';

class ProgressAnimation extends Animation {
  ProgressAnimation({
    this.width = 30,
    super.speed = const Duration(milliseconds: 50),
    super.duration,
    super.loop = false,
    super.color,
  });

  final int width;

  double _progress = 0;

  void update(double value) {
    _progress = value.clamp(0, 1);

    render();

    if (_progress >= 1) {
      stop();
    }
  }

  @override
  void tick() {
    render();
  }

  void render() {
    clearLine();

    final completed = (_progress * width).round();
    final remaining = width - completed;

    final bar = '${'█' * completed}${'░' * remaining}';
    final percent = (_progress * 100).toInt();

    write('[$bar] $percent%');
  }
}
