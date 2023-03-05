import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'common.dart';

/// A Widget that builds depending on the state of a [Future] or [Stream].
///
/// AsyncBuilder must be given either a [future] or [stream], not both.
///
/// This is similar to [FutureBuilder] and [StreamBuilder] but accepts separate
/// callbacks for each state. Just like the built in builders, the [future] or
/// [stream] should not be created at build time because it would restart
/// every time the ancestor is rebuilt.
///
/// If [stream] is an rxdart [ValueStream] with an existing value, that value
/// will be available on the first build. Otherwise when no data is available
/// this builds either [waiting] if provided, or [builder] with a null value.
///
/// If [initial] is provided, it is used in place of the value before one is
/// available.
///
/// If [retain] is true, the current value is retained when the [stream] or
/// [future] instances change. Otherwise when [retain] is false or omitted, the
/// value is reset.
///
/// If the asynchronous operation completes with an error this builds [error].
/// If [error] is not provided [reportError] is called with the [FlutterErrorDetails].
///
/// When [stream] closes and [closed] is provided, [closed] is built with the
/// last value emitted.
///
/// If [pause] is true, the [StreamSubscription] used to listen to [stream] is
/// paused.
///
/// Example using [future]:
///
/// ```dart
/// AsyncBuilder<String>(
///   future: myFuture,
///   waiting: (context) => Text('Loading...'),
///   builder: (context, value) => Text('$value'),
///   error: (context, error, stackTrace) => Text('Error! $error'),
/// )
/// ```
///
/// Example using [stream]:
///
/// ```dart
/// AsyncBuilder<String>(
///   stream: myStream,
///   waiting: (context) => Text('Loading...'),
///   builder: (context, value) => Text('$value'),
///   error: (context, error, stackTrace) => Text('Error! $error'),
///   closed: (context, value) => Text('$value (closed)'),
/// )
/// ```
class AsyncBuilder<T> extends StatefulWidget {
  /// The builder that should be called when no data is available.
  final WidgetBuilder? waiting;

  /// The default value builder.
  final ValueBuilderFn<T> builder;

  /// The builder that should be called when an error was thrown by the future
  /// or stream.
  final ErrorBuilderFn? error;

  /// The builder that should be called when the stream is closed.
  final ValueBuilderFn<T>? closed;

  /// If provided, this is the future the widget listens to.
  final Future<T>? future;

  /// If provided, this is the stream the widget listens to.
  final Stream<T>? stream;

  /// The initial value used before one is available.
  final T? initial;

  /// Whether or not the current value should be retained when the [stream] or
  /// [future] instances change.
  final bool retain;

  /// Whether or not to suppress printing errors to the console.
  final bool silent;

  /// Whether or not to pause the stream subscription.
  final bool pause;

  /// If provided, overrides the function that prints errors to the console.
  final ErrorReporterFn reportError;

  /// Whether or not we should send a keep alive
  /// notification with [AutomaticKeepAliveClientMixin].
  final bool keepAlive;

  /// Creates a widget that builds depending on the state of a [Future] or [Stream].
  const AsyncBuilder({
    Key? key,
    this.waiting,
    required this.builder,
    this.error,
    this.closed,
    this.future,
    this.stream,
    this.initial,
    this.retain = false,
    this.pause = false,
    bool? silent,
    this.keepAlive = false,
    ErrorReporterFn? reportError,
  })  : silent = silent ?? error != null,
        reportError = reportError ?? FlutterError.reportError,
        assert(!((future != null) && (stream != null)),
            'AsyncBuilder should be given either a stream or future'),
        assert(future == null || closed == null,
            'AsyncBuilder should not be given both a future and closed builder'),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _AsyncBuilderState<T>();
}

class _AsyncBuilderState<T> extends State<AsyncBuilder<T>>
    with AutomaticKeepAliveClientMixin {
  T? _lastValue;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _hasFired = false;
  bool _isClosed = false;
  StreamSubscription<T>? _subscription;

  void _cancel() {
    if (!widget.retain) {
      _lastValue = null;
      _lastError = null;
      _lastStackTrace = null;
      _hasFired = false;
    }
    _isClosed = false;
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    _lastError = error;
    _lastStackTrace = stackTrace;
    if (widget.error != null && mounted) {
      setState(() {});
    }
    if (!widget.silent) {
      widget.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace ?? StackTrace.empty,
        context: ErrorDescription('While updating AsyncBuilder'),
      ));
    }
  }

  void _initFuture() {
    _cancel();
    final Future<T> future = widget.future!;
    future.then((T value) {
      if (future != widget.future || !mounted) return; // Skip if future changed
      setState(() {
        _lastValue = value;
        _hasFired = true;
      });
    }, onError: _handleError);
  }

  void _updatePause() {
    if (_subscription != null) {
      if (widget.pause && !_subscription!.isPaused) {
        _subscription!.pause();
      } else if (!widget.pause && _subscription!.isPaused) {
        _subscription!.resume();
      }
    }
  }

  void _initStream() {
    _cancel();
    final Stream<T> stream = widget.stream!;
    var skipFirst = false;
    if (stream is ValueStream<T> && stream.hasValue) {
      skipFirst = true;
      _hasFired = true;
      _lastValue = stream.value;
    }
    _subscription = stream.listen(
      (T event) {
        if (skipFirst) {
          skipFirst = false;
          return;
        }
        setState(() {
          _hasFired = true;
          _lastValue = event;
        });
      },
      onDone: () {
        _isClosed = true;
        if (widget.closed != null) {
          setState(() {});
        }
      },
      onError: _handleError,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.future != null) {
      _initFuture();
    } else if (widget.stream != null) {
      _initStream();
      _updatePause();
    }
  }

  @override
  void didUpdateWidget(AsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.future != null) {
      if (widget.future != oldWidget.future) _initFuture();
    } else if (widget.stream != null) {
      if (widget.stream != oldWidget.stream) _initStream();
    } else {
      _cancel();
    }

    _updatePause();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_lastError != null && widget.error != null) {
      return widget.error!(context, _lastError!, _lastStackTrace);
    }

    if (_isClosed && widget.closed != null) {
      return widget.closed!(context, _hasFired ? _lastValue : widget.initial);
    }

    if (!_hasFired && widget.waiting != null) {
      return widget.waiting!(context);
    }

    return widget.builder(context, _hasFired ? _lastValue : widget.initial);
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
