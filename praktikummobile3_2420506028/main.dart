import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.orange,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 30,
                color: Colors.white,
                child: Text("Container 1"),
              ),

              SizedBox(width: 20),

              Container(color: Colors.cyan, child: Text("Container 2")),

              Container(color: Colors.greenAccent, child: Text("Container 3")),
            ],
          ),
        ),
      ),
    );
  }
}
