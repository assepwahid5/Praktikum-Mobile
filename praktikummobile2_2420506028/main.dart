import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Welcome to My Flutter App",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
        ),
        body: SizedBox.expand(
          child: Opacity(
            opacity: 0.6,
            child: Image.asset(
              'images/pexels.jpg', // path harus lengkap
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ),
  );
}
