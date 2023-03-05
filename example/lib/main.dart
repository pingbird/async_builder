import 'dart:async';
import 'dart:math';

import 'package:async_builder/async_builder.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'AsyncBuilder Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          AsyncTestChild1(),
          AsyncTestChild2(),
          AsyncTestChild3(),
          AsyncTestChild4(),
        ],
      ),
      backgroundColor: Colors.blueGrey.shade600,
    );
  }
}

class AsyncTestChild1 extends StatefulWidget {
  @override
  _AsyncTestChild1State createState() => _AsyncTestChild1State();
}

class _AsyncTestChild1State extends State<AsyncTestChild1> {
  Future<int>? randomNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return TestCard(
      title: 'Random Numbers - Future',
      desc:
          'This example completes a future with a random number after 2 seconds.',
      child: Row(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: const Text('Generate'),
          onPressed: () {
            setState(() {
              randomNumber = Future.delayed(
                  const Duration(seconds: 2), () => Random().nextInt(100));
            });
          },
        ),
        const Padding(padding: EdgeInsets.only(right: 16)),
        if (randomNumber != null)
          AsyncBuilder<int>(
            waiting: (context) => const CircularProgressIndicator(),
            builder: (context, i) => Text('$i', style: textTheme.titleLarge),
            future: randomNumber,
          ),
      ]),
    );
  }
}

class AsyncTestChild2 extends StatefulWidget {
  @override
  _AsyncTestChild2State createState() => _AsyncTestChild2State();
}

class _AsyncTestChild2State extends State<AsyncTestChild2> {
  StreamController<int>? randomNumber;

  void initController() {
    setState(() {
      randomNumber?.close();
      randomNumber = StreamController<int>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return TestCard(
      title: 'Random Numbers - Stream',
      desc: 'This example adds a random number to a stream after 1 second.',
      child: Row(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: const Text('Reset'),
          onPressed: randomNumber == null
              ? null
              : () {
                  setState(() {
                    randomNumber = null;
                  });
                },
        ),
        const Padding(padding: EdgeInsets.only(right: 8)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: const Text('Add'),
          onPressed: () async {
            if (randomNumber == null) initController();
            final ctrl = randomNumber;
            await Future<void>.delayed(const Duration(seconds: 1));
            ctrl!.add(Random().nextInt(100));
          },
        ),
        const Padding(padding: EdgeInsets.only(right: 16)),
        if (randomNumber != null)
          AsyncBuilder<int>(
            waiting: (context) => const CircularProgressIndicator(),
            builder: (context, i) => Text('$i', style: textTheme.titleLarge),
            stream: randomNumber!.stream,
          ),
      ]),
    );
  }
}

class AsyncTestChild3 extends StatefulWidget {
  @override
  _AsyncTestChild3State createState() => _AsyncTestChild3State();
}

class _AsyncTestChild3State extends State<AsyncTestChild3> {
  StreamController<int>? randomNumber;

  void initController() {
    setState(() {
      randomNumber?.close();
      final ctrl = StreamController<int>();
      randomNumber = ctrl;
      final timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        ctrl.add(Random().nextInt(100));
      });
      ctrl.onCancel = timer.cancel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return TestCard(
      title: 'Random Numbers - Closing',
      desc:
          'This example continuously adds numbers to a stream until it is closed.',
      child: Row(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: Text(randomNumber == null ? 'Start' : 'Restart'),
          onPressed: initController,
        ),
        const Padding(padding: EdgeInsets.only(right: 8)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: const Text('Close'),
          onPressed: randomNumber == null || randomNumber!.isClosed
              ? null
              : () {
                  setState(() {
                    randomNumber!.close();
                  });
                },
        ),
        const Padding(padding: EdgeInsets.only(right: 16)),
        if (randomNumber != null)
          AsyncBuilder<int>(
            waiting: (context) => const CircularProgressIndicator(),
            builder: (context, i) => Text('$i', style: textTheme.titleLarge),
            closed: (context, i) =>
                Text('$i (Closed)', style: textTheme.titleLarge),
            stream: randomNumber!.stream,
          ),
      ]),
    );
  }
}

class AsyncTestChild4 extends StatefulWidget {
  @override
  _AsyncTestChild4State createState() => _AsyncTestChild4State();
}

class _AsyncTestChild4State extends State<AsyncTestChild4> {
  StreamController<int>? randomNumber;
  var pause = false;

  void initController() {
    setState(() {
      randomNumber?.close();

      final ctrl = StreamController<int>();
      randomNumber = ctrl;

      late Timer timer;
      void start() {
        timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
          ctrl.add(Random().nextInt(100));
        });
      }

      ctrl.onPause = () => timer.cancel();
      ctrl.onCancel = () => timer.cancel();
      ctrl.onResume = start;

      start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return TestCard(
      title: 'Random Numbers - Pausing',
      desc:
          'This example continuously adds numbers to a stream but allows the subscription to be paused.',
      child: Row(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: Text(randomNumber == null ? 'Start' : 'Restart'),
          onPressed: initController,
        ),
        const Padding(padding: EdgeInsets.only(right: 16)),
        Text('Pause', style: textTheme.titleSmall),
        Switch(
            value: pause,
            onChanged: (b) {
              setState(() {
                pause = b;
              });
            },
            activeColor: Colors.blue),
        const Padding(padding: EdgeInsets.only(right: 16)),
        if (randomNumber != null)
          AsyncBuilder<int>(
            waiting: (context) => const CircularProgressIndicator(),
            builder: (context, i) => Text('$i', style: textTheme.titleLarge),
            stream: randomNumber!.stream,
            pause: pause,
          ),
      ]),
    );
  }
}

class TestCard extends StatelessWidget {
  final String title;
  final String desc;
  final Widget child;

  const TestCard({
    required this.title,
    required this.desc,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                child: Text(title, style: textTheme.titleLarge),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              const Divider(),
              Text(desc, style: textTheme.titleMedium),
              const Padding(padding: EdgeInsets.only(bottom: 16)),
              child,
            ],
          )),
    );
  }
}
