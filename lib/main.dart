import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:pointycastle/digests/keccak.dart';


import 'config/reown_config.dart';
import 'services/blockchain_service.dart';

part 'screens/admin_pages.dart';
part 'screens/student_pages.dart';
part 'widgets/chainattend_widgets.dart';
part 'utils/chainattend_formatters.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChainAttendApp());
}

const Color primary = Color(0xFF167C72);
const Color primaryDark = Color(0xFF123D3A);
const Color primaryLight = Color(0xFFDDF2ED);
const Color pageBg = Color(0xFFF3F7F5);
const Color darkText = Color(0xFF1B302E);
const Color mutedText = Color(0xFF71827F);
const Color green = Color(0xFF16856D);
const Color red = Color(0xFFD95D55);
const Color orange = Color(0xFFD99136);

class ChainAttendApp extends StatelessWidget {
  const ChainAttendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi Praktikum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: darkText),
          headlineMedium: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: darkText),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: darkText),
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkText),
          bodyLarge: TextStyle(fontSize: 14, height: 1.45, color: darkText),
          bodyMedium: TextStyle(fontSize: 13, height: 1.4, color: mutedText),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.1),
        ),
        scaffoldBackgroundColor: pageBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: darkText,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: darkText, fontSize: 19, fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F8F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2EBE7))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.5)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: Colors.white,
          indicatorColor: primaryLight,
          elevation: 8,
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? primary : mutedText,
          )),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      home: const ChainAttendHome(),
    );
  }
}

class ChainAttendHome extends StatefulWidget {
  const ChainAttendHome({super.key});

  @override
  State<ChainAttendHome> createState() => _ChainAttendHomeState();
}

class _ChainAttendHomeState extends State<ChainAttendHome> {
  final BlockchainService chain = BlockchainService();

  ReownAppKit? appKit;
  ReownAppKitModal? modal;

  String? address;
  String? adminAddress;

  String network = 'Belum terhubung';
  String? error;

  bool ready = false;
  bool refreshing = false;
  bool transactionInProgress = false;
  bool onSepolia = false;
  bool registered = false;

  BigInt meetingCount = BigInt.zero;

  int selectedPage = 0;

  void updateSelectedPage(int index) {
    if (!mounted) return;
    setState(() => selectedPage = index);
  }

  final Map<int, Map<String, dynamic>> meetings = {};
  final Map<int, BigInt> attendanceCounts = {};
  final Map<int, bool> myAttendance = {};
  final Map<int, Map<String, dynamic>> myAttendanceData = {};
  final Map<int, List<Map<String, dynamic>>> attendanceRecords = {};

  bool get isAdmin {
  return normalizeAddress(address).isNotEmpty &&
      normalizeAddress(address) ==
          normalizeAddress(adminAddress);
}

bool get isStudent {
  return address != null && onSepolia && !isAdmin;
}

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      await chain.init();

      adminAddress = await chain.getAdmin();

      if (!mounted) return;

      appKit = ReownAppKit(
        core: ReownCore(
          projectId: ReownConfig.projectId,
          logLevel: LogLevel.all,
        ),
        metadata: PairingMetadata(
          name: 'Presensi Praktikum',
          description: ReownConfig.description,
          url: ReownConfig.appUrl,
          icons: const [
            'https://raw.githubusercontent.com/reown-com/reown_flutter/develop/assets/appkit-icon.png',
          ],
          redirect: const Redirect(
            native: 'chainattend://',
          ),
        ),
      );

      modal = ReownAppKitModal(
        context: context,
        appKit: appKit!,
      );

      modal!.onModalConnect.subscribe((_) {
        syncWallet();
      });

      modal!.onModalUpdate.subscribe((_) {
        syncWallet();
      });

      modal!.onModalNetworkChange.subscribe((_) {
        syncWallet();
      });

      modal!.onModalDisconnect.subscribe((_) {
        if (!mounted) return;

        setState(() {
          address = null;
          onSepolia = false;
          registered = false;
          network = 'Belum terhubung';
          selectedPage = 0;
        });
      });

      await modal!.init();

