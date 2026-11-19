# Presensi Praktikum

## Fitur Aplikasi

### Dosen
- Menghubungkan wallet MetaMask.
- Mendaftarkan mahasiswa menggunakan NIM dan alamat wallet.
- Membuka pertemuan praktikum.
- Melihat rekap presensi mahasiswa.
- Melihat alamat wallet dan NIM yang telah di-hash.
- Melihat tanggal dan waktu kehadiran.
- Menutup pertemuan praktikum.

### Mahasiswa
- Menghubungkan wallet MetaMask.
- Melihat pertemuan aktif.
- Melakukan presensi melalui transaksi blockchain.
- Melihat riwayat kehadiran.
- Melihat NIM yang telah di-hash serta waktu presensi.

## Teknologi yang Digunakan

| Teknologi | Keterangan |
|---|---|
| Flutter | Framework pengembangan aplikasi |
| Dart | Bahasa pemrograman |
| Solidity | Bahasa pemrograman smart contract |
| Remix IDE | Kompilasi dan deployment smart contract |
| MetaMask | Wallet blockchain |
| Reown AppKit | Integrasi koneksi wallet |
| Web3dart | Komunikasi aplikasi dengan blockchain |
| Ethereum Sepolia | Jaringan blockchain |

## Versi Perangkat dan Paket

### Versi Pengembangan
- Flutter: 3.47.0
- Dart: 3.13.0
- Android SDK: Sesuai konfigurasi pengembangan

### Dependencies

| Paket | Versi |
|---|---|
| cupertino_icons | ^1.0.8 |
| web3dart | ^3.0.3 |
| http | ^1.6.0 |
| wallet | ^0.0.18 |
| pointycastle | ^4.0.0 |
| reown_appkit | ^1.9.0 |

### Dev Dependencies

| Paket | Versi |
|---|---|
| flutter_test | SDK Flutter |
| flutter_lints | ^6.0.0 |

## Jaringan Blockchain

- Network: Ethereum Sepolia Testnet
- Chain ID: 11155111
- Wallet: MetaMask

### Smart Contract

Smart contract dikembangkan menggunakan Solidity dan dikompilasi serta di-deploy melalui Remix IDE.

- Nama file: `ChainAttend.sol`
- Alamat Smart Contract: `0xfc611fcbab4b98afdde166357f559426aaee19ff`
- Jaringan: Ethereum Sepolia Testnet

**Etherscan:**  
https://sepolia.etherscan.io/address/0xfc611fcbab4b98afdde166357f559426aaee19ff

## Struktur Repository

```text
presensi-praktikum/
├── android/
├── assets/
│   └── abi/
│       └── ChainAttend.json
├── contracts/
│   └── ChainAttend.sol
├── ios/
├── lib/
│   ├── config/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   ├── widgets/
│   └── main.dart
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── .gitignore
├── README.md
├── analysis_options.yaml
├── pubspec.lock
└── pubspec.yaml
```

**Keterangan:**
- `lib/` berisi kode utama aplikasi Flutter.
- `assets/abi/ChainAttend.json` berisi ABI smart contract yang digunakan aplikasi.
- `contracts/ChainAttend.sol` berisi source code smart contract untuk dikompilasi dan di-deploy melalui Remix IDE.

## Cara Menjalankan Aplikasi

### 1. Persiapan

Pastikan perangkat sudah memasang:
- Flutter SDK.
- Dart SDK.
- Visual Studio Code atau IDE lainnya.
- Android Studio atau emulator Android.
- MetaMask.

### 2. Clone Repository

```bash
git clone https://github.com/damestuditya-gif/presensi-praktikum.git
```

Masuk ke folder proyek:

```bash
cd presensi-praktikum
```

### 3. Instal Dependencies

```bash
flutter pub get
```

### 4. Menjalankan Aplikasi

```bash
flutter run
```

## Cara Deployment Smart Contract Menggunakan Remix IDE

1. Buka https://remix.ethereum.org/.
2. Siapkan file `ChainAttend.sol` yang tersedia pada folder `contracts` di repository.
3. Buat atau buka file Solidity tersebut di Remix IDE.
4. Pilih compiler Solidity sesuai versi yang digunakan pada source code.
5. Klik **Compile** untuk mengompilasi smart contract.
6. Hubungkan MetaMask melalui menu Deploy & Run Transactions.
7. Pastikan MetaMask menggunakan jaringan Ethereum Sepolia.
8. Pilih environment Injected Provider.
9. Klik **Deploy** dan konfirmasi transaksi melalui MetaMask.
10. Setelah deployment berhasil, salin alamat smart contract.
11. Simpan ABI hasil kompilasi ke `assets/abi/ChainAttend.json` apabila ABI yang tersedia perlu diperbarui.
12. Pastikan alamat kontrak pada konfigurasi aplikasi Flutter sesuai dengan alamat hasil deployment.

## Keamanan Data

NIM mahasiswa diproses menggunakan fungsi hash sebelum disimpan ke blockchain. Dengan demikian, NIM asli tidak disimpan secara langsung sebagai data presensi pada smart contract.

## Tujuan

Aplikasi ini dikembangkan sebagai proyek pembelajaran penerapan teknologi blockchain dalam sistem presensi praktikum untuk meningkatkan transparansi dan integritas pencatatan kehadiran.

## Tim Pengembang

Proyek ini dikembangkan secara berkelompok oleh mahasiswa Program Studi Teknologi Rekayasa Komputer.

1. Aditya Damestu
2. Althaf Sakha Difa Al Falah
3. Bhintang Agra
4. Dimas Abi Destian
5. Muhammad Akbar
6. Paskalis Ardiyanus Tingang
