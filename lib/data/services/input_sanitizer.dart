/// Input sanitisation and validation utilities.
///
/// Two threat models are addressed:
///
/// 1. **Prompt injection into the on-device AI.** User-controlled fields
///    (`profile.name`, `profile.placeLabel`) flow into the prompt sent to
///    Apple Intelligence. A user could enter `"...\nIgnore all prior\n"` and
///    redirect the model. Inputs are stripped of control characters /
///    newlines and length-clamped before any AI prompt assembly. The prompt
///    template itself uses delimited blocks plus an explicit instruction
///    that delimiter contents are data, not commands.
///
/// 2. **Garbage-in / crash-prone numeric inputs.** Latitude / longitude
///    parsed from geocoding or current location must be range-checked so
///    that downstream Swiss Ephemeris calls don't receive NaN or out-of-
///    range values that produce undefined results.
library;

class InputSanitizer {
  InputSanitizer._();

  /// Maximum characters allowed for any free-text field that flows into
  /// chart calculations or AI prompts. Names longer than this are very
  /// likely paste / injection attempts rather than real names.
  static const int maxNameLength = 60;
  static const int maxPlaceLabelLength = 120;

  /// Removes ASCII / Unicode control characters (including `\n`, `\r`,
  /// `\t`, zero-width joiners, BiDi overrides, etc.) and collapses all
  /// runs of whitespace to a single space. Trims surrounding whitespace.
  ///
  /// Preserves regular printable Unicode (any letter / number / mark /
  /// symbol / punctuation that is not a control character).
  static String stripControlChars(String input) {
    final buf = StringBuffer();
    for (final rune in input.runes) {
      // C0: 0x00-0x1F, DEL: 0x7F, C1: 0x80-0x9F.
      if (rune < 0x20 || rune == 0x7F || (rune >= 0x80 && rune <= 0x9F)) {
        // Replace control chars with a single space — keeps tokenisation
        // sane without leaking the original byte sequence.
        buf.write(' ');
        continue;
      }
      // Strip unicode line/paragraph separators which DateFormat / AI
      // prompts treat as line breaks.
      if (rune == 0x2028 || rune == 0x2029) {
        buf.write(' ');
        continue;
      }
      // Strip BiDi overrides (CVE-class "Trojan Source") and zero-width
      // characters that can hide malicious payloads.
      if (rune == 0x202A ||
          rune == 0x202B ||
          rune == 0x202C ||
          rune == 0x202D ||
          rune == 0x202E ||
          rune == 0x2066 ||
          rune == 0x2067 ||
          rune == 0x2068 ||
          rune == 0x2069 ||
          rune == 0x200B ||
          rune == 0x200C ||
          rune == 0x200D ||
          rune == 0xFEFF) {
        continue;
      }
      buf.writeCharCode(rune);
    }
    return buf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Sanitises a free-text name and clamps its length. Used by the
  /// `BirthProfile` flow before persisting to Hive.
  static String sanitizeName(String input) {
    final clean = stripControlChars(input);
    if (clean.length <= maxNameLength) return clean;
    return clean.substring(0, maxNameLength);
  }

  /// Sanitises a place label.
  static String sanitizePlaceLabel(String input) {
    final clean = stripControlChars(input);
    if (clean.length <= maxPlaceLabelLength) return clean;
    return clean.substring(0, maxPlaceLabelLength);
  }

  /// Sanitises an arbitrary user string that will be inlined into an AI
  /// prompt. Strips delimiter sequences that could break out of a fenced
  /// data block, control characters, and prompt-engineering keywords like
  /// `"system:"` / `"assistant:"` / `"###"`. The result is still
  /// human-readable.
  static String sanitizeForPrompt(String input, {int maxLength = 200}) {
    var out = stripControlChars(input);
    // Strip our own delimiter to make breakout impossible.
    out = out.replaceAll('<<<', '').replaceAll('>>>', '');
    // Strip role-impersonation prefixes (case-insensitive, at any
    // position). The on-device Foundation Models guard against most of
    // these, but defence in depth is cheap.
    out = out.replaceAll(
      RegExp(r'(?:system|assistant|user)\s*:', caseSensitive: false),
      '',
    );
    out = out.replaceAll(RegExp(r'#{2,}'), '');
    if (out.length > maxLength) out = out.substring(0, maxLength);
    return out.trim();
  }

  /// Validates a WGS-84 latitude. Returns the value when valid, or `null`
  /// when out of range / not finite.
  static double? validateLatitude(double? lat) {
    if (lat == null || lat.isNaN || lat.isInfinite) return null;
    if (lat < -90.0 || lat > 90.0) return null;
    return lat;
  }

  /// Validates a WGS-84 longitude. Returns the value when valid, or `null`
  /// when out of range / not finite. Wraps to `[-180, 180]` is **not**
  /// performed because callers should treat out-of-range as user error.
  static double? validateLongitude(double? lng) {
    if (lng == null || lng.isNaN || lng.isInfinite) return null;
    if (lng < -180.0 || lng > 180.0) return null;
    return lng;
  }

  /// Validates birth datetime. Sweph's bundled ephemerides cover 1800-2400.
  /// Outside that window we refuse the input rather than silently producing
  /// garbage positions. Future dates are also rejected because all chart
  /// calculations key off a real birth in the past.
  static bool isValidBirthDateTime(DateTime utc) {
    final lower = DateTime.utc(1800, 1, 1);
    final upper = DateTime.now().toUtc();
    if (utc.isBefore(lower)) return false;
    if (utc.isAfter(upper)) return false;
    return true;
  }
}
