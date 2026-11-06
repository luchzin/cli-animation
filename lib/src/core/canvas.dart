import 'dart:async';
import 'dart:io';

import 'ansi_color.dart';
import 'context_2d.dart';
import 'node.dart';
import 'size.dart';

/// Callback signature invoked when the canvas or terminal size changes.
typedef ResizeCallback = void Function(Size newSize);

/// Callback signature invoked on every frame before rendering.
typedef FrameCallback = void Function(double dt, CanvasContext2D ctx);

/// A 2D terminal Canvas that manages a scene graph of [Node]s and renders them at `(x, y)`.
///
/// Example usage:
/// ```dart
/// final cv = Canvas(
///   size: const Size(60, 20),
///   onResize: (newSize) {
///     // Adjust node positions on terminal resize
///   },
/// );
///
/// final square = Square(x: 5, y: 3, size: 6, color: AnsiColor.cyan);
/// cv.add(square);
/// cv.start();
/// ```
class Canvas {
  Canvas({
    Size? size,
    this.frameRate = const Duration(milliseconds: 50),
    this.onResize,
    this.onUpdate,
    this.autoResize = false,
    this.backgroundChar = ' ',
    this.backgroundColor = AnsiColor.reset,
    this.border = false,
    this.borderColor = AnsiColor.gray,
  }) : _size = size ?? Size.fromTerminal(fallback: const Size(60, 20)) {
    _ctx = CanvasContext2D(_size.width, _size.height);
  }

  Size _size;
  late final CanvasContext2D _ctx;

  /// Target duration between rendered frames.
  final Duration frameRate;

  /// Optional callback triggered whenever the canvas is resized.
  final ResizeCallback? onResize;

  /// Optional per-frame hook called before nodes are drawn.
  final FrameCallback? onUpdate;

  /// Whether to listen to OS terminal resize signals (`SIGWINCH`) automatically.
  final bool autoResize;

  /// Character used to clear the canvas background each frame.
  final String backgroundChar;

  /// Background/default color when clearing the canvas.
  final AnsiColor backgroundColor;

  /// Whether to draw an outer frame border around the canvas bounds.
  final bool border;

  /// Color of the outer frame border if [border] is `true`.
  final AnsiColor borderColor;

  final List<Node> _nodes = [];
  Timer? _timer;
  StreamSubscription<ProcessSignal>? _resizeSubscription;
  DateTime? _lastFrameTime;
  bool _running = false;
  int _allocatedTerminalRows = 0;

  /// Current dimensions of the canvas.
  Size get size => _size;

  /// Width (columns) of the canvas.
  int get width => _size.width;

  /// Height (rows) of the canvas.
  int get height => _size.height;

  /// Direct access to the 2D rendering context.
  CanvasContext2D get context => _ctx;

  /// Whether the canvas render loop is currently active.
  bool get isRunning => _running;

  /// Unmodifiable list of root nodes added to this canvas.
  List<Node> get nodes => List.unmodifiable(_nodes);

  /// Adds a [Node] to the canvas scene graph.
  void add(Node node) {
    if (!_nodes.contains(node)) {
      _nodes.add(node);
      if (_running) {
        node.mount();
      }
    }
  }

  /// Adds multiple [Node]s to the canvas scene graph.
  void addAll(Iterable<Node> nodes) {
    for (final node in nodes) {
      add(node);
    }
  }

  /// Removes a [Node] from the canvas scene graph.
  bool remove(Node node) {
    final removed = _nodes.remove(node);
    if (removed && node.isMounted) {
      node.unmount();
    }
    return removed;
  }

  /// Removes all nodes from the canvas.
  void clear() {
    for (final node in _nodes) {
      if (node.isMounted) {
        node.unmount();
      }
    }
    _nodes.clear();
  }

  /// Finds a node in the scene graph by its [id].
  Node? findById(String id) {
    for (final node in _nodes) {
      final match = node.findById(id);
      if (match != null) return match;
    }
    return null;
  }

