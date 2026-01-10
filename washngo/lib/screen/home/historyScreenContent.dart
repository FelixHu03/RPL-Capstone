import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ada
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class HistoryScreen extends StatefulWidget {
  final String email; // Menerima email dari Home
  const HistoryScreen({super.key, required this.email});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    // Tentukan URL API
    String baseUrl;
    if (kIsWeb) {
      baseUrl = 'http://localhost/washngo_api';
    } else {
      baseUrl = 'http://192.168.1.28/washngo_api'; 
    }

    final url = Uri.parse('$baseUrl/get_user_history.php');

    try {
      final response = await http.post(url, body: {'email': widget.email});
      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        if (mounted) {
          setState(() {
            _historyData = data['data'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : (_historyData.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList()),
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

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: _historyData.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final item = _historyData[index];
        
        // FORMAT TANGGAL
        // Dari "2025-12-17" menjadi format yang lebih rapi
        // Jika ingin Bahasa Indonesia ("Rabu..."), perlu setup locale tambahan
        // Di sini saya pakai format standar dulu: "EEEE, d MMMM y"
        DateTime date = DateTime.parse(item['booking_date']);
        String formattedDate = DateFormat('EEEE, d MMMM y').format(date); 

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
                formattedDate, 
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
                  // Bilik (bay_number dari DB)
                  SizedBox(
                    width: 60,
                    child: Text(
                      "Bilik ${item['bay_number']}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Plat Nomor (vehicle_name dari DB)
                  // Karena di DB tersimpan "Plat (Merk)", kita tampilkan saja langsung
                  Expanded( // Pakai Expanded agar teks panjang tidak error
                    child: Text(
                      item['vehicle_name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Sedikit dikecilkan agar muat
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Jam (schedule_time dari DB)
                  SizedBox(
                    width: 90,
                    child: Text(
                      item['schedule_time'],
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