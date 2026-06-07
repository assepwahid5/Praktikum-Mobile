class MovieModel {
  final int id;
  final String title;
  final String director;
  final String genre;

  MovieModel({
    required this.id,
    required this.title,
    required this.director,
    required this.genre,
  });

  // Konversi dari MovieModel ke Map untuk disimpan di SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'director': director,
      'genre': genre,
    };
  }

  // Membuat instance MovieModel dari Map (biasanya hasil json.decode)
  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'] as int,
      title: map['title'] as String,
      director: map['director'] as String,
      genre: map['genre'] as String,
    );
  }
}
