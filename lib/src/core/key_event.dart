import 'dart:convert';

/// Logical key codes for terminal keyboard input.
enum KeyCode {
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  enter,
  space,
  escape,
  backspace,
  tab,
  delete,
  home,
  end,
  pageUp,
  pageDown,
  ctrlC,
  character,
  unknown,
}

/// Represents a parsed terminal keyboard event.
class KeyEvent {
  const KeyEvent({
    required this.key,
    this.char,
    this.rawBytes = const [],
    this.isCtrl = false,
  });

  /// Parses raw bytes from `stdin` into one or more [KeyEvent]s.
  ///
  /// Handles multi-byte ANSI escape sequences (e.g. arrow keys, Home/End,
  /// Delete, PageUp/PageDown) as well as rapid key-repeat chunks.
  static List<KeyEvent> parseBytes(List<int> bytes) {
    final events = <KeyEvent>[];
    var i = 0;

    while (i < bytes.length) {
      final b = bytes[i];

      // Escape sequence (0x1B)
      if (b == 0x1B) {
        if (i + 2 < bytes.length && bytes[i + 1] == 0x5B) {
          // CSI sequence: ESC [ <param> ...
          final seq = _parseCsiSequence(bytes, i);
          if (seq != null) {
            events.add(seq.event);
            i += seq.consumed;
            continue;
          }
        } else if (i + 2 < bytes.length && bytes[i + 1] == 0x4F) {
          // SS3 sequence: ESC O <char> (some terminals send this for arrows/Home/End)
          final code = bytes[i + 2];
          final mapped = switch (code) {
            0x41 => KeyCode.arrowUp,
            0x42 => KeyCode.arrowDown,
            0x43 => KeyCode.arrowRight,
            0x44 => KeyCode.arrowLeft,
            0x48 => KeyCode.home,
            0x46 => KeyCode.end,
            _ => KeyCode.unknown,
          };
          events.add(
            KeyEvent(
              key: mapped,
              rawBytes: bytes.sublist(i, i + 3),
            ),
          );
          i += 3;
          continue;
        }

        // Standalone Escape key
        events.add(KeyEvent(key: KeyCode.escape, rawBytes: [b]));
        i += 1;
        continue;
      }

      // Ctrl+C (0x03)
      if (b == 0x03) {
        events.add(KeyEvent(key: KeyCode.ctrlC, isCtrl: true, rawBytes: [b]));
        i += 1;
        continue;
      }

      // Tab (0x09)
      if (b == 0x09) {
        events.add(KeyEvent(key: KeyCode.tab, rawBytes: [b]));
        i += 1;
        continue;
      }

      // Enter / Return (0x0A or 0x0D)
      if (b == 0x0A || b == 0x0D) {
        events.add(KeyEvent(key: KeyCode.enter, rawBytes: [b]));
        i += 1;
        continue;
      }

      // Space (0x20)
      if (b == 0x20) {
        events.add(KeyEvent(key: KeyCode.space, char: ' ', rawBytes: [b]));
        i += 1;
        continue;
      }

      // Backspace (0x7F or 0x08)
      if (b == 0x7F || b == 0x08) {
        events.add(KeyEvent(key: KeyCode.backspace, rawBytes: [b]));
        i += 1;
        continue;
      }

      // Other Ctrl+A..Ctrl+Z (0x01..0x1A)
      if (b >= 0x01 && b <= 0x1A) {
        final letter = String.fromCharCode(b + 96); // 1 -> 'a'
        events.add(
          KeyEvent(
            key: KeyCode.character,
            char: letter,
            isCtrl: true,
            rawBytes: [b],
          ),
        );
        i += 1;
        continue;
      }

      // Printable ASCII (0x21..0x7E)
      if (b >= 0x21 && b <= 0x7E) {
        events.add(
          KeyEvent(
            key: KeyCode.character,
            char: String.fromCharCode(b),
            rawBytes: [b],
          ),
        );
        i += 1;
        continue;
      }

      // UTF-8 multi-byte character
      final utf8Len = _utf8CharLength(b);
      if (utf8Len > 1 && i + utf8Len <= bytes.length) {
        final slice = bytes.sublist(i, i + utf8Len);
        try {
          final decoded = utf8.decode(slice);
          events.add(
            KeyEvent(
              key: KeyCode.character,
              char: decoded,
              rawBytes: slice,
            ),
          );
          i += utf8Len;
          continue;
        } catch (_) {
          // Fall through to unknown byte
        }
      }

      events.add(KeyEvent(key: KeyCode.unknown, rawBytes: [b]));
      i += 1;
    }

    return events;
  }

