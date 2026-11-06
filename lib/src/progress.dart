import '../animation.dart';

/// A horizontal progress bar node with percentage readout.
class ProgressAnimation extends Animation {
  ProgressAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    this.barWidth = 30,
    super.speed = const Duration(milliseconds: 50),
    super.duration,
    super.loop = false,
    super.color,
  });

  final int barWidth;

  double _progress = 0;

  double get progress => _progress;

  @override
  int get width => barWidth + 7;

  void updateProgress(double value) {
    _progress = value.clamp(0.0, 1.0);
    if (_progress >= 1.0 && isRunning) {
      stop();
    }
  }

  @override
  void tick() {}

  @override
  void draw(CanvasContext2D ctx) {
    final completed = (_progress * barWidth).round();
    final remaining = barWidth - completed;

    final bar = '${'█' * completed}${'░' * remaining}';
    final percent = (_progress * 100).toInt();

    ctx.drawText(0, 0, '[$bar] $percent%', color: color, z: zIndex.toDouble());
  }
}
