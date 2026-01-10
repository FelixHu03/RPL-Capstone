import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:washngo/layouts/bgWelcome.dart';
import 'package:washngo/screen/home/homeScreen.dart';
import 'package:washngo/screen/welcome/registerScreen.dart';
import 'package:flutter/foundation.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
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

    final url = Uri.parse('$baseUrl/login.php');

    try {
      final response = await http.post(url, body: {
        "email": _emailController.text,
        "password": _passwordController.text,
      });

      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        // Login Berhasil
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Selamat Datang, ${data['name']}"), backgroundColor: Colors.green),
        );

        // TODO: Simpan session user (Shared Preferences) di sini jika perlu

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) =>  Homescreen(email: data['email'])));
      } else {
        // Login Gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal terhubung ke server")),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/executive.png',
                  width: 350,
                  height: 350,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 50), // Disesuaikan agar tidak terlalu jauh
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  width: double.infinity,
                  child: const Text(
                    'Sign In', // Typo fixed: Sing In -> Sign In
                    style: TextStyle(
                      color: Colors.black, fontSize: 45, fontWeight: FontWeight.bold),
                  ),
                ),
                
                // --- EMAIL INPUT ---
                _buildInputLabel('Email'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? "Masukkan Email" : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.email),
                      hintText: 'Enter your Email',
                    ),
                  ),
                ),

                // --- PASSWORD INPUT ---
                _buildInputLabel('Password'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    validator: (value) => value!.isEmpty ? "Masukkan Password" : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                      hintText: 'Silahkan masukkan password Anda',
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                
                // --- TOMBOL LOGIN ---
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
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login", style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 10),

                // --- LINK REGISTER ---
                Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(
                          color: Color(0XFF005461), decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const registeScreen()));
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
          style: const TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          children: [TextSpan(text: '*', style: const TextStyle(color: Colors.red))],
        ),
      ),
    );
  }
}