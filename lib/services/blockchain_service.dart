
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:reown_appkit/reown_appkit.dart';

import '../config/blockchain_config.dart';

class BlockchainService {
  late Web3Client _client;
  late DeployedContract _contract;

  bool _initialized = false;

  // =====================================
  // 1. INISIALISASI BLOCKCHAIN
  // =====================================

  Future<void> init() async {
    if (_initialized) return;

    _client = Web3Client(
      BlockchainConfig.rpcUrl,
      http.Client(),
    );

    final abiJson = await rootBundle.loadString(
      BlockchainConfig.abiPath,
    );

    final contractAbi = ContractAbi.fromJson(
      abiJson,
      'ChainAttend',
    );

    _contract = DeployedContract(
      contractAbi,
      EthereumAddress.fromHex(
        BlockchainConfig.contractAddress,
      ),
    );

    _initialized = true;
  }

  // =====================================
  // 2. MENGAMBIL FUNGSI SMART CONTRACT
  // =====================================

  ContractFunction _getFunction(String name) {
    if (!_initialized) {
      throw Exception(
        'BlockchainService belum diinisialisasi.',
      );
    }

    return _contract.function(name);
  }

  // =====================================
  // 3. MEMERIKSA KONEKSI BLOCKCHAIN
  // =====================================

  Future<int> cekKoneksi() async {
    if (!_initialized) {
      throw Exception('Blockchain belum terhubung.');
    }

    return await _client.getBlockNumber();
  }

  // =====================================
  // 4. MENGAMBIL JUMLAH PERTEMUAN
  // =====================================

