import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:washngo/screen/home/settingScreen.dart';
import 'package:washngo/screen/welcome/loginScreen.dart';

class Accountscreencontent extends StatefulWidget {
  final String email; // Menerima email dari Home
  const Accountscreencontent({super.key, required this.email});

  @override
  State<Accountscreencontent> createState() => _AccountscreencontentState();
}

class _AccountscreencontentState extends State<Accountscreencontent> {
  // Variabel penampung data
  String _name = "Loading...";
  String _phone = "-";
  String _address = "-";
  String _dob = "-";
  String _emailDisplay = "-";
  
  List<String> _platList = [];
  String? _selectedPlat;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fungsi Ambil Data dari API
  Future<void> _fetchUserProfile() async {
    String baseUrl;
    if (kIsWeb) {
      baseUrl = 'http://localhost/washngo_api';
    } else {
      // GANTI DENGAN IP LAPTOP ANDA (Cek ipconfig)
      baseUrl = 'http://192.168.1.28/washngo_api'; 
    }

    final url = Uri.parse('$baseUrl/get_user_profile.php');

    try {
      final response = await http.post(url, body: {'email': widget.email});
      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        final userData = data['data'];
        if (mounted) {
          setState(() {
            _name = userData['name'];
            _emailDisplay = userData['email'];
            _phone = userData['phone'];
            _address = userData['address'];
            _dob = userData['dob'];
            
            // Update list mobil
            _platList = List<String>.from(userData['vehicles']);
            if (_platList.isNotEmpty) {
              _selectedPlat = _platList[0];
            } else {
              _platList = ["Belum ada mobil"];
              _selectedPlat = _platList[0];
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Logout
  void _logout() {
    // Navigasi ke Login dan HAPUS semua halaman sebelumnya (tidak bisa back)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const loginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView( // Agar bisa discroll jika layar kecil
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Container Profil Data
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E6F0),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem('Nama', _name),
                  const SizedBox(height: 10),
                  _buildProfileItem('No. Telepon', _phone),
                  const SizedBox(height: 10),
                  _buildProfileItem('Alamat', _address),
                  const SizedBox(height: 10),
                  _buildProfileItem('Tanggal Lahir', _dob),
                  const SizedBox(height: 10),
                  _buildProfileItem('Email', _emailDisplay),
                ],
              ),
            ),

            // DROPDOWN PLAT NOMOR
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E6F0),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Daftar Plat Nomor Polisi',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyan[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPlat,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black,
                          size: 34,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        dropdownColor: Colors.cyan[100],
                        borderRadius: BorderRadius.circular(20),
                        items: _platList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPlat = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
            
            // TOMBOL LOGOUT & SETTING
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Logout
                    ElevatedButton.icon(
                      onPressed: _logout, // Panggil fungsi logout
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 23, color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 20),
                    // Setting Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Setting',
                        style: TextStyle(fontSize: 23, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Teks Profil agar rapi
  Widget _buildProfileItem(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18, color: Colors.black),
        children: [
          TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}