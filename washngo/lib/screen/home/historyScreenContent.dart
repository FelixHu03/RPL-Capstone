import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> historyData = [
      {
        'date': 'Rabu, 17 Desember 2025',
        'bilik': 'Bilik 1',
        'plat': 'BG 1234 YZX',
        'time': '13:00 - 14:30',
      },
      {
        'date': 'Kamis, 18 Desember 2025',
        'bilik': 'Bilik 2',
        'plat': 'B 5678 AA',
        'time': '10:00 - 11:30',
      },
      {
        'date': 'Jumat, 19 Desember 2025',
        'bilik': 'Bilik 1',
        'plat': 'BG 9999 ZZ',
        'time': '15:00 - 16:30',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul
          const Text(
            'History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: historyData.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(historyData),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Belum ada riwayat transaksi.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, String>> data) {
    return ListView.builder(
      itemCount: data.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            children: [
              // Baris Tanggal
              Text(
                item['date']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // Baris Detail
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bilik
                  SizedBox(
                    width: 60,
                    child: Text(
                      item['bilik']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Plat Nomor (Tengah)
                  Text(
                    item['plat']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // Jam
                  SizedBox(
                    width: 90,
                    child: Text(
                      item['time']!,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
