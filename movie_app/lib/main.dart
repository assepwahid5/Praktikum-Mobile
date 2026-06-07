import 'package:flutter/material.dart';
import 'movie_service.dart';
import 'movie_list_screen.dart';

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    final movieService = MovieService();

    return MaterialApp(
      title: 'Movie DB App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MovieListScreen(service: movieService),
    );
  }
}
