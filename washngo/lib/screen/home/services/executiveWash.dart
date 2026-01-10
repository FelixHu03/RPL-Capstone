import 'package:flutter/material.dart';
import 'package:washngo/layouts/bgHomeScreen.dart';
import 'package:washngo/screen/home/content/ExecutivewashContent.dart';

class Executivewash extends StatelessWidget {
  final String email; // 1. Siapkan penampung email

  // 2. Tambahkan di constructor
  const Executivewash({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Bghomescreen(
      showFooter: false, 
      child: ExecutivewashContent(email: email),
    );
  }
}