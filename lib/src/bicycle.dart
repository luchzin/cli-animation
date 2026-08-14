import '../animation.dart';

class BicycleAnimation extends Animation {
  BicycleAnimation({
    super.speed = const Duration(milliseconds: 100),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  });

  int _frame = 0;

  static const List<String> _frames = [
    r'''
     __o
   _ \<_
  (_)/(_)
''',
    r'''
      __o
    _ \<_
   (_)/(_)
''',
    r'''
       __o
     _ \<_
    (_)/(_)
''',
    r'''
        __o
      _ \<_
     (_)/(_)
''',
    r'''
         __o
       _ \<_
      (_)/(_)
''',
    r'''
          __o
        _ \<_
       (_)/(_)
''',
  ];

  @override
  int get height => 3;

  @override
  void tick() {
    write(_frames[_frame]);

    _frame = (_frame + 1) % _frames.length;
  }
}
