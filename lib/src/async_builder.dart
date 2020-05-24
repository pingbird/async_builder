import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

typedef ValueBuilderFn<T> = Widget Function(BuildContext context, T value);
typedef ErrorBuilderFn = Widget Function(BuildContext context, Object error, StackTrace stackTrace);
typedef ErrorReporterFn = void Function(FlutterErrorDetails details);

class AsyncBuilder<T> extends StatefulWidget {
  final WidgetBuilder waiting;
  final ValueBuilderFn<T> builder;
  final ErrorBuilderFn error;
  final ValueBuilderFn<T> closed;
  final Future<T> future;
  final Stream<T> stream;
  final T initial;
  final bool silent;
  final bool pause;
  final ErrorReporterFn reportError;

  AsyncBuilder({
    this.waiting,
    @required this.builder,
    this.error,
    this.closed,
    this.future,
    this.stream,
    this.initial,
    this.pause = false,
    bool silent,
    ErrorReporterFn reportError,
  }) : silent = silent ?? error != null,
       reportError = reportError ?? FlutterError.reportError,
       assert(builder != null),
       assert((future != null) != (stream != null), 'AsyncBuilder should be given exactly one stream or future'),
       assert(future == null || closed == null, 'AsyncBuilder should not be given both a future and closed builder'),
       assert(pause != null);

  @override
  State<StatefulWidget> createState() => _AsyncBuilderState();
}

class _AsyncBuilderState extends State<AsyncBuilder> {
  Object _lastValue;
  Object _lastError;
  StackTrace _lastStackTrace;
  bool _hasFired = false;
  bool _isClosed = false;
  StreamSubscription _subscription;

  void _cancel() {
    _lastValue = null;
    _lastError = null;
    _lastStackTrace = null;
    _hasFired = false;
    _isClosed = false;
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _lastError = error;
    _lastStackTrace = stackTrace;
    if (widget.error != null) {
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
    var future = widget.future;
    future.then((value) {
      if (future != widget.future) return; // Skip if future changed
      setState(() {
        _lastValue = value;
        _hasFired = true;
      });
    }, onError: _handleError);
  }

  void _updateStream() {
    if (_subscription != null) {
      if (widget.pause && !_subscription.isPaused) {
        _subscription.pause();
      } else if (!widget.pause && _subscription.isPaused) {
        _subscription.resume();
      }
    }
  }

  void _initStream() {
    _cancel();
    var stream = widget.stream;
    if (stream != null) {
      var skipFirst = false;
      if (stream is ValueStream && stream.hasValue) {
        skipFirst = true;
        _hasFired = true;
        _lastValue = stream.value;
      }
      _subscription = stream.listen(
        (event) {
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
          setState(() {
            _isClosed = true;
          });
        },
        onError: _handleError,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.future != null) {
      _initFuture();
    } else {
      _initStream();
    }

    _updateStream();
  }

  @override
  void didUpdateWidget(AsyncBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.future != null && widget.future != oldWidget.future) {
      _initFuture();
    } else if (widget.stream != oldWidget.stream) {
      _initStream();
    }

    _updateStream();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastError != null && widget.error != null) {
      return widget.error(context, _lastError, _lastStackTrace);
    }

    if (_isClosed && widget.closed != null) {
      return widget.closed(context, _hasFired ? _lastValue : widget.initial);
    }

    if (!_hasFired && widget.waiting != null) {
      return widget.waiting(context);
    }

    return widget.builder(context, _hasFired ? _lastValue : widget.initial);
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
