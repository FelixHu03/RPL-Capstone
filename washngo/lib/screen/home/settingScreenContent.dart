import 'package:flutter/material.dart';

class SettingScreenContent extends StatefulWidget {
  const SettingScreenContent({super.key});

  @override
  State<SettingScreenContent> createState() => _SettingScreenContentState();
}

class _SettingScreenContentState extends State<SettingScreenContent> {
  // State untuk switch notifikasi
  bool _isNotificationOn = false;

  // Data Dummy untuk List Mobil
  final List<Map<String, String>> _carList = [
    {'plat': 'BG 1234 XYZ', 'model': '(Toyota Avanza)'},
    {'plat': 'D 5678 EF', 'model': '(Toyota Avanza)'},
    {'plat': 'F 9101 GH', 'model': '(Toyota Brio)'},
    {'plat': 'B 2222 ZZ', 'model': '(Toyota Innova)'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  "Kembali ke halaman sebelumnya",
                  style: TextStyle(
                    fontSize: 16, 
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // JUDUL HALAMAN
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.black
            ),
          ),
          const SizedBox(height: 20),

          // MANAGE PLAT NOMOR 
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE4E6F0), 
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Plat Nomor Polisi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // List Mobil
                ..._carList.map((car) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        // Plat Nomor
                        Expanded(
                          flex: 2,
                          child: Text(
                            car['plat']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15
                            ),
                          ),
                        ),
                        // Model Mobil
                        Expanded(
                          flex: 3,
                          child: Text(
                            car['model']!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        // Tombol Edit Kecil
                        GestureDetector(
                          onTap: () {
                            // Aksi edit
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: const Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 10),

                // Tombol Add Another Car
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black, size: 18),
                    label: const Text(
                      "Add another Car",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          
          // Notification Toggle
          _buildMenuContainer(
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, size: 28),
                const SizedBox(width: 15),
                const Text("Notification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Switch(
                  value: _isNotificationOn,
                  onChanged: (val) {
                    setState(() {
                      _isNotificationOn = val;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.grey,
                )
              ],
            ),
          ),

          const SizedBox(height: 15),

          // 2. Share App
          _buildMenuContainer(
            child: Row(
              children: const [
                Icon(Icons.share_outlined, size: 28),
                SizedBox(width: 15),
                Text("Share App", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // 3. Contact
          _buildMenuContainer(
            child: Row(
              children: const [
                Icon(Icons.mail_outline, size: 28),
                SizedBox(width: 15),
                Text("Contact", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          // Versi Aplikasi
          Center(
            child: Text(
              'WashNGo App Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk membuat kotak menu yang seragam
  Widget _buildMenuContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E6F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}