  static int _utf8CharLength(int firstByte) {
    if ((firstByte & 0xE0) == 0xC0) return 2;
    if ((firstByte & 0xF0) == 0xE0) return 3;
    if ((firstByte & 0xF8) == 0xF0) return 4;
    return 1;
  }

  static ({KeyEvent event, int consumed})? _parseCsiSequence(
    List<int> bytes,
    int start,
  ) {
    final third = bytes[start + 2];
    switch (third) {
      case 0x41: // A
        return (
          event: KeyEvent(
            key: KeyCode.arrowUp,
            rawBytes: bytes.sublist(start, start + 3),
          ),
          consumed: 3,
        );
      case 0x42: // B
        return (
          event: KeyEvent(
            key: KeyCode.arrowDown,
            rawBytes: bytes.sublist(start, start + 3),
          ),
          consumed: 3,
        );
      case 0x43: // C
        return (
          event: KeyEvent(
            key: KeyCode.arrowRight,
            rawBytes: bytes.sublist(start, start + 3),
          ),
          consumed: 3,
        );
      case 0x44: // D
        return (
          event: KeyEvent(
            key: KeyCode.arrowLeft,
            rawBytes: bytes.sublist(start, start + 3),
          ),
          consumed: 3,
        );
      case 0x48: // H
        return (
          event: KeyEvent(
            key: KeyCode.home,
            rawBytes: bytes.sublist(start, start + 3),
          ),
          consumed: 3,
        );
      case 0x46: // F
        return (
          event: KeyEvent(
            key: KeyCode.end,
            rawBytes: bytes.sublist(start, start + 3),
          ),
          consumed: 3,
        );
    }

    // Sequences ending in '~' like ESC [ 3 ~ (Delete), ESC [ 5 ~ (PageUp)
    if (start + 3 < bytes.length && bytes[start + 3] == 0x7E) {
      final mapped = switch (third) {
        0x31 || 0x37 => KeyCode.home,
        0x33 => KeyCode.delete,
        0x34 || 0x38 => KeyCode.end,
        0x35 => KeyCode.pageUp,
        0x36 => KeyCode.pageDown,
        _ => KeyCode.unknown,
      };
      return (
        event: KeyEvent(
          key: mapped,
          rawBytes: bytes.sublist(start, start + 4),
        ),
        consumed: 4,
      );
    }

    return null;
  }

  /// Logical key code.
  final KeyCode key;

  /// Character value when [key] is [KeyCode.character] or [KeyCode.space].
  final String? char;

  /// Raw bytes received from `stdin`.
  final List<int> rawBytes;

  /// Whether Ctrl modifier was held (e.g. Ctrl+C, Ctrl+A..Z).
  final bool isCtrl;

  bool get isUp => key == KeyCode.arrowUp;
  bool get isDown => key == KeyCode.arrowDown;
  bool get isLeft => key == KeyCode.arrowLeft;
  bool get isRight => key == KeyCode.arrowRight;
  bool get isSpace => key == KeyCode.space;
  bool get isEnter => key == KeyCode.enter;
  bool get isEscape => key == KeyCode.escape;

  @override
  String toString() =>
      'KeyEvent(key: $key, char: $char, isCtrl: $isCtrl, rawBytes: $rawBytes)';
}

