// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String nama, gender, kategori;
  final double bmi;

  const ResultPage({
    required this.nama,
    required this.bmi,
    required this.gender,
    required this.kategori,
    super.key,
  });

  // Perbaikan: Tambah kategori Gemuk (Overweight)
  String _getKategori() {
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Gemuk';
    return 'Obesitas';
  }

  Color _getKategoriColor() {
    if (bmi < 18.5) return Color(0xFF0288D1); // biru – kurus
    if (bmi < 25.0) return Color(0xFF2E7D32); // hijau – normal
    if (bmi < 30.0) return Color(0xFFF57F17); // kuning – gemuk
    return Color(0xFFC62828);                  // merah – obesitas
  }

  IconData _getKategoriIcon() {
    if (bmi < 18.5) return Icons.arrow_downward_rounded;
    if (bmi < 25.0) return Icons.check_circle_outline;
    if (bmi < 30.0) return Icons.warning_amber_rounded;
    return Icons.dangerous_outlined;
  }

  String _getSaran() {
    if (bmi < 18.5) {
      return 'Berat badan Anda kurang dari ideal. Disarankan untuk meningkatkan asupan kalori bergizi, konsumsi protein yang cukup, dan konsultasi dengan ahli gizi.';
    } else if (bmi < 25.0) {
      return 'Selamat! Berat badan Anda berada dalam kondisi ideal. Pertahankan pola makan sehat dan aktivitas fisik rutin untuk menjaga kondisi ini.';
    } else if (bmi < 30.0) {
      return 'Berat badan Anda sedikit berlebih. Disarankan untuk mengurangi konsumsi makanan tinggi lemak dan gula, serta meningkatkan aktivitas fisik secara bertahap.';
    } else {
      return 'Berat badan Anda termasuk kategori obesitas. Segera konsultasikan dengan dokter atau ahli gizi untuk mendapatkan program penurunan berat badan yang aman dan terstruktur.';
    }
  }

  Widget _buildBmiScale() {
    // Clamp BMI ke rentang 10–40 untuk tampilan visual
    final double clampedBmi = bmi.clamp(10.0, 40.0);
    final double percent = (clampedBmi - 10.0) / 30.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Track bar gradasi warna
            Container(
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0288D1),
                    Color(0xFF2E7D32),
                    Color(0xFFF57F17),
                    Color(0xFFC62828),
                  ],
                ),
              ),
            ),
            // Indikator posisi
            FractionallySizedBox(
              widthFactor: percent.clamp(0.0, 1.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _getKategoriColor(), width: 3),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('18.5', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('25', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('30', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('40', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kategoriLabel = _getKategori();
    final kategoriColor = _getKategoriColor();

    return Scaffold(
      backgroundColor: Color(0xFFF0F4FF),
      body: ListView(
        children: [
          // ── Header Gradient ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, 52, 16, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Hasil Perhitungan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: 16),
                // Avatar & nama
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    gender == 'Laki-laki' ? Icons.male : Icons.female,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  nama,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$gender  •  $kategori',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // ── Card: Nilai BMI ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('Nilai BMI Anda', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: kategoriColor,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(' kg/m²', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: kategoriColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getKategoriIcon(), color: kategoriColor, size: 18),
                          SizedBox(width: 6),
                          Text(
                            kategoriLabel,
                            style: TextStyle(
                              color: kategoriColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildBmiScale(),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // ── Card: Info Ringkas ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'INFORMASI',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0)),
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFFBBDEFB), height: 18),
                    _buildInfoTile(Icons.category_outlined, 'Kategori Usia', kategori, Color(0xFF1565C0)),
                    SizedBox(height: 8),
                    _buildInfoTile(
                      Icons.favorite_outline,
                      'Status Kesehatan',
                      kategoriLabel,
                      kategoriColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // ── Card: Saran ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              color: kategoriColor.withOpacity(0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: kategoriColor.withOpacity(0.25)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined, color: kategoriColor, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'SARAN KESEHATAN',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kategoriColor),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      _getSaran(),
                      style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // ── Tombol Hitung Ulang ──
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 32),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1976D2).withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Hitung Ulang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
