import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  // API Key TMDB placeholder. Silakan ganti dengan API Key TMDB Anda.
  static const String _apiKey = 'YOUR_TMDB_API_KEY_HERE';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Fungsi helper untuk mempermudah request HTTP GET
  Future<dynamic> _get(String path, {Map<String, String>? queryParams}) async {
    final Map<String, String> query = {
      'api_key': _apiKey,
      ...?queryParams,
    };

    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    
    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Koneksi timeout. Silakan coba lagi.'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data (Status Code: ${response.statusCode})');
    }
  }

  // Mengambil daftar film terpopuler
  Future<List<Movie>> fetchPopularMovies() async {
    final data = await _get('/movie/popular');
    final List<dynamic> results = data['results'] as List? ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  // Mencari film berdasarkan judul/kata kunci
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _get('/search/movie', queryParams: {'query': query});
    final List<dynamic> results = data['results'] as List? ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  // Mengambil informasi rincian film berdasarkan ID film
  Future<MovieDetail> fetchMovieDetail(int movieId) async {
    final data = await _get('/movie/$movieId');
    return MovieDetail.fromJson(data);
  }
}
