import 'dart:async';
import 'dart:isolate';

import 'common.dart';

typedef IsolateWorker = void Function(SendPort sendPort);

/// Ceiling on a single request.
///
/// Four minutes, and the number is not arbitrary: 白い熊 応用管理
/// abandons a job that has been silent and idle for **ten** minutes. A
/// guard set beyond that can never fire — the caller is killed first —
/// which is exactly what happened when this was 30 minutes. Every stall
/// then looked identical from outside: silence, then abandonment, and
/// never a word from us about which operation was stuck.
///
/// Four leaves room for a genuinely slow multi-gigabyte entry while
/// still reporting inside the window.
const Duration kDefaultRequestTimeout = Duration(minutes: 4);

/// Runs Zip work on a worker isolate and pairs replies to requests.
///
/// **Local change (2026-09-09).** Upstream spawns the worker with no
/// `onExit` or `onError` port and awaits every request on a bare
/// `Completer` with no timeout. If the worker dies — a native crash in
/// the zip library, an OOM, anything — no response is ever posted and
/// the caller's `await` never returns. There is no error and no
/// timeout: the isolate is simply gone and the future waits forever.
///
/// That is not theoretical. An automation export hung here for six and
/// a half hours mid-way through writing artifact file 2264 of 2265,
/// with every thread of the process in `S` and zero CPU, and would have
/// waited indefinitely.
///
/// So the worker is now spawned with both ports, and its death — or a
/// request outliving [requestTimeout] — completes every outstanding
/// request with a [ZipException] instead. Callers get a failure they
/// can report and retry rather than silence.
class IsolateManager<T> {
  final _receivePort = ReceivePort();
  final _exitPort = ReceivePort();
  final _errorPort = ReceivePort();
  final _sendPort = new Completer<SendPort>();
  final _requests = <int, Completer>{};
  final _timers = <int, Timer>{};
  var _requestId = 0;
  var _dead = false;
  var _quit = false;
  /// Why the worker stopped, so a later call reports the original cause
  /// rather than the bare "no longer running" guard it happens to hit.
  String? _deathReason;

  /// How long a single request may take before it is treated as dead.
  final Duration requestTimeout;

  IsolateManager(IsolateWorker worker,
      {this.requestTimeout = kDefaultRequestTimeout}) {
    _listenForWorkerMessages();
    _listenForWorkerDeath();
    Isolate.spawn(
      worker,
      _receivePort.sendPort,
      onExit: _exitPort.sendPort,
      onError: _errorPort.sendPort,
    );
  }

  Future<P> sendRequest<P>(T type, [dynamic param]) async {
    if (_dead) {
      throw ZipException(_deathReason ??
          'Zip worker isolate is no longer running');
    }
    final sendPort = await _sendPort.future;
    final request = IsolateRequest(++_requestId, type, param);
    final completer = Completer<P>();
    _requests[request.id] = completer;
    _timers[request.id] = Timer(requestTimeout, () {
      _fail(request.id,
          'Zip request $type timed out after ${requestTimeout.inMinutes} '
          'minutes');
    });
    sendPort.send(request);
    return completer.future;
  }

  /// The worker exited, or threw out of its top level. Either way no
  /// further replies are coming, so nothing may be left waiting.
  void _listenForWorkerDeath() {
    _exitPort.listen((_) {
      // close() makes the worker quit on purpose; that is teardown, not
      // a failure, and there is nothing left waiting by then.
      _failAll(_quit
          ? 'Zip worker isolate finished'
          : 'Zip worker isolate exited unexpectedly');
    });
    _errorPort.listen((message) {
      // onError delivers [error, stackTrace] as strings.
      final detail = message is List && message.isNotEmpty
          ? '${message.first}'
          : '$message';
      _failAll('Zip worker isolate crashed: $detail');
    });
  }

  void _fail(int id, String reason) {
    _timers.remove(id)?.cancel();
    final completer = _requests.remove(id);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(ZipException(reason));
    }
  }

  void _failAll(String reason) {
    _dead = true;
    _deathReason ??= reason;
    asyncZipDebugPrint?.call(reason);
    // A normal close exits the worker too, so only pending work is a
    // failure — an idle exit is just teardown.
    for (final id in _requests.keys.toList()) {
      _fail(id, reason);
    }
    if (!_sendPort.isCompleted) {
      _sendPort.completeError(ZipException(reason));
    }
  }

  void _listenForWorkerMessages() async {
    await for (final message in _receivePort) {
      if (message is SendPort) {
        _sendPort.complete(message);
      } else if (message is IsolateQuitMessage) {
        _quit = true;
        break;
      } else if (message is IsolateResponse) {
        _timers.remove(message.id)?.cancel();
        final completer = _requests[message.id];
        if (completer != null) {
          _requests.remove(message.id);
          if (message.error != null) {
            completer.completeError(ZipException(message.error!));
          } else {
            completer.complete(message.param);
          }
        }
      }
    }
    asyncZipDebugPrint?.call('Stopped listening for messages');
    // Closing the exit port below means onExit may never fire, so the
    // manager marks itself spent here rather than relying on it.
    _dead = true;
    _deathReason ??= 'Zip worker isolate stopped with work outstanding';
    for (final id in _requests.keys.toList()) {
      _fail(id, _deathReason!);
    }
    _receivePort.close();
    _exitPort.close();
    _errorPort.close();
  }
}

class IsolateRequest<T, P> {
  final int id;
  final T type;
  final P? param;

  IsolateRequest(this.id, this.type, [this.param]);
}

class IsolateResponse<P> {
  final int id;
  final P? param;
  final String? error;

  IsolateResponse(this.id, [this.param, this.error]);
}

class IsolateQuitMessage {}
