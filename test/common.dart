import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
