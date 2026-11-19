// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ChainAttend - Sistem Presensi Praktikum Berbasis Blockchain
/// @notice Rekonstruksi kontrak berdasarkan ABI ChainAttend yang diberikan.
/// @dev Ini bukan source code asli yang hilang. Periksa dan uji sebelum deployment.
contract ChainAttend {
    address public admin;

    struct Pertemuan {
        uint256 nomor;
        bool dibuka;
        uint256 waktuDibuka;
    }

    struct DataPresensi {
        bytes32 nimHash;
        uint256 waktuPresensi;
    }

    uint256 public jumlahPertemuan;

    mapping(uint256 => Pertemuan) public pertemuan;
    mapping(address => bool) public mahasiswaTerdaftar;
    mapping(bytes32 => bool) public nimSudahTerdaftar;
    mapping(uint256 => mapping(address => DataPresensi)) public dataPresensi;
    mapping(uint256 => mapping(address => bool)) public sudahPresensi;

    // Daftar wallet yang hadir pada setiap pertemuan.
    mapping(uint256 => address[]) private daftarWalletHadir;

    // Hash NIM disimpan berdasarkan wallet agar fungsi presensi() tanpa argumen
    // dapat mencatat hash NIM mahasiswa yang sedang mengirim transaksi.
    mapping(address => bytes32) private nimHashMahasiswa;

    event MahasiswaDidaftarkan(address indexed wallet, bytes32 nimHash);
    event PertemuanDibuka(uint256 indexed nomor, uint256 waktu);
    event PertemuanDitutup(uint256 indexed nomor);
    event PresensiBerhasil(
        uint256 indexed nomor,
        address indexed mahasiswa,
        bytes32 nimHash,
        uint256 waktu
    );

    modifier hanyaAdmin() {
        require(msg.sender == admin, "Hanya admin yang dapat melakukan tindakan ini");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Mendaftarkan wallet mahasiswa beserta hash NIM.
    function daftarkanMahasiswa(address wallet, bytes32 nimHash) external hanyaAdmin {
        require(wallet != address(0), "Wallet tidak valid");
        require(!mahasiswaTerdaftar[wallet], "Wallet sudah terdaftar");
        require(nimHash != bytes32(0), "Hash NIM tidak valid");
        require(!nimSudahTerdaftar[nimHash], "NIM sudah terdaftar");

        mahasiswaTerdaftar[wallet] = true;
        nimSudahTerdaftar[nimHash] = true;
        nimHashMahasiswa[wallet] = nimHash;

        emit MahasiswaDidaftarkan(wallet, nimHash);
    }

    /// @notice Membuka pertemuan baru dan menaikkan nomor pertemuan.
    function bukaPertemuan() external hanyaAdmin {
        jumlahPertemuan += 1;
        uint256 nomor = jumlahPertemuan;

        pertemuan[nomor] = Pertemuan({
            nomor: nomor,
            dibuka: true,
            waktuDibuka: block.timestamp
        });

        emit PertemuanDibuka(nomor, block.timestamp);
    }

    /// @notice Menutup pertemuan berdasarkan nomor pertemuan.
    function tutupPertemuan(uint256 nomor) external hanyaAdmin {
        require(nomor > 0 && nomor <= jumlahPertemuan, "Pertemuan tidak ditemukan");
        require(pertemuan[nomor].dibuka, "Pertemuan sudah ditutup");

        pertemuan[nomor].dibuka = false;
        emit PertemuanDitutup(nomor);
    }

    /// @notice Mahasiswa yang terdaftar melakukan presensi pada pertemuan aktif.
    function presensi() external {
        require(mahasiswaTerdaftar[msg.sender], "Mahasiswa belum terdaftar");
        require(jumlahPertemuan > 0, "Belum ada pertemuan");

        uint256 nomor = jumlahPertemuan;
        require(pertemuan[nomor].dibuka, "Pertemuan tidak sedang dibuka");
        require(!sudahPresensi[nomor][msg.sender], "Sudah melakukan presensi");

        bytes32 nimHash = nimHashMahasiswa[msg.sender];
        require(nimHash != bytes32(0), "Hash NIM tidak ditemukan");

        sudahPresensi[nomor][msg.sender] = true;
        dataPresensi[nomor][msg.sender] = DataPresensi({
            nimHash: nimHash,
            waktuPresensi: block.timestamp
        });
        daftarWalletHadir[nomor].push(msg.sender);

        emit PresensiBerhasil(nomor, msg.sender, nimHash, block.timestamp);
    }

    /// @notice Mengambil hash NIM dan waktu presensi mahasiswa pada pertemuan tertentu.
    function ambilPresensi(
        uint256 nomor,
        address mahasiswa
    ) external view returns (bytes32, uint256) {
        DataPresensi memory data = dataPresensi[nomor][mahasiswa];
        return (data.nimHash, data.waktuPresensi);
    }

    /// @notice Mengambil wallet mahasiswa berdasarkan indeks daftar hadir.
    function ambilWalletHadir(
        uint256 nomor,
        uint256 index
    ) external view returns (address) {
        require(index < daftarWalletHadir[nomor].length, "Index di luar jangkauan");
        return daftarWalletHadir[nomor][index];
    }

    /// @notice Memeriksa apakah wallet sudah presensi pada pertemuan tertentu.
    function cekSudahPresensi(
        uint256 nomor,
        address mahasiswa
    ) external view returns (bool) {
        return sudahPresensi[nomor][mahasiswa];
    }

    /// @notice Mengambil jumlah mahasiswa yang telah presensi pada pertemuan tertentu.
    function jumlahPresensi(uint256 nomor) external view returns (uint256) {
        return daftarWalletHadir[nomor].length;
    }

    /// @notice Mengambil status buka/tutup dan waktu pembukaan pertemuan.
    function statusPertemuan(
        uint256 nomor
    ) external view returns (bool, uint256) {
        Pertemuan memory data = pertemuan[nomor];
        return (data.dibuka, data.waktuDibuka);
    }
}
