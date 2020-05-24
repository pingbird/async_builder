# async_builder - Improved Future and Stream builder for Flutter.

This package provides AsyncBuilder, a widget similar to StreamBuilder / FutureBuilder which is designed to reduce
boilerplate and improve error handling.

## How to use

**1. Add to dependencies**
```
dependencies:
  async_builder: ^1.0.0
```

**2. Import**
```
import 'package:async_builder/async_builder.dart';
```

## Examples

### Future

```dart
AsyncBuilder<String>(
  future: myFuture,
  waiting: (context, value) => Text('Loading...'),
  builder: (context, value) => Text('$value'),
  error: (context, error, stackTrace) => Text('Error! $error'),
)
```

### Stream

```dart
AsyncBuilder<String>(
  stream: myStream,
  waiting: (context, value) => Text('Loading...'),
  builder: (context, value) => Text('$value'),
  error: (context, error, stackTrace) => Text('Error! $error'),
  closed: (context, value) => Text('$value (closed)'),
)
```

## Features

### Separate builders

Instead of a single builder, AsyncBuilder allows you to specify separate builders depending on the state of the
asynchronous operation:

* `waiting(context)` - Called when no events have fired yet.
* `builder(context, value)` - Required. Called when a value is available.
* `error(context, error, stackTrace)` - Called if there was an error.
* `closed(context, value)` - Called if the stream was closed.

If any of these are not provided then it defaults to calling `builder` (potentially with a null `value`).

### Error handling

AsyncBuilder does not silently ignore errors by default.

If an exception occurs and `error` is provided, the widget will rebuild and call that builder.
Otherwise, if `error` is not provided and `silent` not true then the exception and stack trace will be printed to
console (default behavior).

### Initial value

If `initial` is provided, it is used in place of the value before one is available.

### RxDart ValueStream

If `stream` is a ValueStream (BehaviorSubject) holding an existing value, that value will be available immediately on
first build.

### Stream pausing

The `StreamSubscription` for this widget can be paused with the `pause` parameter, this is useful if you want to notify
the upstream `StreamController` that you don't need updates.