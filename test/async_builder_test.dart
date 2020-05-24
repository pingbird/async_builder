import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:async_builder/async_builder.dart';
import 'package:rxdart/rxdart.dart';

final findText = find.byType(Text);

Widget buildFrame(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

final reportedErrors = <FlutterErrorDetails>[];

void reportError(FlutterErrorDetails details) {
  reportedErrors.add(details);
}

void main() {
  group('AsyncBuilder', () {
    testWidgets('Stream', (tester) async {
      reportedErrors.clear();
      final ctrl = StreamController<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        waiting: (context) => Text('waiting'),
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('waiting'));

      // Remove waiting builder

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('null'));

      // Add initial value

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        initial: 'foo',
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('foo'));

      // Add events

      ctrl.add('bar');
      await tester.pump(Duration.zero);
      expect(tester.widget<Text>(findText).data, equals('bar'));

      ctrl.add('potato');
      await tester.pump(Duration.zero);
      expect(tester.widget<Text>(findText).data, equals('potato'));

      // Add error

      expect(reportedErrors, isEmpty);
      ctrl.addError('Test error message', StackTrace.current);

      await tester.pump(Duration.zero);

      expect(reportedErrors.single.exception, equals('Test error message'));
      reportedErrors.clear();

      // Error builder

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        initial: 'foo',
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        error: (context, error, stackTrace) => Text('$error'),
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('Test error message'));

      // Stream closed

      ctrl.close();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        initial: 'foo',
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        closed: (context, value) => Text('Closed $value'),
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('Closed potato'));
      expect(reportedErrors, isEmpty);
    });

    testWidgets('Stops listening when disposed', (tester) async {
      reportedErrors.clear();
      final ctrl = StreamController<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        reportError: reportError,
      )));

      expect(ctrl.hasListener, isTrue);

      await tester.pumpWidget(const SizedBox());

      expect(ctrl.hasListener, isFalse);
      ctrl.close();
    });

    testWidgets('Stops listening when replaced', (tester) async {
      reportedErrors.clear();
      final ctrl = StreamController<String>();
      final ctrl2 = StreamController<String>();

      // Listen to ctrl

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        reportError: reportError,
      )));

      expect(ctrl.hasListener, isTrue);

      // Switch stream to ctrl2

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        stream: ctrl2.stream,
        reportError: reportError,
      )));

      expect(ctrl.hasListener, isFalse);
      expect(ctrl2.hasListener, isTrue);

      // Switch to future

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        future: Future.value('foo'),
        reportError: reportError,
      )));

      expect(ctrl2.hasListener, isFalse);

      await tester.pump(Duration.zero);
      expect(tester.widget<Text>(findText).data, equals('foo'));

      ctrl.close();
      ctrl2.close();
    });

    testWidgets('Future', (tester) async {
      reportedErrors.clear();
      final ctrl = Completer<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        initial: 'waiting',
        builder: (context, value) => Text('$value'),
        future: ctrl.future,
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('waiting'));

      // Complete future

      ctrl.complete('foo');

      await tester.pump(Duration.zero);
      expect(tester.widget<Text>(findText).data, equals('foo'));
    });

    testWidgets('Future error', (tester) async {
      reportedErrors.clear();
      final ctrl = Completer<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        initial: 'waiting',
        builder: (context, value) => Text('$value'),
        future: ctrl.future,
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('waiting'));

      // Complete future

      ctrl.completeError('Test error message');

      await tester.pump(Duration.zero);

      expect(reportedErrors.single.exception, equals('Test error message'));
      reportedErrors.clear();

      // Error builder

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        future: ctrl.future,
        error: (context, error, stackTrace) => Text('$error'),
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('Test error message'));
      expect(reportedErrors, isEmpty);
    });

    testWidgets('SynchronousFuture', (tester) async {
      reportedErrors.clear();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        initial: 'waiting',
        builder: (context, value) => Text('$value'),
        future: SynchronousFuture('foo'),
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('foo'));
      await tester.pump(Duration.zero);
      expect(tester.widget<Text>(findText).data, equals('foo'));
      expect(reportedErrors, isEmpty);
    });

    testWidgets('Future complete after dispose', (tester) async {
      reportedErrors.clear();
      final ctrl = Completer<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        future: ctrl.future,
        reportError: reportError,
      )));

      await tester.pumpWidget(SizedBox());

      ctrl.complete('foo');

      await tester.pump(Duration.zero);
      expect(reportedErrors, isEmpty);
    });

    testWidgets('Future errors after dispose', (tester) async {
      reportedErrors.clear();
      final ctrl = Completer<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        future: ctrl.future,
        reportError: reportError,
      )));

      await tester.pumpWidget(SizedBox());

      ctrl.completeError('Test error message');

      await tester.pump(Duration.zero);

      expect(reportedErrors.single.exception, equals('Test error message'));
      reportedErrors.clear();
    });

    testWidgets('Future errors after dispose with error builder', (tester) async {
      reportedErrors.clear();
      final ctrl = Completer<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        error: (context, error, stackTrace) => Text('$error'),
        future: ctrl.future,
        reportError: reportError,
      )));

      await tester.pumpWidget(SizedBox());

      ctrl.completeError('Test error message');

      await tester.pump(Duration.zero);

      expect(reportedErrors, isEmpty);
    });

    testWidgets('BehaviorSubject', (tester) async {
      reportedErrors.clear();
      final ctrl = BehaviorSubject<String>();

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        initial: 'waiting',
        builder: (context, value) => Text('$value'),
        stream: ctrl,
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('waiting'));

      ctrl.add('foo');

      await tester.pump(Duration.zero);
      expect(tester.widget<Text>(findText).data, equals('foo'));

      // Remove AsyncBuilder

      await tester.pumpWidget(const SizedBox());
      expect(ctrl.hasListener, isFalse);

      // Use ValueStream with existing value

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        stream: ctrl,
        reportError: reportError,
      )));

      expect(tester.widget<Text>(findText).data, equals('foo'));

      ctrl.add('bar');

      await tester.pump(Duration.zero);
      expect(tester.widget<Text>(findText).data, equals('bar'));

      ctrl.close();
      expect(reportedErrors, isEmpty);
    });

    testWidgets('Pausing', (tester) async {
      reportedErrors.clear();
      var paused = false;

      final ctrl = StreamController<String>(
        onPause: () => paused = true,
        onResume: () => paused = false,
      );

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        reportError: reportError,
        pause: true,
      )));

      expect(paused, isTrue);

      await tester.pumpWidget(buildFrame(AsyncBuilder(
        builder: (context, value) => Text('$value'),
        stream: ctrl.stream,
        reportError: reportError,
        pause: false,
      )));

      expect(paused, isFalse);
      ctrl.close();
      expect(reportedErrors, isEmpty);
    });
  });
}
