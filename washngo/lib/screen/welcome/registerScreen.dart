import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:washngo/layouts/bgWelcome.dart';
import 'package:washngo/screen/welcome/dataEntryScreen.dart';
import 'package:washngo/screen/welcome/loginScreen.dart';
import 'package:flutter/foundation.dart';

class registeScreen extends StatefulWidget {
  const registeScreen({super.key});

  @override
  State<registeScreen> createState() => _registeScreenState();
}

class _registeScreenState extends State<registeScreen> {
  // Controller untuk mengambil teks inputan
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Kunci form untuk validasi
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureText = true; // Untuk mata password

  // Fungsi Register ke API PHP
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String baseUrl;
    if (kIsWeb) {
      // Jika dijalankan di Browser Edge/Chrome
      baseUrl = 'http://localhost/washngo_api';
    } else {
      // Jika dijalankan di Emulator Android
      baseUrl = 'http://192.168.1.28/washngo_api';
    }

    final url = Uri.parse('$baseUrl/register.php');

    try {
      final response = await http.post(
        url,
        body: {
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        // Berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
        // Pindah ke Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DataEntryScreen(email: _emailController.text)),
        );
      } else {
        // Gagal (Email sudah ada, dll)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan koneksi")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return bgWelcome(
      child: Center(
        child: SingleChildScrollView(
          // Agar tidak overflow saat keyboard muncul
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/executive.png',
                  width: 300, // Sedikit diperkecil agar muat
                  height: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 15,
                  ),
                  width: double.infinity,
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // --- INPUT NAMA ---
                _buildInputLabel('Name'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) =>
                        value!.isEmpty ? "Nama tidak boleh kosong" : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      hintText: 'Enter your name',
                    ),
                  ),
                ),

                // --- INPUT EMAIL ---
                _buildInputLabel('Email'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        !value!.contains('@') ? "Email tidak valid" : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email),
                      hintText: 'Enter your Email',
                    ),
                  ),
                ),

                // --- INPUT PASSWORD ---
                _buildInputLabel('Password'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    validator: (value) =>
                        value!.length < 6 ? "Minimal 6 karakter" : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      ),
                      hintText: 'Password minimal 6 karakter',
                    ),
                  ),
                ),

                // --- INPUT CONFIRM PASSWORD ---
                _buildInputLabel('Confirm Password'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value != _passwordController.text)
                        return "Password tidak sama";
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Enter your password again',
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- TOMBOL REGISTER ---
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF005461),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : _register, // Disable saat loading
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- LINK LOGIN ---
                Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: const TextStyle(
                          color: Color(0XFF005461),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const loginScreen(),
                              ),
                            );
                          },
                      ),
                    ],
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

  Widget _buildInputLabel(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: '*',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
