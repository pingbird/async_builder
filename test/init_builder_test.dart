import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('InitBuilder', () {
    testWidgets('Basic getter', (tester) async {
      var getterCount = 42;
      var disposerCount = 0;

      int getInt() => getterCount++;

      await tester.pumpWidget(buildFrame(InitBuilder<int>(
        getter: getInt,
        builder: (context, value) => Text('$value'),
        disposer: (e) => disposerCount += e,
      )));

      expect(tester.widget<Text>(findText).data, equals('42'));

      // Make sure getter is not called again on rebuild

      await tester.pumpWidget(buildFrame(InitBuilder<int>(
        getter: getInt,
        builder: (context, value) => Text('$value'),
        disposer: (e) => disposerCount += e,
      )));

      expect(tester.widget<Text>(findText).data, equals('42'));

      // Change getter, expect it to be called

      int getInt2() => getterCount++;

      await tester.pumpWidget(buildFrame(InitBuilder<int>(
        getter: getInt2,
        builder: (context, value) => Text('$value'),
        disposer: (e) => disposerCount += e,
      )));

      expect(tester.widget<Text>(findText).data, equals('43'));

      /// Make sure disposer works

      await tester.pumpWidget(const SizedBox());

      expect(disposerCount, equals(43));
    });

    testWidgets('Arg getter', (tester) async {
      var getterCount = 0;
      String? disposedValue;

      void disposer(String value) {
        expect(disposedValue, isNull);
        disposedValue = value;
      }

      String getString(String prefix, int offset) =>
          '$prefix${offset + getterCount++}';

      await tester.pumpWidget(buildFrame(InitBuilder.arg2<String, String, int>(
        getter: getString,
        arg1: 'foo',
        arg2: 42,
        builder: (context, value) => Text(value!),
        disposer: disposer,
      )));

      expect(tester.widget<Text>(findText).data, equals('foo42'));

      // Make sure getter is not called again on rebuild

      await tester.pumpWidget(buildFrame(InitBuilder.arg2<String, String, int>(
        getter: getString,
        arg1: 'foo',
        arg2: 42,
        builder: (context, value) => Text(value!),
        disposer: disposer,
      )));

      expect(tester.widget<Text>(findText).data, equals('foo42'));

      // Change arg, expect getter to be called

      await tester.pumpWidget(buildFrame(InitBuilder.arg2<String, String, int>(
        getter: getString,
        arg1: 'foobar',
        arg2: 42,
        builder: (context, value) => Text(value!),
        disposer: disposer,
      )));

      expect(tester.widget<Text>(findText).data, equals('foobar43'));

      /// Make sure disposer works

      await tester.pumpWidget(const SizedBox());

      expect(disposedValue, equals('foobar43'));
    });
  });
}
