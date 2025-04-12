import 'package:architecture/architecture.dart';
import 'package:fl_observable/fl_observable.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends RdView<MyHomePage> {
  const MyHomePage({super.key});

  MyHomePageController get _controller => bind(
        (_) => MyHomePageController(),
        // If you want to use the same type multiple times, you need to use tags
        tag: 'Optional',
        onViewUpdated: (MyHomePage oldView, MyHomePage newView) {
          // when the Widget receives a new configuration, this method is called.
          // if you return a new instance of the controller, the old instance will be disposed
          // and the new instance will be used.
          // if you return null, the old instance will be used, but you can update the state of the controller.
          return null;
        },
      );

  @override
  void onInit() {
    print('This is called, when the element is mounted');
    super.onInit();
  }

  @override
  void onDisposed() {
    print('This is called, when the element is disposed');
    super.onDisposed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('StatelessWidget with state'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            _controller.rxCounter.build(builder: (context, counter, _) {
              return Text(
                '$counter',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.onIncrementPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyHomePageController extends Controller {
  late final RxInt _rxCounter = RxInt(0);
  late final Observable<int> rxCounter = _rxCounter;

  void onIncrementPressed() {
    _rxCounter.value++;
  }
}
