import 'ansi_color.dart';
import 'context_2d.dart';

/// Base scene-graph node that can be positioned at `(x, y)` and drawn on a `Canvas`.
///
/// Nodes can have child nodes, forming a hierarchical 2D scene graph where children
/// inherit the coordinate space of their parent.
abstract class Node {
  Node({
    this.x = 0,
    this.y = 0,
    this.zIndex = 0,
    this.visible = true,
    this.color = AnsiColor.reset,
    this.id,
  });

  /// Optional identifier for debugging or lookup.
  final String? id;

  /// Horizontal position in parent coordinate space (columns from left).
  double x;

  /// Vertical position in parent coordinate space (rows from top).
  double y;

  /// Rendering order relative to sibling nodes (lower renders first, higher on top).
  int zIndex;

  /// Whether this node and its children should be drawn.
  bool visible;

  /// Primary foreground color of this node.
  AnsiColor color;

  Node? _parent;
  final List<Node> _children = [];
  bool _mounted = false;

  /// The parent node in the scene graph, or `null` if attached to root or detached.
  Node? get parent => _parent;

  /// Unmodifiable view of child nodes.
  List<Node> get children => List.unmodifiable(_children);

  /// Whether this node is currently mounted in an active scene.
  bool get isMounted => _mounted;

  /// World X coordinate accumulated across ancestor nodes.
  double get worldX => (_parent?.worldX ?? 0.0) + x;

  /// World Y coordinate accumulated across ancestor nodes.
  double get worldY => (_parent?.worldY ?? 0.0) + y;

  /// Adds a child [node] to this node's local coordinate space.
  void add(Node node) {
    if (identical(node, this)) {
      throw ArgumentError('A Node cannot be added as a child of itself.');
    }
    node._parent?.remove(node);
    node._parent = this;
    _children.add(node);
    if (_mounted) {
      node.mount();
    }
  }

  /// Removes a child [node] from this node.
  bool remove(Node node) {
    final removed = _children.remove(node);
    if (removed) {
      if (node._mounted) {
        node.unmount();
      }
      node._parent = null;
    }
    return removed;
  }

  /// Removes all child nodes.
  void clearChildren() {
    for (final child in _children) {
      if (child._mounted) {
        child.unmount();
      }
      child._parent = null;
    }
    _children.clear();
  }

  /// Finds a descendant node by [id], or returns `null`.
  Node? findById(String targetId) {
    if (id == targetId) return this;
    for (final child in _children) {
      final found = child.findById(targetId);
      if (found != null) return found;
    }
    return null;
  }

  /// Internal lifecycle hook called when attached to a running Canvas.
  void mount() {
    if (_mounted) return;
    _mounted = true;
    onMount();
    for (final child in _children) {
      child.mount();
    }
  }

  /// Internal lifecycle hook called when detached or when the Canvas stops.
  void unmount() {
    if (!_mounted) return;
    for (final child in _children) {
      child.unmount();
    }
    _mounted = false;
    onUnmount();
  }

  /// Called once when the node is mounted to an active scene.
  void onMount() {}

  /// Called once when the node is unmounted from an active scene.
  void onUnmount() {}

  /// Updates the node's state for the current frame.
  ///
  /// [dt] is the elapsed time in seconds since the previous frame.
  void update(double dt) {}

  /// Draws this node's visual representation onto [ctx] in local coordinates.
  ///
  /// `(0, 0)` in [ctx] corresponds to this node's `(x, y)` position.
  void draw(CanvasContext2D ctx);

  /// Recursively updates this node and all of its children.
  void updateTree(double dt) {
    update(dt);
    if (_children.isNotEmpty) {
      final snapshot = List<Node>.of(_children);
      for (final child in snapshot) {
        child.updateTree(dt);
      }
    }
  }

  /// Recursively renders this node and its children (sorted by [zIndex]) onto [ctx].
  void renderTree(CanvasContext2D ctx) {
    if (!visible) return;

    ctx.save();
    ctx.translate(x, y);
    if (color != AnsiColor.reset) {
      ctx.defaultColor = color;
    }

    draw(ctx);

    if (_children.isNotEmpty) {
      final sorted = List<Node>.of(_children)
        ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
      for (final child in sorted) {
        child.renderTree(ctx);
      }
    }

    ctx.restore();
  }
}

/// A container node that groups multiple child nodes together under a shared `(x, y)` transform.
class GroupNode extends Node {
  GroupNode({
    super.x,
    super.y,
    super.zIndex,
    super.visible,
    super.color,
    super.id,
    List<Node>? children,
  }) {
    if (children != null) {
      for (final child in children) {
        add(child);
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    // GroupNode is a transform container; children are drawn by renderTree.
  }
}

