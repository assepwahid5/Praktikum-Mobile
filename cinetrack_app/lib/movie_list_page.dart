import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'movie_model.dart';
import 'sort_option.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  // State variables
  List<MovieModel> _movies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = false;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();

  // Active filter/sort state
  SortOption _activeSort = SortOption.idAsc;
  String _selectedGenre = 'Sci-Fi';

  // Available genres for dropdown
  final List<String> _genres = [
    'Action',
    'Comedy',
    'Drama',
    'Sci-Fi',
    'Horror',
    'Romance',
    'Animation',
    'Thriller',
    'Adventure'
  ];

  // Initial dummy data
  final List<MovieModel> _dummyMovies = [
    MovieModel(id: 1, title: 'Inception', director: 'Christopher Nolan', genre: 'Sci-Fi'),
    MovieModel(id: 2, title: 'The Dark Knight', director: 'Christopher Nolan', genre: 'Action'),
    MovieModel(id: 3, title: 'Spirited Away', director: 'Hayao Miyazaki', genre: 'Animation'),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _directorController.dispose();
    super.dispose();
  }

  // --- PERSISTENCE: SharedPreferences ---

  // Memuat data dari SharedPreferences
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? moviesJson = prefs.getString('movie_watchlist');

      if (moviesJson != null) {
        final List<dynamic> decodedList = json.decode(moviesJson);
        setState(() {
          _movies = decodedList.map((item) => MovieModel.fromMap(item)).toList();
        });
      } else {
        // Jika data kosong pada run pertama, gunakan data dummy
        setState(() {
          _movies = List.from(_dummyMovies);
        });
        await _saveData();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _applyFilterAndSort();
      setState(() => _isLoading = false);
    }
  }

  // Menyimpan data ke SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(_movies.map((m) => m.toMap()).toList());
      await prefs.setString('movie_watchlist', encodedData);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // --- CRUD FUNCTIONS ---

  // Menambahkan film baru
  Future<void> _addMovie() async {
    if (_titleController.text.trim().length < 2 || _titleController.text.trim().length > 50) {
      return;
    }
    if (_directorController.text.trim().length < 3 || _directorController.text.trim().length > 50) {
      return;
    }

    // Tentukan ID baru (inkremental)
    final int newId = _movies.isNotEmpty
        ? _movies.map((m) => m.id).reduce((curr, next) => curr > next ? curr : next) + 1
        : 1;

    final newMovie = MovieModel(
      id: newId,
      title: _titleController.text.trim(),
      director: _directorController.text.trim(),
      genre: _selectedGenre,
    );

    setState(() {
      _movies.add(newMovie);
    });

    await _saveData();
    _applyFilterAndSort();
    _clearControllers();

    if (mounted) {
      Navigator.of(context).pop(); // Tutup dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newMovie.title}" berhasil ditambahkan ke watchlist.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  // Mengubah data film yang ada
  Future<void> _editMovie(MovieModel movie) async {
    if (_titleController.text.trim().length < 2 || _titleController.text.trim().length > 50) {
      return;
    }
    if (_directorController.text.trim().length < 3 || _directorController.text.trim().length > 50) {
      return;
    }

    final int index = _movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      setState(() {
        _movies[index] = MovieModel(
          id: movie.id,
          title: _titleController.text.trim(),
          director: _directorController.text.trim(),
          genre: _selectedGenre,
        );
      });

      await _saveData();
      _applyFilterAndSort();
      _clearControllers();

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informasi film berhasil diperbarui.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  // Menghapus film berdasarkan ID
  Future<void> _deleteMovie(int id) async {
    final movie = _movies.firstWhere((m) => m.id == id);
    setState(() {
      _movies.removeWhere((m) => m.id == id);
    });

    await _saveData();
    _applyFilterAndSort();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${movie.title}" dihapus dari watchlist.'),
          backgroundColor: AppColors.danger,
          action: SnackBarAction(
            label: 'Batal',
            textColor: AppColors.textPrimary,
            onPressed: () async {
              setState(() {
                _movies.add(movie);
              });
              await _saveData();
              _applyFilterAndSort();
            },
          ),
        ),
      );
    }
  }

  // --- FILTER & SORT LOGIC ---

  void _onSearchChanged() {
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    final query = _searchController.text.trim().toLowerCase();
    List<MovieModel> temp = List.from(_movies);

    // Filter berdasarkan query pencarian (ID, Judul, atau Sutradara)
    if (query.isNotEmpty) {
      temp = temp.where((movie) {
        final idMatch = movie.id.toString() == query;
        final titleMatch = movie.title.toLowerCase().contains(query);
        final directorMatch = movie.director.toLowerCase().contains(query);
        return idMatch || titleMatch || directorMatch;
      }).toList();
    }

    // Jalankan pengurutan (Sorting)
    switch (_activeSort) {
      case SortOption.idAsc:
        temp.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortOption.idDesc:
        temp.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.titleAsc:
        temp.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleDesc:
        temp.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOption.directorAsc:
        temp.sort((a, b) => a.director.toLowerCase().compareTo(b.director.toLowerCase()));
        break;
      case SortOption.directorDesc:
        temp.sort((a, b) => b.director.toLowerCase().compareTo(a.director.toLowerCase()));
        break;
    }

    setState(() {
      _filteredMovies = temp;
    });
  }

  // --- UTILITY METHODS ---

  void _clearControllers() {
    _titleController.clear();
    _directorController.clear();
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.idAsc:
        return 'ID Terkecil';
      case SortOption.idDesc:
        return 'ID Terbesar';
      case SortOption.titleAsc:
        return 'Judul A-Z';
      case SortOption.titleDesc:
        return 'Judul Z-A';
      case SortOption.directorAsc:
        return 'Sutradara A-Z';
      case SortOption.directorDesc:
        return 'Sutradara Z-A';
    }
  }

  Color _getGenreColor(String genre) {
    switch (genre) {
      case 'Action':
        return Colors.redAccent;
      case 'Sci-Fi':
        return AppColors.primary;
      case 'Animation':
        return AppColors.secondary;
      case 'Drama':
        return Colors.blueAccent;
      case 'Horror':
        return Colors.purpleAccent;
      case 'Comedy':
        return Colors.orangeAccent;
      case 'Romance':
        return Colors.pinkAccent;
      default:
        return Colors.tealAccent;
    }
  }

  // --- DIALOGS (UI COMPONENTS) ---

  // Menampilkan Dialog Add atau Edit Film
  void _showFormDialog({MovieModel? movie}) {
    final bool isEdit = movie != null;
    if (isEdit) {
      _titleController.text = movie.title;
      _directorController.text = movie.director;
      _selectedGenre = movie.genre;
    } else {
      _clearControllers();
      _selectedGenre = 'Sci-Fi';
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border, width: 1.5),
              ),
              title: Text(
                isEdit ? 'Ubah Informasi Film' : 'Tambah Film Baru',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Input Judul Film
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Judul Film',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.danger),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.danger, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.movie_filter, color: AppColors.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul film tidak boleh kosong';
                          }
                          if (value.trim().length < 2 || value.trim().length > 50) {
                            return 'Judul harus antara 2-50 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Input Sutradara
                      TextFormField(
                        controller: _directorController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Sutradara',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.danger),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.danger, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_pin, color: AppColors.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama sutradara tidak boleh kosong';
                          }
                          if (value.trim().length < 3 || value.trim().length > 50) {
                            return 'Nama harus antara 3-50 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dropdown Pilihan Genre
                      DropdownButtonFormField<String>(
                        value: _selectedGenre,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Genre Film',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category, color: AppColors.textSecondary),
                        ),
                        items: _genres.map((String genre) {
                          return DropdownMenuItem<String>(
                            value: genre,
                            child: Text(genre),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              _selectedGenre = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Tombol Batal
                TextButton(
                  onPressed: () {
                    _clearControllers();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                // Tombol Simpan
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (isEdit) {
                        _editMovie(movie);
                      } else {
                        _addMovie();
                      }
                    }
                  },
                  child: Text(isEdit ? 'Ubah' : 'Simpan', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog Konfirmasi Hapus Film
  void _showDeleteConfirmation(int id, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: const Text(
            'Hapus dari Watchlist?',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus film "$title" dari daftar watchlist Anda?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMovie(id);
              },
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- SCENE BUILDERS ---

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Watchlist',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          // Menu Aksi Pengurutan (Sorting)
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.primary),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            onSelected: (SortOption option) {
              setState(() {
                _activeSort = option;
              });
              _applyFilterAndSort();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              PopupMenuItem<SortOption>(
                value: SortOption.idAsc,
                child: Text('ID Terkecil',
                    style: TextStyle(
                        color: _activeSort == SortOption.idAsc
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
              PopupMenuItem<SortOption>(
                value: SortOption.idDesc,
                child: Text('ID Terbesar',
                    style: TextStyle(
                        color: _activeSort == SortOption.idDesc
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
              PopupMenuItem<SortOption>(
                value: SortOption.titleAsc,
                child: Text('Judul A-Z',
                    style: TextStyle(
                        color: _activeSort == SortOption.titleAsc
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
              PopupMenuItem<SortOption>(
                value: SortOption.titleDesc,
                child: Text('Judul Z-A',
                    style: TextStyle(
                        color: _activeSort == SortOption.titleDesc
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
              PopupMenuItem<SortOption>(
                value: SortOption.directorAsc,
                child: Text('Sutradara A-Z',
                    style: TextStyle(
                        color: _activeSort == SortOption.directorAsc
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
              PopupMenuItem<SortOption>(
                value: SortOption.directorDesc,
                child: Text('Sutradara Z-A',
                    style: TextStyle(
                        color: _activeSort == SortOption.directorDesc
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kolom Pencarian
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari judul, sutradara, atau ID...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Info Bar: Jumlah Watchlist & Status Pengurutan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredMovies.length} Film',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.swap_vert_rounded, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _getSortLabel(_activeSort),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area (Loading, Empty, atau ListView)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _filteredMovies.isEmpty
                      ? _buildEmptyState(isSearching)
                      : _buildListView(),
            ),
          ],
        ),
      ),
      // Tombol Tambah Watchlist Baru
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 6,
        tooltip: 'Tambah Film',
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  // Membangun Empty State Layout
  Widget _buildEmptyState(bool isSearching) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.movie_outlined,
                size: 72,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'Tidak Ada Hasil' : 'Watchlist Masih Kosong',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Coba gunakan kata kunci pencarian lain\natau bersihkan kolom pencarian.'
                  : 'Mulai buat daftar tontonan film Anda\ndengan menekan tombol "+" di bawah.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text('Bersihkan Pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Membangun ListView Builder
  Widget _buildListView() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredMovies.length,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];
        final genreColor = _getGenreColor(movie.genre);

        return Card(
          color: AppColors.surface,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar Visual (Inisial Genre)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: genreColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: genreColor.withOpacity(0.5), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    movie.genre.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: genreColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Informasi Teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ID: ${movie.id}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: genreColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              movie.genre,
                              style: TextStyle(
                                color: genreColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dir: ${movie.director}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol Edit & Hapus
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.secondary, size: 22),
                      onPressed: () => _showFormDialog(movie: movie),
                      tooltip: 'Ubah Film',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
                      onPressed: () => _showDeleteConfirmation(movie.id, movie.title),
                      tooltip: 'Hapus Film',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
