import 'package:flutter/material.dart';
import 'package:washngo/layouts/bgWelcome.dart';
import 'package:washngo/screen/welcome/loginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(), 
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return bgWelcome(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            
            Image.asset(
              'assets/images/executive.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 250),
            
            const Text(
              'Welcome',
              style: TextStyle(
                color: Colors.black,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const Spacer(),
            
            Container(
              padding: const EdgeInsets.only(bottom: 80, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Tombol Panah
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const loginScreen(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/arrow-right.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}