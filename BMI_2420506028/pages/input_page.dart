// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'result_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedCategory;

  final List<String> _categories = [
    'Anak-anak',
    'Remaja',
    'Dewasa',
  ];

  String _selectedGender = 'Laki-laki';

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      prefixIcon: Icon(icon, color: Color(0xFF1565C0)),
      labelStyle: TextStyle(color: Color(0xFF1565C0)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFBBDEFB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF1565C0), size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Divider(color: Color(0xFFBBDEFB), thickness: 1, height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4FF),
      body: Form(
        key: _formKey,
        child: ListView(
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
              padding: EdgeInsets.fromLTRB(24, 56, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.monitor_weight_outlined, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalkulator BMI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Body Mass Index Calculator',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Masukkan data Anda untuk mengetahui\nindeks massa tubuh secara akurat.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // ── Card: Data Pribadi ──
            _sectionCard(
              title: 'DATA PRIBADI',
              icon: Icons.person_outline,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Mohon isi data ini';
                    return null;
                  },
                  controller: _nameController,
                  decoration: _fieldDecoration(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama...',
                    icon: Icons.badge_outlined,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Mohon isi data ini';
                    return null;
                  },
                  value: _selectedCategory,
                  decoration: _fieldDecoration(
                    label: 'Kategori Usia',
                    hint: '',
                    icon: Icons.cake_outlined,
                  ),
                  hint: Text('Pilih kategori...', style: TextStyle(color: Colors.grey)),
                  items: _categories.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Jenis Kelamin',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = 'Laki-laki'),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedGender == 'Laki-laki'
                                ? Color(0xFF1565C0)
                                : Colors.white,
                            border: Border.all(
                              color: _selectedGender == 'Laki-laki'
                                  ? Color(0xFF1565C0)
                                  : Color(0xFFBBDEFB),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.male,
                                color: _selectedGender == 'Laki-laki'
                                    ? Colors.white
                                    : Color(0xFF1565C0),
                                size: 28,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Laki-laki',
                                style: TextStyle(
                                  color: _selectedGender == 'Laki-laki'
                                      ? Colors.white
                                      : Color(0xFF1565C0),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = 'Perempuan'),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedGender == 'Perempuan'
                                ? Color(0xFFAD1457)
                                : Colors.white,
                            border: Border.all(
                              color: _selectedGender == 'Perempuan'
                                  ? Color(0xFFAD1457)
                                  : Color(0xFFF8BBD0),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.female,
                                color: _selectedGender == 'Perempuan'
                                    ? Colors.white
                                    : Color(0xFFAD1457),
                                size: 28,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Perempuan',
                                style: TextStyle(
                                  color: _selectedGender == 'Perempuan'
                                      ? Colors.white
                                      : Color(0xFFAD1457),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Card: Data Fisik ──
            _sectionCard(
              title: 'DATA FISIK',
              icon: Icons.straighten,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Mohon isi data ini';
                    return null;
                  },
                  controller: _weightController,
                  decoration: _fieldDecoration(
                    label: 'Berat Badan',
                    hint: 'Contoh: 65',
                    icon: Icons.monitor_weight_outlined,
                    suffix: 'kg',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 16),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Mohon isi data ini';
                    return null;
                  },
                  controller: _heightController,
                  decoration: _fieldDecoration(
                    label: 'Tinggi Badan',
                    hint: 'Contoh: 170',
                    icon: Icons.height,
                    suffix: 'cm',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),

            // ── Tombol Hitung ──
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    final nama = _nameController.text;
                    final berat = double.parse(_weightController.text);
                    final tinggi = double.parse(_heightController.text) / 100;
                    final bmi = berat / (tinggi * tinggi);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(
                          nama: nama,
                          bmi: bmi,
                          gender: _selectedGender,
                          kategori: _selectedCategory!,
                        ),
                      ),
                    );
                  }
                },
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
                      Icon(Icons.calculate_outlined, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Hitung BMI',
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
      ),
    );
  }
}
