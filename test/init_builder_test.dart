import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';

import 'common.dart';

void main() {
  group('InitBuilder', () {
    testWidgets('Basic getter', (tester) async {
      var getterCount = 42;

      int getInt() => getterCount++;

      await tester.pumpWidget(buildFrame(InitBuilder<int>(
        getter: getInt,
        builder: (context, value) => Text('$value'),
      )));

      expect(tester.widget<Text>(findText).data, equals('42'));

      // Make sure getter is not called again on rebuild

      await tester.pumpWidget(buildFrame(InitBuilder<int>(
        getter: getInt,
        builder: (context, value) => Text('$value'),
      )));

      expect(tester.widget<Text>(findText).data, equals('42'));

      // Change getter, expect it to be called

      int getInt2() => getterCount++;

      await tester.pumpWidget(buildFrame(InitBuilder<int>(
        getter: getInt2,
        builder: (context, value) => Text('$value'),
      )));

      expect(tester.widget<Text>(findText).data, equals('43'));
    });

    testWidgets('Arg getter', (tester) async {
      var getterCount = 0;

      String getString(String prefix, int offset) =>
        '$prefix${offset + getterCount++}';

      await tester.pumpWidget(buildFrame(InitBuilder.arg2<String, String, int>(
        getter: getString,
        arg1: 'foo',
        arg2: 42,
        builder: (context, value) => Text(value),
      )));

      expect(tester.widget<Text>(findText).data, equals('foo42'));

      // Make sure getter is not called again on rebuild

      await tester.pumpWidget(buildFrame(InitBuilder.arg2<String, String, int>(
        getter: getString,
        arg1: 'foo',
        arg2: 42,
        builder: (context, value) => Text(value),
      )));

      expect(tester.widget<Text>(findText).data, equals('foo42'));

      // Change arg, expect getter to be called

      await tester.pumpWidget(buildFrame(InitBuilder.arg2<String, String, int>(
        getter: getString,
        arg1: 'foobar',
        arg2: 42,
        builder: (context, value) => Text(value),
      )));

      expect(tester.widget<Text>(findText).data, equals('foobar43'));
    });
  });
}
