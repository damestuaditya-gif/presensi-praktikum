# Presensi Praktikum

**Aplikasi Presensi Praktikum Berbasis Blockchain**

## 1. Deskripsi Proyek

Presensi Praktikum merupakan aplikasi berbasis Flutter yang memanfaatkan teknologi blockchain untuk mencatat kehadiran mahasiswa secara transparan dan terdesentralisasi.

Aplikasi ini menggunakan MetaMask sebagai wallet untuk menghubungkan pengguna dengan jaringan Ethereum Sepolia. Proses pendaftaran mahasiswa, pembukaan pertemuan, presensi mahasiswa, dan penutupan pertemuan dilakukan melalui transaksi blockchain.

## 2. Fitur Aplikasi

### Dosen
- Menghubungkan akun MetaMask.
- Mendaftarkan mahasiswa menggunakan NIM dan alamat wallet.
- Membuka pertemuan praktikum.
- Melihat rekap presensi mahasiswa.
- Melihat alamat wallet dan NIM yang telah di-hash.
- Melihat tanggal dan waktu kehadiran.
- Menutup pertemuan praktikum.

### Mahasiswa
- Menghubungkan akun MetaMask.
- Melihat pertemuan aktif.
- Melakukan presensi melalui transaksi blockchain.
- Melihat riwayat kehadiran.
- Melihat NIM yang telah di-hash serta tanggal dan waktu presensi.

## 3. Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Pengembangan aplikasi |
| Dart | Bahasa pemrograman |
| Solidity | Pengembangan smart contract |
| MetaMask | Wallet blockchain |
| Reown AppKit | Koneksi wallet |
| Web3dart | Interaksi dengan blockchain |
| Ethereum Sepolia | Jaringan blockchain |

## 4. Versi Flutter, Dart, dan Package

**Versi pengembangan:**
- Flutter: 3.47.0
- Dart: 3.13.0

**Dependencies:**

| Package | Versi |
|---|---|
| cupertino_icons | ^1.0.8 |
| web3dart | ^3.0.3 |
| http | ^1.6.0 |
| wallet | ^0.0.18 |
| pointycastle | ^4.0.0 |
| reown_appkit | ^1.9.0 |

**Dev Dependencies:**

| Package | Versi |
|---|---|
| flutter_test | SDK Flutter |
| flutter_lints | ^6.0.0 |

## 5. Jaringan Blockchain

- Network: Ethereum Sepolia Testnet
- Chain ID: 11155111
- Wallet: MetaMask

## 6. Smart Contract

- Nama kontrak: ChainAttend
- Bahasa pemrograman: Solidity
- Alamat kontrak: `0xfc611fcbab4b98afdde166357f559426aaee19ff`

**Etherscan:**

[ Lihat Smart Contract di Etherscan](https://sepolia.etherscan.io/address/0xfc611fcbab4b98afdde166357f559426aaee19ff)

## 7. Keamanan Data

NIM mahasiswa diproses menggunakan fungsi hash sebelum disimpan ke blockchain. Dengan demikian, NIM asli tidak disimpan secara langsung sebagai data presensi pada smart contract.

Data presensi dicatat melalui transaksi blockchain sehingga riwayat transaksi dapat diverifikasi pada jaringan Ethereum Sepolia.

## 8. Cara Menjalankan Aplikasi

**Persyaratan:**
- Flutter SDK 3.47.0.
- Dart SDK 3.13.0.
- Android Studio atau Visual Studio Code.
- MetaMask.
- Koneksi internet.

**Cara Menjalankan Aplikasi**
- Pastikan Flutter SDK dan Android Studio atau VS Code sudah terpasang.
- Clone repository: git clone https://github.com/damest uaditya-gif/presensi-praktikum.git
- Masuk ke folder proyek: cd presensi-praktikum
- Unduh dependensi: flutter pub get
- Jalankan aplikasi: flutter run

## 9. Sumber Kode dan Referensi

Pengembangan aplikasi dilakukan dengan memanfaatkan beberapa sumber referensi dan bantuan teknologi AI.

- **ChatGPT (OpenAI):** Digunakan sebagai alat bantu dalam penyusunan, penjelasan, pengembangan, dan perbaikan kode program.
- **Dokumentasi Flutter:** https://docs.flutter.dev/
- **Dokumentasi Dart:** https://dart.dev/
- **Dokumentasi Solidity:** https://docs.soliditylang.org/
- **Dokumentasi Web3dart:** https://pub.dev/packages/web3dart
- **Dokumentasi Reown AppKit:** https://docs.reown.com/

Kode yang dihasilkan atau disarankan melalui bantuan AI telah disesuaikan dengan kebutuhan proyek dan dipelajari oleh anggota kelompok.

## 10. Tim Pengembang

Proyek ini dikembangkan secara berkelompok oleh mahasiswa Program Studi Teknologi Rekayasa Komputer.

1. Aditya Damestu
2. Althaf Sakha Difa Al Falah
3. Bhintang Agra
4. Dimas Abi Destian
5. Muhammad Akbar
6. Paskalis Ardiyanus Tingang
