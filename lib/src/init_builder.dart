import 'package:flutter/widgets.dart';
import 'common.dart';

abstract class InitBuilder<T> extends StatefulWidget {
  final ValueBuilderFn<T> builder;

  factory InitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required ValueGetter<T> getter,
  }) => _GetterInitBuilder<T>(key: key, builder: builder, getter: getter);

  const InitBuilder.base({Key key, @required this.builder}) : super(key: key);

  static InitBuilder<T> arg<T, A>({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required A arg,
    @required T Function(A) getter,
  }) => _ArgInitBuilder<T, A>(
    key: key,
    builder: builder,
    arg: arg,
    getter: getter,
  );

  static InitBuilder<T> arg2<T, A1, A2>({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required A1 arg1,
    @required A2 arg2,
    @required T Function(A1, A2) getter,
  }) => _Arg2InitBuilder<T, A1, A2>(
    key: key,
    builder: builder,
    arg1: arg1,
    arg2: arg2,
    getter: getter,
  );

  static InitBuilder<T> arg3<T, A1, A2, A3>({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required A1 arg1,
    @required A2 arg2,
    @required A3 arg3,
    @required T Function(A1, A2, A3) getter,
  }) => _Arg3InitBuilder<T, A1, A2, A3>(
    key: key,
    builder: builder,
    arg1: arg1,
    arg2: arg2,
    arg3: arg3,
    getter: getter,
  );

  static InitBuilder<T> arg4<T, A1, A2, A3, A4>({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required A1 arg1,
    @required A2 arg2,
    @required A3 arg3,
    @required A4 arg4,
    @required T Function(A1, A2, A3, A4) getter,
  }) => _Arg4InitBuilder<T, A1, A2, A3, A4>(
    key: key,
    builder: builder,
    arg1: arg1,
    arg2: arg2,
    arg3: arg3,
    arg4: arg4,
    getter: getter,
  );

  static InitBuilder<T> arg5<T, A1, A2, A3, A4, A5>({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required A1 arg1,
    @required A2 arg2,
    @required A3 arg3,
    @required A4 arg4,
    @required A5 arg5,
    @required T Function(A1, A2, A3, A4, A5) getter,
  }) => _Arg5InitBuilder<T, A1, A2, A3, A4, A5>(
    key: key,
    builder: builder,
    arg1: arg1,
    arg2: arg2,
    arg3: arg3,
    arg4: arg4,
    arg5: arg5,
    getter: getter,
  );

  static InitBuilder<T> arg6<T, A1, A2, A3, A4, A5, A6>({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required A1 arg1,
    @required A2 arg2,
    @required A3 arg3,
    @required A4 arg4,
    @required A5 arg5,
    @required A6 arg6,
    @required T Function(A1, A2, A3, A4, A5, A6) getter,
  }) => _Arg6InitBuilder<T, A1, A2, A3, A4, A5, A6>(
    key: key,
    builder: builder,
    arg1: arg1,
    arg2: arg2,
    arg3: arg3,
    arg4: arg4,
    arg5: arg5,
    arg6: arg6,
    getter: getter,
  );

  static InitBuilder<T> arg7<T, A1, A2, A3, A4, A5, A6, A7>({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required A1 arg1,
    @required A2 arg2,
    @required A3 arg3,
    @required A4 arg4,
    @required A5 arg5,
    @required A6 arg6,
    @required A7 arg7,
    @required T Function(A1, A2, A3, A4, A5, A6, A7) getter,
  }) => _Arg7InitBuilder<T, A1, A2, A3, A4, A5, A6, A7>(
    key: key,
    builder: builder,
    arg1: arg1,
    arg2: arg2,
    arg3: arg3,
    arg4: arg4,
    arg5: arg5,
    arg6: arg6,
    arg7: arg7,
    getter: getter,
  );

  T initValue();
  bool shouldInit(covariant InitBuilder<T> other);

  @override
  _InitBuilderState<T> createState() => _InitBuilderState<T>();
}

class _GetterInitBuilder<T> extends InitBuilder<T> {
  final ValueGetter<T> getter;

  const _GetterInitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter();

  @override
  bool shouldInit(_GetterInitBuilder<T> other) =>
      getter != other.getter;
}

class _ArgInitBuilder<T, A> extends InitBuilder<T> {
  final A arg;
  final T Function(A) getter;

  const _ArgInitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.arg,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter(arg);

  @override
  bool shouldInit(_ArgInitBuilder<T, A> other) =>
    arg != other.arg ||
    getter != other.getter;
}

