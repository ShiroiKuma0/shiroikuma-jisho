import 'dart:io';

/// Gate for the external-lookup timing trace. `const false` dead-codes
/// every `if (kLookupTrace) lookupTrace(...)` call site.
const bool kLookupTrace = false;

/// Where the trace goes. MainActivity appends its own lines (intent and
/// lifecycle callbacks) to the same file, so one `adb pull` shows the
/// whole path from the intent to the drawn result. Wall-clock
/// milliseconds on both sides, so the lines interleave correctly.
const String lookupTracePath = '/sdcard/tmp/jisho-lookup-trace.log';

/// Append one timestamped [event] line to [lookupTracePath]. Synchronous
/// on purpose — an IOSink buffers, and an un-awaited flush loses lines
/// (see on-device diagnostics notes). Safe from any isolate, including
/// the search worker.
void lookupTrace(String event) {
  try {
    File(lookupTracePath).writeAsStringSync(
      '${DateTime.now().millisecondsSinceEpoch} dart '
      'majflt=${_majorFaults()} $event\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {}
}

/// The process's major page faults so far — reads from storage, chiefly
/// the memory-mapped dictionary database. Field 12 of /proc/self/stat.
String _majorFaults() {
  try {
    final String stat = File('/proc/self/stat').readAsStringSync();
    // The command name (field 2) may contain spaces; count from its end.
    final List<String> fields = stat
        .substring(stat.lastIndexOf(')') + 2)
        .split(' ');
    return fields[9];
  } catch (_) {
    return '?';
  }
}

/// Trace-only accumulator of time spent in named render stages, written
/// out and reset by [flush].
class LookupTraceCost {
  final Map<String, int> _micros = {};
  final Map<String, int> _counts = {};

  /// Add [micros] to [stage].
  void add(String stage, int micros) {
    if (!kLookupTrace) return;
    _micros[stage] = (_micros[stage] ?? 0) + micros;
    _counts[stage] = (_counts[stage] ?? 0) + 1;
  }

  /// Trace the totals under [label] and reset them.
  void flush(String label) {
    if (!kLookupTrace) return;
    lookupTrace('$label costs ${[
      for (final e in _micros.entries)
        '${e.key}=${e.value ~/ 1000}ms/${_counts[e.key]}',
    ].join(' ')}');
    _micros.clear();
    _counts.clear();
  }
}

/// The shared [LookupTraceCost].
final LookupTraceCost lookupTraceCost = LookupTraceCost();
