import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class ExecutivewashContent extends StatefulWidget {
  final String email;
  const ExecutivewashContent({super.key, required this.email});

  @override
  State<ExecutivewashContent> createState() => _ExecutivewashContentState();
}

class _ExecutivewashContentState extends State<ExecutivewashContent> {
  // Variabel Data User
  String _userName = "Loading...";
  List<String> _vehicleList = [];
  bool _isLoadingData = true;

  // --- VARIABEL BARU UNTUK CEK KETERSEDIAAN ---
  List<int> _bookedBays =
      []; // Menampung bilik yang sudah dipesan (misal: [1, 3])
  // -------------------------------------------

  final List<Map<String, dynamic>> _serviceList = [
    {'name': 'Executive Wash', 'price': 50000},
    {'name': 'Regular Wash', 'price': 35000},
    {'name': 'Body Polish', 'price': 100000},
  ];

  final List<String> _scheduleList = [
    '09:00 - 10:30',
    '10:30 - 12:00',
    '13:00 - 14:30',
  ];

  String? _selectedVehicle;
  Map<String, dynamic>? _selectedService;
  String? _selectedSchedule;
  int? _selectedBay;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedService = _serviceList[0];
    _selectedSchedule = _scheduleList[0];

    _fetchUserData();
    _checkAvailability(); // Cek ketersediaan saat pertama kali buka
  }

  // --- FUNGSI 1: AMBIL DATA USER ---
  Future<void> _fetchUserData() async {
    String baseUrl = kIsWeb
        ? 'http://localhost/washngo_api'
        : 'http://192.168.1.28/washngo_api';
    final url = Uri.parse('$baseUrl/get_booking_data.php');

    try {
      final response = await http
          .post(url, body: {'email': widget.email})
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        if (mounted) {
          setState(() {
            _userName = data['nama'];
            _vehicleList = List<String>.from(data['vehicles']);
            if (_vehicleList.isNotEmpty) _selectedVehicle = _vehicleList[0];
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  // --- FUNGSI 2: CEK KETERSEDIAAN BILIK (FITUR BARU) ---
  Future<void> _checkAvailability() async {
    String baseUrl = kIsWeb
        ? 'http://localhost/washngo_api'
        : 'http://192.168.1.28/washngo_api';
    final url = Uri.parse('$baseUrl/check_availability.php');

    // Siapkan data tanggal & jam
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final response = await http.post(
        url,
        body: {'date': dateStr, 'schedule': _selectedSchedule},
      );

      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        if (mounted) {
          setState(() {
            // Masukkan data dari PHP ke list _bookedBays
            _bookedBays = List<int>.from(data['booked_bays']);

            // Logika Pengaman:
            // Jika bilik yang sedang dipilih user (misal bilik 1) ternyata masuk daftar booked,
            // maka batalkan pilihan user agar dia tidak booking bilik penuh.
            if (_selectedBay != null && _bookedBays.contains(_selectedBay)) {
              _selectedBay = null;
            }
          });
        }
      }
    } catch (e) {
      print("Error checking availability: $e");
    }
  }

  // --- FUNGSI 3: KIRIM ORDER ---
  // --- FUNGSI 1: TAMPILKAN POPUP QR CODE (Langkah Awal) ---
  void _showPaymentDialog(int totalPrice) {
    // 1. Validasi dulu sebelum muncul QR
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih kendaraan dulu!")));
      return;
    }
    if (_selectedBay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih bilik dulu!")),
      );
      return;
    }

    // 2. Tampilkan Dialog
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa tutup dengan klik di luar
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(child: Text("Pembayaran QRIS")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Scan QR di bawah ini untuk membayar:",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // --- GAMBAR QR CODE ---
              // Jika punya gambar: Image.asset('assets/images/qris.png', height: 200),
              // Di sini kita pakai Icon besar sebagai contoh Fake QR
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 200,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Total: Rp $totalPrice",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF311B92),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Menunggu pembayaran...",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.red)),
            ),

            // Tombol Konfirmasi Bayar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog QR
                _processBookingToDB(totalPrice); // LANJUT SIMPAN KE DB
              },
              child: const Text("Sudah Bayar"),
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI 2: SIMPAN KE DATABASE (Langkah Akhir) ---
  // (Ini adalah isi _submitBooking yang lama, dipindahkan ke sini)
  Future<void> _processBookingToDB(int totalPrice) async {
    // Tampilkan loading kecil
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String baseUrl;
    if (kIsWeb) {
      baseUrl = 'http://localhost/washngo_api';
    } else {
      baseUrl = 'http://192.168.1.28/washngo_api';
    }

    final url = Uri.parse('$baseUrl/save_booking.php');
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final response = await http
          .post(
            url,
            body: {
              'email': widget.email,
              'service': _selectedService!['name'],
              'vehicle': _selectedVehicle,
              'schedule': _selectedSchedule,
              'date': dateStr,
              'bay': _selectedBay.toString(),
              'price': totalPrice.toString(),
            },
          )
          .timeout(const Duration(seconds: 10));

      // Tutup loading indicator
      Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        if (mounted) {
          // Tampilkan Dialog Sukses
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              content: const Text(
                "Pembayaran Berhasil! Booking Anda telah disimpan.",
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup Dialog Sukses
                    Navigator.pop(context); // Kembali ke Home
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Tutup loading jika error
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal koneksi server")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int biaya = _selectedService?['price'] ?? 0;
    int ppn = (biaya * 0.1).toInt();
    int total = biaya + ppn;

    if (_isLoadingData)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB3E5FC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Kembali",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildRowLabel('Nama\nPelanggan', _userName),
                  const SizedBox(height: 15),

                  _vehicleList.isEmpty
                      ? const Text(
                          "Belum ada data mobil.",
                          style: TextStyle(color: Colors.red),
                        )
                      : _buildDropdownRow(
                          label: 'Pilih\nKendaraan',
                          value: _selectedVehicle,
                          items: _vehicleList,
                          onChanged: (val) =>
                              setState(() => _selectedVehicle = val),
                        ),
                  const SizedBox(height: 15),

                  _buildDropdownRow(
                    label: 'Pilih Jenis\nLayanan',
                    value: _selectedService?['name'],
                    items: _serviceList
                        .map((e) => e['name'] as String)
                        .toList(),
                    onChanged: (val) => setState(
                      () => _selectedService = _serviceList.firstWhere(
                        (e) => e['name'] == val,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // PICKER TANGGAL
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "Tanggal :",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          DateFormat('dd MMMM yyyy').format(_selectedDate),
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _selectedBay =
                                  null; // Reset bilik saat ganti tanggal
                            });
                            // PENTING: Cek ulang ketersediaan saat tanggal berubah
                            _checkAvailability();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // DROPDOWN JADWAL
                  _buildDropdownRow(
                    label: 'Pilih Jadwal :',
                    value: _selectedSchedule,
                    items: _scheduleList,
                    onChanged: (val) {
                      setState(() {
                        _selectedSchedule = val;
                        _selectedBay = null; // Reset bilik saat ganti jam
                      });
                      // PENTING: Cek ulang ketersediaan saat jam berubah
                      _checkAvailability();
                    },
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL BILIK (HIJAU/MERAH/PUTIH)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      1,
                      2,
                      3,
                    ].map((bayNum) => _buildBayButton(bayNum)).toList(),
                  ),

                  const SizedBox(height: 10),
                  // Legenda Warna
                  Center(
                    child: Text(
                      "Hijau: Terisi | Merah: Dipilih | Putih: Kosong",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Footer Total
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF26CCC2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              _buildPriceRow("Total Pembayaran :", "RP $total", isTotal: true),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  
                  onPressed: () {
                    _showPaymentDialog(total);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF311B92),
                  ),
                  child: const Text(
                    "Bayar Sekarang",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---

  // Update Widget Bay Button agar bisa Hijau
  Widget _buildBayButton(int bayNum) {
    // Cek apakah bilik ini ada di daftar bookingan?
    bool isBooked = _bookedBays.contains(bayNum);

    // Tentukan Warna
    Color btnColor = Colors.white;
    if (isBooked) {
      btnColor = Colors.green; // Hijau jika terisi
    } else if (_selectedBay == bayNum) {
      btnColor = Colors.red; // Merah jika dipilih user
    }

    return GestureDetector(
      // Jika booked, matikan onTap (null)
      onTap: isBooked ? null : () => setState(() => _selectedBay = bayNum),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "$bayNum",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // Ubah warna teks agar kontras
              color: (isBooked || _selectedBay == bayNum)
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // ... Widget helper lain (_buildRowLabel, _buildDropdownRow, _buildPriceRow) tetap sama ...
  // Silakan copy paste 3 widget helper terakhir dari kode sebelumnya jika belum ada di sini.
  // Agar kode tidak terlalu panjang, saya asumsikan helper widget standar sudah Anda miliki.

  Widget _buildDropdownRow({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Text(" : "),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRowLabel(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Text(" :  "),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
