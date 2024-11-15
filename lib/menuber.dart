import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'イベント販売'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return MyApp();
                      }),
                    )
                  },
                  iconSize: 48.0,
                ),
                IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return MyApp();
                      }),
                    )
                  },
                  iconSize: 48.0,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          // alignment: Alignment.center,
          // width:100,
          // color:Colors.green,
          // child:Column(
          // children: [
          //   myContainer(),
          //   Expanded(child: myContainer()),
          //   myContainer(),
          // ],
        // ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), 
    );
  }
}

// class _MyHomePageState extends State<MyHomePage> {
//   }