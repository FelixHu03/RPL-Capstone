import 'package:flutter/material.dart';

class Bghomescreen extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  // Tambahan untuk Footer
  final int currentIndex;
  final Function(int)? onTap;
  final bool showFooter; 

  const Bghomescreen({
    Key? key,
    required this.child,
    this.useSafeArea = true,
    this.currentIndex = 0,
    this.onTap,
    this.showFooter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF26CCC2);

    return Scaffold(
      extendBody: true,

      // FOOTER
      bottomNavigationBar: showFooter
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: const Border(
                  top: BorderSide(color: Colors.black12, width: 0.5),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: primaryColor,
                unselectedItemColor: Colors.black54,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Account',
                  ),
                ],
              ),
            )
          : null,

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/backgroundHome.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.1)),

          // 3. Konten Utama
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // HEADER
                if (useSafeArea)
                  SizedBox(height: MediaQuery.of(context).padding.top),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/executive.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 40),
                      const Text(
                        'WashNGo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40),
                      Image.asset(
                        'assets/images/notification.png',
                        width: 35,
                        height: 35,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),

                Expanded(child: child),

                if (showFooter) const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