  /// Manually resizes the canvas and invokes [onResize].
  void resize(Size newSize) {
    if (newSize == _size) return;
    _size = newSize;
    _ctx.resize(newSize);
    onResize?.call(newSize);
  }

  /// Starts the canvas animation loop and begins rendering to the terminal.
  void start() {
    if (_running) return;
    _running = true;
    _lastFrameTime = DateTime.now();

    for (final node in _nodes) {
      node.mount();
    }

    // Reserve vertical space in the terminal
    _allocatedTerminalRows = _size.height;
    stderr.write('\x1B[?25l'); // Hide cursor
    for (var i = 0; i < _allocatedTerminalRows; i++) {
      stderr.writeln();
    }

    if (autoResize || onResize != null) {
      try {
        _resizeSubscription = ProcessSignal.sigwinch.watch().listen((_) {
          final termSize = Size.fromTerminal(fallback: _size);
          resize(termSize);
        });
      } catch (_) {
        // SIGWINCH may not be supported on all platforms (e.g., Windows)
      }
    }

    _tickFrame(0.0);

    _timer = Timer.periodic(frameRate, (_) {
      if (!_running) return;
      final now = DateTime.now();
      final dt =
          now.difference(_lastFrameTime ?? now).inMicroseconds / 1000000.0;
      _lastFrameTime = now;
      _tickFrame(dt);
    });
  }

  /// Stops the canvas animation loop and restores the terminal cursor.
  void stop({bool clearOnStop = true}) {
    if (!_running) return;
    _running = false;

    _timer?.cancel();
    _timer = null;
    _resizeSubscription?.cancel();
    _resizeSubscription = null;

    for (final node in _nodes) {
      node.unmount();
    }

    if (clearOnStop && _allocatedTerminalRows > 0) {
      stderr.write(
        '\x1B[${_allocatedTerminalRows}A'
        '\x1B[J'
        '\x1B[?25h',
      );
    } else {
      stderr.write('\x1B[?25h');
    }
    _allocatedTerminalRows = 0;
  }

  /// Steps the simulation by [dt] seconds and renders the current frame into [context]
  /// without writing to `stderr` (useful for headless testing or custom output).
  String renderFrame([double dt = 0.05]) {
    _ctx.clear(backgroundChar, backgroundColor);

    final snapshot = List<Node>.of(_nodes);
    for (final node in snapshot) {
      node.updateTree(dt);
    }

    onUpdate?.call(dt, _ctx);

    final sorted = List<Node>.of(_nodes)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    for (final node in sorted) {
      node.renderTree(_ctx);
    }

    if (border && _size.width >= 2 && _size.height >= 2) {
      _ctx.strokeRect(
        0,
        0,
        _size.width,
        _size.height,
        color: borderColor,
        asciiBorder: true,
        z: double.maxFinite,
      );
    }

    return _ctx.toAnsiString();
  }

  void _tickFrame(double dt) {
    renderFrame(dt);
    _flushToTerminal(_ctx.toLines());
  }

  void _flushToTerminal(List<String> lines) {
    final buffer = StringBuffer();

    // If canvas grew taller than previously allocated lines, allocate the difference
    if (lines.length > _allocatedTerminalRows) {
      final extra = lines.length - _allocatedTerminalRows;
      for (var i = 0; i < extra; i++) {
        buffer.writeln();
      }
      _allocatedTerminalRows = lines.length;
    }

    if (_allocatedTerminalRows > 0) {
      buffer.write('\x1B[${_allocatedTerminalRows}A');
    }

    for (var i = 0; i < _allocatedTerminalRows; i++) {
      buffer.write('\x1B[2K\r');
      if (i < lines.length) {
        buffer.write(lines[i]);
      }
      if (i < _allocatedTerminalRows - 1) {
        buffer.write('\n');
      }
    }

    buffer.write('\n\r');
    stderr.write(buffer.toString());
  }
}