  Future<BigInt> getJumlahPertemuan() async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('jumlahPertemuan'),
      params: [],
    );

    return result[0] as BigInt;
  }

  // =====================================
  // 5. MENGAMBIL STATUS PERTEMUAN
  // =====================================

  Future<Map<String, dynamic>> getStatusPertemuan(
    BigInt nomor,
  ) async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('statusPertemuan'),
      params: [nomor],
    );

    return {
      'dibuka': result[0] as bool,
      'waktuDibuka': result[1] as BigInt,
    };
  }

  // =====================================
  // 6. MEMERIKSA PENDAFTARAN MAHASISWA
  // =====================================

  Future<bool> cekMahasiswaTerdaftar(
    String walletAddress,
  ) async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('mahasiswaTerdaftar'),
      params: [
        EthereumAddress.fromHex(walletAddress),
      ],
    );

    return result[0] as bool;
  }

  // =====================================
  // 7. MEMERIKSA STATUS PRESENSI
  // =====================================

  Future<bool> cekSudahPresensi(
    BigInt nomor,
    String walletAddress,
  ) async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('cekSudahPresensi'),
      params: [
        nomor,
        EthereumAddress.fromHex(walletAddress),
      ],
    );

    return result[0] as bool;
  }

  // =====================================
  // 8. MENGAMBIL JUMLAH PRESENSI
  // =====================================

  Future<BigInt> getJumlahPresensi(
    BigInt nomor,
  ) async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('jumlahPresensi'),
      params: [nomor],
    );

    return result[0] as BigInt;
  }

  // =====================================
  // 9. MENGAMBIL DATA PRESENSI MAHASISWA
  // =====================================

  Future<Map<String, dynamic>> getDataPresensi(
    BigInt nomor,
    String walletAddress,
  ) async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('ambilPresensi'),
      params: [
        nomor,
        EthereumAddress.fromHex(walletAddress),
      ],
    );

    return {
      'nimHash': result[0],
      'waktuPresensi': result[1] as BigInt,
    };
  }

  // =====================================
  // 10. MENGAMBIL WALLET MAHASISWA HADIR
  // =====================================

  Future<String> getWalletHadir(
    BigInt nomor,
    BigInt index,
  ) async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('ambilWalletHadir'),
      params: [
        nomor,
        index,
      ],
    );

    return (result[0] as EthereumAddress).toString();
  }

  // =====================================
  // 11. MENGAMBIL DETAIL PRESENSI BERDASARKAN INDEX
  // =====================================

  Future<Map<String, dynamic>> getDetailPresensi(
    BigInt nomor,
    BigInt index,
  ) async {
    // Ambil alamat wallet mahasiswa dari daftar kehadiran.
    final wallet = await getWalletHadir(
      nomor,
      index,
    );

    // Ambil hash NIM dan timestamp berdasarkan wallet.
    final data = await getDataPresensi(
      nomor,
      wallet,
    );

    return {
      'pertemuan': nomor,
      'index': index,
      'wallet': wallet,
      'nimHash': data['nimHash'],
      'waktuPresensi': data['waktuPresensi'],
      'status': 'Hadir',
    };
  }

  // =====================================
  // 12. MENGAMBIL SELURUH PRESENSI PERTEMUAN
  // =====================================

  Future<List<Map<String, dynamic>>> getSemuaPresensi(
    BigInt nomor,
  ) async {
    final jumlah = await getJumlahPresensi(nomor);

    final records = <Map<String, dynamic>>[];

    for (int i = 0; i < jumlah.toInt(); i++) {
      final detail = await getDetailPresensi(
        nomor,
        BigInt.from(i),
      );

      records.add(detail);
    }

    return records;
  }

  // =====================================
  // 13. MENGAMBIL ALAMAT ADMIN
  // =====================================

  Future<String> getAdmin() async {
    final result = await _client.call(
      contract: _contract,
      function: _getFunction('admin'),
      params: [],
    );

    return (result[0] as EthereumAddress).toString();
  }

  // =====================================
  // 14. TRANSAKSI MELALUI WALLET REOWN
  // =====================================

  Future<String> _writeFunction({
    required ReownAppKitModal walletModal,
    required String walletAddress,
    required String functionName,
    List<dynamic> parameters = const [],
  }) async {
    if (!walletModal.isConnected ||
        walletModal.session == null) {
      throw Exception(
        'Hubungkan wallet terlebih dahulu.',
      );
    }

    final selectedChain =
        walletModal.selectedChain?.chainId;

    if (selectedChain !=
        'eip155:${BlockchainConfig.chainId}') {
      throw Exception(
        'Wallet harus menggunakan jaringan Sepolia.',
      );
    }

    final topic = walletModal.session!.topic;

    if (topic == null || topic.isEmpty) {
      throw Exception(
        'Sesi wallet tidak valid. Hubungkan ulang wallet.',
      );
    }

    final result =
        await walletModal.requestWriteContract(
      topic: topic,
      chainId: 'eip155:${BlockchainConfig.chainId}',
      deployedContract: _contract,
      functionName: functionName,
      parameters: parameters,
      transaction: Transaction(
        from: EthereumAddress.fromHex(walletAddress),
      ),
    );

    return result.toString();
  }

  // =====================================
  // 15. MEMBUKA PERTEMUAN
  // =====================================

  Future<String> bukaPertemuan({
    required ReownAppKitModal walletModal,
    required String walletAddress,
  }) {
    return _writeFunction(
      walletModal: walletModal,
      walletAddress: walletAddress,
      functionName: 'bukaPertemuan',
    );
  }

  // =====================================
  // 16. MENUTUP PERTEMUAN
  // =====================================

  Future<String> tutupPertemuan({
    required ReownAppKitModal walletModal,
    required String walletAddress,
    required BigInt nomor,
  }) {
    return _writeFunction(
      walletModal: walletModal,
      walletAddress: walletAddress,
      functionName: 'tutupPertemuan',
      parameters: [nomor],
    );
  }

  // =====================================
  // 17. MENDAFTARKAN MAHASISWA
  // =====================================

  Future<String> daftarkanMahasiswa({
    required ReownAppKitModal walletModal,
    required String walletAddress,
    required String mahasiswaAddress,
    required List<int> nimHash,
  }) {
    return _writeFunction(
      walletModal: walletModal,
      walletAddress: walletAddress,
      functionName: 'daftarkanMahasiswa',
      parameters: [
        EthereumAddress.fromHex(mahasiswaAddress),
        nimHash,
      ],
    );
  }

  // =====================================
  // 18. MELAKUKAN PRESENSI
  // =====================================

  Future<String> presensi({
    required ReownAppKitModal walletModal,
    required String walletAddress,
  }) {
    return _writeFunction(
      walletModal: walletModal,
      walletAddress: walletAddress,
      functionName: 'presensi',
    );
  }

  // =====================================
  // 19. MENUTUP KONEKSI
  // =====================================

  void dispose() {
    if (_initialized) {
      _client.dispose();
      _initialized = false;
    }
  }
}
