# Changelog


## 1.1.3
- add readme.md example
## 1.1.2
- Added terminal keyboard listener support (`onKey`, `handleCtrlC`, `handleInputBytes`, `dispatchKey`) to `Canvas` with automatic raw-mode setup and restoration.
- Added `KeyEvent` and `KeyCode` to parse arrow keys, Space, Enter, Escape, Ctrl combinations, and UTF-8 characters.
- Fixed terminal frame flushing in `Canvas` so rendering no longer scrolls or duplicates top border lines when the canvas height approaches the terminal height.
- Added interactive hit-the-ball mini-game example (`example/hit_ball_game.dart`) with score and countdown header.

## 1.1.1
- Add examples
## 1.1.0
- Introduced a 2D terminal `Canvas` and `CanvasContext2D` rendering engine inspired by HTML5 Canvas 2D.
- Added hierarchical scene-graph `Node` architecture (`Node`, `GroupNode`) supporting `(x, y)` coordinates, `zIndex` depth sorting, visibility toggling, and `onResize` terminal hooks.
- Added 2D shape and primitive nodes: `Square`, `RectNode`, `Circle`, `Line`, `TextNode`, `SpriteNode`, and `CustomNode`.
- Extended `AnsiColor` with 256-color palette (`AnsiColor.palette`) and 24-bit RGB (`AnsiColor.rgb`) support.
- Added `NewtonsCradleAnimation`, `BlackHoleAnimation`, `ParticleFountainAnimation`, `DnaHelixAnimation`, and `Rotating3DStarAnimation`.
- Migrated all 17 built-in animations to extend `Node` and render directly onto `CanvasContext2D` at any `(x, y)` position while preserving standalone `Animation` and `AnimationGroup` compatibility.

## 1.0.2
- Added `AudioVisualizerAnimation`.
- Added `SpectrumAnimation`.

## 1.0.1
- Added `MatrixRainAnimation`.

## 1.0.0
- Initial stable release.
- Added spinner, dots, pulse, blink, progress, donut, typewriter, train, and bicycle animations.
- Added `AnimationGroup` for running multiple animations concurrently.
- Added configurable animation speed, duration, looping, and ANSI color support.
