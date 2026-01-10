import 'package:flutter/material.dart';

class bgWelcome extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  const bgWelcome({Key? key, required this.child, this.useSafeArea = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/backgroundWelcome.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          useSafeArea
          ? SafeArea(child: child)
          : child,
        ],
      ),
    );
  }
}
