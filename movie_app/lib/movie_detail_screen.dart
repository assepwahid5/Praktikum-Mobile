import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  final MovieService service;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    required this.service,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<MovieDetail> _movieDetailFuture;

  @override
  void initState() {
    super.initState();
    _loadMovieDetail();
  }

  void _loadMovieDetail() {
    setState(() {
      _movieDetailFuture = widget.service.fetchMovieDetail(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F172A); // Slate 900
    const cardBgColor = Color(0xFF1E293B); // Slate 800
    const accentColor = Color(0xFF38BDF8); // Sky Blue

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        title: const Text(
          'Detail Film',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<MovieDetail>(
        future: _movieDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loadMovieDetail,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Detail film tidak ditemukan',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final movie = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Backdrop Image dengan Gradient Overlay
                Stack(
                  children: [
                    movie.backdropUrl.isNotEmpty
                        ? Image.network(
                            movie.backdropUrl,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(height: 250, color: cardBgColor);
                            },
                          )
                        : Container(height: 250, color: cardBgColor),
                    // Efek Gradasi menggelap ke bawah
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            backgroundColor.withValues(alpha: 0.5),
                            backgroundColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),

                // Seksi Informasi Utama (Poster dan Informasi Teks)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poster Film Mini
                            Container(
                              width: 110,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: movie.posterUrl.isNotEmpty
                                  ? Image.network(
                                      movie.posterUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(color: cardBgColor);
                                      },
                                    )
                                  : Container(color: cardBgColor),
                            ),
                            const SizedBox(width: 16),
                            // Informasi Teks di samping Poster
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Rating
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFFBBF24),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          movie.ratingFormatted,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          ' / 10',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Row Metadata
                                    Row(
                                      children: [
                                        _MetaInfoChip(
                                          icon: Icons.calendar_today,
                                          label: movie.releaseYear,
                                          accentColor: accentColor,
                                          cardBgColor: cardBgColor,
                                        ),
                                        const SizedBox(width: 8),
                                        _MetaInfoChip(
                                          icon: Icons.schedule,
                                          label: movie.runtimeFormatted,
                                          accentColor: accentColor,
                                          cardBgColor: cardBgColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Chips Genre
                        if (movie.genres.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: movie.genres
                                .take(4)
                                .map((g) => _GenreChip(name: g.name, accentColor: accentColor))
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Sinopsis
                        const Text(
                          'Sinopsis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview.isNotEmpty
                              ? movie.overview
                              : 'Tidak ada sinopsis untuk film ini.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetaInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final Color cardBgColor;

  const _MetaInfoChip({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.cardBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String name;
  final Color accentColor;

  const _GenreChip({required this.name, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
