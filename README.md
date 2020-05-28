# async_builder - Improved Future and Stream builder for Flutter.

This package provides `AsyncBuilder`, a widget similar to StreamBuilder / FutureBuilder which is designed to reduce
boilerplate and improve error handling.

It also provides `InitBuilder`, which makes it easier to start async tasks safely.

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

## AsyncBuilder Examples

### Future

```dart
AsyncBuilder<String>(
  future: myFuture,
  waiting: (context) => Text('Loading...'),
  builder: (context, value) => Text('$value'),
  error: (context, error, stackTrace) => Text('Error! $error'),
)
```

### Stream

```dart
AsyncBuilder<String>(
  stream: myStream,
  waiting: (context) => Text('Loading...'),
  builder: (context, value) => Text('$value'),
  error: (context, error, stackTrace) => Text('Error! $error'),
  closed: (context, value) => Text('$value (closed)'),
)
```

Note that you cannot provide both a stream and future.

## AsyncBuilder Features

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

## InitBuilder

InitBuilder is a widget that initializes a value only when its configuration changes, this is extremely useful because
it allows you to safely start async tasks without making a whole new StatefulWidget.

The basic usage of this widget is to make a separate function outside of build that starts the task and then pass it to
InitBuilder, for example:

```dart
static Future<int> getNumber() async => ...;

build(context) => InitBuilder<int>(
  getter: getNumber,
  builder: (context, future) => AsyncBuilder<int>(
    future: future,
    builder: (context, value) => Text('$value'),
  ),
);
```

In this case, getNumber is only ever called on the first build.

You may also want to pass arguments to the getter, for example to query shared preferences:

```dart
final String prefsKey;

build(context) => InitBuilder.arg<String, String>(
  getter: sharedPrefs.getString,
  arg: prefsKey,
  builder: (context, future) => AsyncBuilder<String>(
    future: future,
    builder: (context, value) => Text('$value'),
  ),
);
```

The alternate constructors `InitBuilder.arg` to `InitBuilder.arg7` can be used to pass arguments to the `getter`, these
will re-initialize the value if and only if either `getter` or the arguments change.