class _Arg2InitBuilder<T, A1, A2> extends InitBuilder<T> {
  final A1 arg1;
  final A2 arg2;
  final T Function(A1, A2) getter;

  const _Arg2InitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.arg1,
    @required this.arg2,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter(arg1, arg2);

  @override
  bool shouldInit(_Arg2InitBuilder<T, A1, A2> other) =>
    arg1 != other.arg1 ||
    arg2 != other.arg2 ||
    getter != other.getter;
}

class _Arg3InitBuilder<T, A1, A2, A3> extends InitBuilder<T> {
  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final T Function(A1, A2, A3) getter;

  const _Arg3InitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.arg1,
    @required this.arg2,
    @required this.arg3,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter(arg1, arg2, arg3);

  @override
  bool shouldInit(_Arg3InitBuilder<T, A1, A2, A3> other) =>
    arg1 != other.arg1 ||
    arg2 != other.arg2 ||
    arg3 != other.arg3 ||
    getter != other.getter;
}

class _Arg4InitBuilder<T, A1, A2, A3, A4> extends InitBuilder<T> {
  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final T Function(A1, A2, A3, A4) getter;

  const _Arg4InitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.arg1,
    @required this.arg2,
    @required this.arg3,
    @required this.arg4,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4);

  @override
  bool shouldInit(_Arg4InitBuilder<T, A1, A2, A3, A4> other) =>
    arg1 != other.arg1 ||
    arg2 != other.arg2 ||
    arg3 != other.arg3 ||
    arg4 != other.arg4 ||
    getter != other.getter;
}

class _Arg5InitBuilder<T, A1, A2, A3, A4, A5> extends InitBuilder<T> {
  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final A5 arg5;
  final T Function(A1, A2, A3, A4, A5) getter;

  const _Arg5InitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.arg1,
    @required this.arg2,
    @required this.arg3,
    @required this.arg4,
    @required this.arg5,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4, arg5);

  @override
  bool shouldInit(_Arg5InitBuilder<T, A1, A2, A3, A4, A5> other) =>
    arg1 != other.arg1 ||
    arg2 != other.arg2 ||
    arg3 != other.arg3 ||
    arg4 != other.arg4 ||
    arg5 != other.arg5 ||
    getter != other.getter;
}

class _Arg6InitBuilder<T, A1, A2, A3, A4, A5, A6> extends InitBuilder<T> {
  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final A5 arg5;
  final A6 arg6;
  final T Function(A1, A2, A3, A4, A5, A6) getter;

  const _Arg6InitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.arg1,
    @required this.arg2,
    @required this.arg3,
    @required this.arg4,
    @required this.arg5,
    @required this.arg6,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4, arg5, arg6);

  @override
  bool shouldInit(_Arg6InitBuilder<T, A1, A2, A3, A4, A5, A6> other) =>
    arg1 != other.arg1 ||
    arg2 != other.arg2 ||
    arg3 != other.arg3 ||
    arg4 != other.arg4 ||
    arg5 != other.arg5 ||
    arg6 != other.arg6 ||
    getter != other.getter;
}

class _Arg7InitBuilder<T, A1, A2, A3, A4, A5, A6, A7> extends InitBuilder<T> {
  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final A5 arg5;
  final A6 arg6;
  final A7 arg7;
  final T Function(A1, A2, A3, A4, A5, A6, A7) getter;

  const _Arg7InitBuilder({
    Key key,
    @required ValueBuilderFn<T> builder,
    @required this.arg1,
    @required this.arg2,
    @required this.arg3,
    @required this.arg4,
    @required this.arg5,
    @required this.arg6,
    @required this.arg7,
    @required this.getter,
  }) : super.base(key: key, builder: builder);

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4, arg5, arg6, arg7);

  @override
  bool shouldInit(_Arg7InitBuilder<T, A1, A2, A3, A4, A5, A6, A7> other) =>
    arg1 != other.arg1 ||
    arg2 != other.arg2 ||
    arg3 != other.arg3 ||
    arg4 != other.arg4 ||
    arg5 != other.arg5 ||
    arg6 != other.arg6 ||
    arg7 != other.arg7 ||
    getter != other.getter;
}

class _InitBuilderState<T> extends State<InitBuilder<T>> {
  T value;

  @override
  void initState() {
    super.initState();
    value = widget.initValue();
  }

  @override
  void didUpdateWidget(InitBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldInit(oldWidget)) {
      value = widget.initValue();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, value);
}