      if (modal!.isConnected) {
        await syncWallet();
      }
    } catch (e) {
      error = 'Gagal menginisialisasi aplikasi: $e';
    }

    if (mounted) {
      setState(() => ready = true);
    }
  }

  Future<void> syncWallet() async {
    if (modal == null || !modal!.isConnected || modal!.session == null) {
      return;
    }

    try {
      final walletAddress = modal!.session!.getAddress('eip155');
      if (walletAddress == null || walletAddress.isEmpty) {
        throw Exception('Alamat wallet tidak ditemukan dari sesi MetaMask.');
      }

      final selectedChain = modal!.selectedChain?.chainId;
      final correctNetwork =
          selectedChain == 'eip155:${ReownConfig.chainId}';

      // Baca alamat admin langsung dari kontrak setiap kali akun/jaringan berubah.
      final contractAdmin = await chain.getAdmin();
      if (!mounted) return;

      setState(() {
        address = walletAddress;
        adminAddress = contractAdmin;
        onSepolia = correctNetwork;
        network = correctNetwork ? 'Sepolia' : 'Jaringan bukan Sepolia';
        selectedPage = 0;
      });

     debugPrint('========== ROLE PRESENSI PRAKTIKUM ==========');
debugPrint('WALLET AKTIF : $walletAddress');
debugPrint('ADMIN KONTRAK: $contractAdmin');
debugPrint('WALLET NORMAL: ${normalizeAddress(walletAddress)}');
debugPrint('ADMIN NORMAL : ${normalizeAddress(contractAdmin)}');
debugPrint('SEPOLIA      : $correctNetwork');
debugPrint('IS ADMIN     : ${normalizeAddress(walletAddress) == normalizeAddress(contractAdmin)}');
debugPrint('======================================');

      if (correctNetwork) {
        await refreshData();
      } else if (mounted) {
        setState(() {
          registered = false;
          meetings.clear();
          attendanceCounts.clear();
          myAttendance.clear();
          myAttendanceData.clear();
          attendanceRecords.clear();
        });
      }
    } catch (e) {
      showMessage('Gagal membaca wallet: $e');
    }
  }

  Future<void> connectWallet() async {
    if (modal == null) {
      showMessage('Wallet belum siap.');
      return;
    }

    try {
      await modal!.openModalView();
      await syncWallet();
    } catch (e) {
      showMessage('Koneksi wallet gagal: $e');
    }
  }

  Future<void> disconnectWallet() async {
    await modal?.disconnect();

    if (!mounted) return;

    setState(() {
      address = null;
      onSepolia = false;
      registered = false;
      network = 'Belum terhubung';
      selectedPage = 0;
    });
  }

  Future<void> refreshData() async {
    if (!onSepolia || address == null || refreshing) return;

    setState(() => refreshing = true);

    try {
     final admin = await chain.getAdmin();

final currentIsAdmin =
    normalizeAddress(address) == normalizeAddress(admin);

final count = await chain.getJumlahPertemuan();
      // Admin bukan mahasiswa, sehingga tidak perlu dicek ke mapping mahasiswa.
      final isRegistered = currentIsAdmin
          ? false
          : await chain.cekMahasiswaTerdaftar(address!);

      final newMeetings = <int, Map<String, dynamic>>{};
      final newCounts = <int, BigInt>{};
      final newAttendance = <int, bool>{};
      final newAttendanceData = <int, Map<String, dynamic>>{};
      final newRecords = <int, List<Map<String, dynamic>>>{};

      for (int i = 1; i <= count.toInt(); i++) {
        final nomor = BigInt.from(i);
        newMeetings[i] = await chain.getStatusPertemuan(nomor);
        newCounts[i] = await chain.getJumlahPresensi(nomor);

        if (currentIsAdmin) {
          final records = await chain.getSemuaPresensi(nomor);
          newRecords[i] = records;
        } else if (isRegistered) {
          final attended = await chain.cekSudahPresensi(nomor, address!);
          newAttendance[i] = attended;
          if (attended) {
            newAttendanceData[i] =
                await chain.getDataPresensi(nomor, address!);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        adminAddress = admin;
        meetingCount = count;
        registered = isRegistered;
        meetings
          ..clear()
          ..addAll(newMeetings);
        attendanceCounts
          ..clear()
          ..addAll(newCounts);
        myAttendance
          ..clear()
          ..addAll(newAttendance);
        myAttendanceData
          ..clear()
          ..addAll(newAttendanceData);
        attendanceRecords
          ..clear()
          ..addAll(newRecords);
        error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Gagal membaca blockchain: $e');
      }
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

  Future<bool> runTransaction(
    Future<String> Function() action,
    String message, {
    Future<void> Function()? afterSuccess,
  }) async {
    if (address == null || !onSepolia || modal == null) {
      showMessage('Hubungkan wallet ke Sepolia terlebih dahulu.');
      return false;
    }

    if (transactionInProgress) {
      showMessage('Transaksi sebelumnya masih diproses. Tunggu sebentar.');
      return false;
    }
    setState(() => transactionInProgress = true);

    var success = false;
    try {
      final txHash = await action();
      if (!mounted) return false;
      showMessage('$message\nHash transaksi: $txHash');
      success = true;
    } catch (e) {
      if (mounted) showMessage('Transaksi gagal: $e');
    } finally {
      if (mounted) setState(() => transactionInProgress = false);
    }

    // Perbarui hanya data yang berubah. Jangan memuat seluruh riwayat presensi.
    if (success && mounted) {
      if (afterSuccess != null) {
        await afterSuccess();
      } else {
        await refreshData();
      }
    }
    return success;
  }

  Future<void> _refreshOpenedMeeting() async {
    // requestWriteContract mengembalikan hash setelah wallet mengirim transaksi.
    // Poll status kontrak sampai transaksi benar-benar tercermin di Sepolia.
    for (var attempt = 0; attempt < 30; attempt++) {
      try {
        final count = await chain.getJumlahPertemuan();
        if (count > BigInt.zero) {
          final id = count.toInt();
          final status = await chain.getStatusPertemuan(count);
          if (status['dibuka'] == true) {
            if (!mounted) return;
            setState(() {
              meetingCount = count;
              meetings[id] = status;
              error = null;
            });
            return;
          }
        }
      } catch (_) {
        // RPC temporer gagal: lanjutkan polling, jangan menganggap transaksi gagal.
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) {
      showMessage('Transaksi sudah dikirim, tetapi status pertemuan belum ter-update. Periksa jaringan atau tekan Refresh.');
    }
  }

  Future<void> _refreshClosedMeeting(int id) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      try {
        final status = await chain.getStatusPertemuan(BigInt.from(id));
        if (status['dibuka'] == false) {
          if (!mounted) return;
          setState(() {
            meetings[id] = status;
            error = null;
          });
          return;
        }
      } catch (_) {
        // RPC temporer gagal: lanjutkan polling.
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) {
      showMessage('Transaksi sudah dikirim, tetapi status penutupan belum ter-update. Periksa jaringan atau tekan Refresh.');
    }
  }

  Future<void> openMeeting() async {
    if (!isAdmin) {
      showMessage('Hanya Dosen yang dapat membuka pertemuan.');
      return;
    }

    await runTransaction(
      () => chain.bukaPertemuan(
        walletModal: modal!,
        walletAddress: address!,
      ),
      'Transaksi pembukaan pertemuan berhasil dikirim.',
      afterSuccess: _refreshOpenedMeeting,
    );
  }

  Future<void> closeMeeting(int id) async {
    if (!isAdmin) return;

    await runTransaction(
      () => chain.tutupPertemuan(
        walletModal: modal!,
        walletAddress: address!,
        nomor: BigInt.from(id),
      ),
      'Transaksi penutupan pertemuan berhasil dikirim.',
      afterSuccess: () => _refreshClosedMeeting(id),
    );
  }

  // Memperbarui status pendaftaran saja, tanpa memuat ulang seluruh dashboard.
  Future<void> _refreshStudentRegistration(String wallet) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      try {
        final isRegistered = await chain.cekMahasiswaTerdaftar(wallet);
        if (isRegistered) {
          if (!mounted) return;
          setState(() {
            if (normalizeAddress(wallet) == normalizeAddress(address)) {
              registered = true;
            }
            error = null;
          });
          return;
        }
      } catch (_) {
        // RPC dapat sementara belum membaca transaksi terbaru.
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) {
      showMessage('Transaksi pendaftaran sudah dikirim, tetapi status belum terbaca. Periksa jaringan atau tekan Refresh.');
    }
  }

  // Memperbarui data presensi untuk pertemuan aktif saja.
  Future<void> _refreshMyAttendance(int meetingId) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      try {
        final attended = await chain.cekSudahPresensi(
          BigInt.from(meetingId),
          address!,
        );
        if (attended) {
          final data = await chain.getDataPresensi(
            BigInt.from(meetingId),
            address!,
          );
          final count = await chain.getJumlahPresensi(BigInt.from(meetingId));
          if (!mounted) return;
          setState(() {
            myAttendance[meetingId] = true;
            myAttendanceData[meetingId] = data;
            attendanceCounts[meetingId] = count;
            error = null;
          });
          return;
        }
      } catch (_) {
        // Tunggu pembacaan RPC berikutnya tanpa memuat ulang seluruh data.
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) {
      showMessage('Transaksi presensi sudah dikirim, tetapi status belum terbaca. Periksa jaringan atau tekan Refresh.');
    }
  }

  Future<void> attend() async {
    if (!isStudent || !registered) {
      showMessage('Wallet belum terdaftar sebagai mahasiswa.');
      return;
    }

    final active = meetings.entries
        .where((e) => e.value['dibuka'] == true)
        .toList();

    if (active.isEmpty) {
      showMessage('Belum ada pertemuan yang dibuka.');
      return;
    }

    final currentMeeting = active.last;

    if (myAttendance[currentMeeting.key] == true) {
      showMessage('Kamu sudah melakukan presensi.');
      return;
    }

    await runTransaction(
      () => chain.presensi(
        walletModal: modal!,
        walletAddress: address!,
      ),
      'Transaksi presensi dikirim ke Sepolia.',
      afterSuccess: () => _refreshMyAttendance(currentMeeting.key),
    );
  }

  Future<void> registerStudent() async {
    if (!isAdmin || transactionInProgress) return;

    final nimController = TextEditingController();
    final walletController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Daftarkan Mahasiswa'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nimController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIM Mahasiswa',
                  helperText: 'NIM akan di-hash sebelum dikirim ke blockchain.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: walletController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Wallet Mahasiswa',
                  hintText: '0x...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hash & Daftarkan'),
          ),
        ],
      ),
    );

    if (result == true) {
      final nim = nimController.text.trim();
      final wallet = walletController.text.trim();

      if (!RegExp(r'^[0-9]{5,20}$').hasMatch(nim) ||
          !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(wallet)) {
        showMessage('NIM atau alamat wallet tidak valid.');
      } else {
        try {
          final alreadyRegistered = await chain.cekMahasiswaTerdaftar(wallet);
          if (alreadyRegistered) {
            showMessage('Wallet ini sudah terdaftar. Hash NIM tidak dapat diperbarui melalui fungsi pendaftaran yang tersedia.');
          } else {
            final nimHash = Uint8List.fromList(
              KeccakDigest(256).process(
                Uint8List.fromList(utf8.encode(nim)),
              ),
            );

            await runTransaction(
              () => chain.daftarkanMahasiswa(
                walletModal: modal!,
                walletAddress: address!,
                mahasiswaAddress: wallet,
                nimHash: nimHash,
              ),
              'Transaksi pendaftaran dikirim ke Sepolia.',
              afterSuccess: () => _refreshStudentRegistration(wallet),
            );
          }
        } catch (e) {
          showMessage('Gagal memproses pendaftaran: $e');
        }
      }
    }

    nimController.dispose();
    walletController.dispose();
  }

  // =========================================================
  // RESPONSIVE ROOT
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 850;

    if (!ready) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primary),
        ),
      );
    }

    if (address == null || !onSepolia) {
      return connectionPage();
    }

    // DOSEN SELALU MASUK KE DASHBOARD DOSEN,
    // BAIK DI DESKTOP MAUPUN MOBILE.
    if (isAdmin) {
      return desktop ? adminDesktop() : adminMobile();
    }

    if (isStudent) {
      return studentMobile();
    }

    return connectionPage();
  }

  // =========================================================
  // CONNECTION PAGE
  // =========================================================

  Widget connectionPage() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.hexagon_rounded,
                    size: 42,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Presensi Praktikum',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sistem Presensi Berbasis Blockchain',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: mutedText),
                ),
                const SizedBox(height: 30),
                infoRow('Jaringan', 'Sepolia Testnet'),
                infoRow('Chain ID', '11155111'),
                infoRow('Status', network),
                if (address != null) ...[
                  const Divider(height: 25),
                  const Text('Wallet terhubung'),
                  SelectableText(
                    address!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: primary,
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: connectWallet,
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Hubungkan MetaMask'),
                  ),
                ),
                if (address != null)
                  TextButton(
                    onPressed: disconnectWallet,
                    child: const Text('Putuskan Wallet'),
                  ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: const TextStyle(color: red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // DESKTOP DOSEN
  // =========================================================




  // =========================================================
  // MOBILE DOSEN
  // =========================================================


  // =========================================================
  // DASHBOARD DOSEN
  // =========================================================


  // =========================================================
  // PENDAFTARAN MAHASISWA
  // =========================================================


  // =========================================================
  // MANAJEMEN PERTEMUAN
  // =========================================================


  // =========================================================
  // REKAP PRESENSI DOSEN
  // =========================================================


  // =========================================================
  // DASHBOARD MAHASISWA
  // =========================================================





  // =========================================================
  // WALLET
  // =========================================================



  // =========================================================
  // COMPONENTS
  // =========================================================






  Widget statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3ECE8)),
        boxShadow: [BoxShadow(color: const Color(0xFF123D3A).withValues(alpha: 0.035), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 21)),
              Icon(Icons.north_east_rounded, color: mutedText.withValues(alpha: 0.55), size: 17),
            ],
          ),
          const SizedBox(height: 17),
          Text(value, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: darkText)),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: mutedText)),
        ],
      ),
    );
  }

  Widget infoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: mutedText,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? darkText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }










  @override
  void dispose() {
    modal?.dispose();
    chain.dispose();
    super.dispose();
  }
}
