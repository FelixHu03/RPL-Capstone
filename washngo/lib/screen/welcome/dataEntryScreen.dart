import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:washngo/layouts/bgWelcome.dart';
import 'package:washngo/screen/home/homeScreen.dart';
import 'package:flutter/foundation.dart';

class DataEntryScreen extends StatefulWidget {
  final String email;

  const DataEntryScreen({super.key, required this.email});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _platController = TextEditingController();

  bool _isLoading = false;

  // Fungsi Memilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        // Format ke YYYY-MM-DD untuk MySQL
        _tglLahirController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Fungsi Simpan Data
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String baseUrl;
    if (kIsWeb) {
      // Jika dijalankan di Browser Edge/Chrome
      baseUrl = 'http://localhost/washngo_api';
    } else {
      // Jika dijalankan di Emulator Android
      baseUrl = 'http://192.168.1.28/washngo_api';
    }

    final url = Uri.parse('$baseUrl/save_data.php');

    try {
      final response = await http.post(
        url,
        body: {
          "email": widget.email, // Kirim email dari constructor
          "no_hp": _hpController.text,
          "alamat": _alamatController.text,
          "tanggal_lahir": _tglLahirController.text,
          "merk": _merkController.text,
          "plat": _platController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil disimpan!"),
            backgroundColor: Colors.green,
          ),
        );
        // Pindah ke Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  Homescreen(email: data['email'])),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error koneksi server")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan bgWelcome sesuai permintaan
    return bgWelcome(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LOGO ---
                Center(
                  child: Image.asset(
                    'assets/images/executive.png', // Sesuaikan path logo
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),

                // --- BAGIAN 1: PENGISIAN DATA ---
                const Text(
                  "Pengisian Data",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _buildCustomInput(
                  label: "No. Hp",
                  hint: "081xxxxxxx",
                  controller: _hpController,
                  inputType: TextInputType.phone,
                ),
                _buildCustomInput(
                  label: "Alamat",
                  hint: "Jl. xxxxxx",
                  controller: _alamatController,
                ),
                // Input Tanggal Lahir (Read Only + OnTap)
                _buildCustomInput(
                  label: "Tanggal Lahir",
                  hint: "YYYY-MM-DD",
                  controller: _tglLahirController,
                  isReadOnly: true,
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 30),

                // --- BAGIAN 2: DETAIL MOBIL ---
                const Text(
                  "Detail Mobil",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _buildCustomInput(
                  label: "Merk Kendaraan",
                  hint: "Toyota Avanza",
                  controller: _merkController,
                ),
                _buildCustomInput(
                  label: "Plat Kendaraan",
                  hint: "BG xxxx YZX",
                  controller: _platController,
                ),

                const SizedBox(height: 40),

                // --- TOMBOL DONE ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF004D40,
                      ), // Warna Hijau Tua Gelap
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Done",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET INPUT CUSTOM (Sesuai Desain Gambar) ---
  Widget _buildCustomInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label dengan Bintang Merah
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontStyle: FontStyle.italic, // Sesuai gambar
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          // Input Field dengan Garis Bawah
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            readOnly: isReadOnly,
            onTap: onTap,
            validator: (val) => val!.isEmpty ? "Harap isi $label" : null,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
              isDense: true,
              // Garis Bawah
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black87, width: 1.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF004D40), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
