part of '../main.dart';

extension _StudentPages on _ChainAttendHomeState {

  Widget studentMobile() {
    final pages = [
      studentDashboard(),
      studentAttendance(),
      studentHistory(),
      walletPage(),
      profilePage(),
    ];

    const labels = [
      'Beranda',
      'Presensi',
      'Riwayat',
      'Wallet',
      'Profil',
    ];

    const icons = [
      Icons.home_rounded,
      Icons.fact_check_rounded,
      Icons.history_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.person_rounded,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [primaryDark, primary]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Text(
              'Presensi Praktikum',
              style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: pages[selectedPage < pages.length ? selectedPage : 0],
      bottomNavigationBar: NavigationBar(
        height: 72,
        elevation: 8,
        backgroundColor: Colors.white,
        indicatorColor: primaryLight,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: selectedPage,
        onDestinationSelected: (index) {
          updateSelectedPage(index);
        },
        destinations: List.generate(
          labels.length,
          (i) => NavigationDestination(
            icon: Icon(icons[i]),
            label: labels[i],
          ),
        ),
      ),
    );
  }

  Widget studentDashboard() {
    final active = meetings.entries
        .where((e) => e.value['dibuka'] == true)
        .toList();

    final attended = myAttendance.values
        .where((value) => value)
        .length;

    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Beranda Mahasiswa',
            'Selamat datang di Presensi Praktikum',
          ),
          const SizedBox(height: 18),
          whiteCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 27,
                  backgroundColor: primaryLight,
                  child: Icon(
                    Icons.person,
                    color: primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mahasiswa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        shortAddress(address),
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                statusPill(
                  registered ? 'Terverifikasi' : 'Belum daftar',
                  registered ? green : orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            // Jangan gunakan CrossAxisAlignment.stretch di dalam
            // SingleChildScrollView vertikal karena tinggi parent tidak terbatas.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: statCard(
                  'Total Pertemuan',
                  meetingCount.toString(),
                  Icons.calendar_month,
                  primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCard(
                  'Presensi Saya',
                  attended.toString(),
                  Icons.fact_check,
                  green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          sectionTitle('Pertemuan Aktif'),
          if (active.isEmpty)
            emptyCard('Belum ada pertemuan yang dibuka.')
          else
            ...active.map((e) => meetingCard(e.key, e.value)),
          if (active.isNotEmpty && registered)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: attend,
                icon: const Icon(Icons.check_circle),
                label: const Text('Presensi Sekarang'),
              ),
            ),
          if (!registered)
            emptyCard(
              'Wallet ini belum didaftarkan oleh Dosen.',
            ),
        ],
      ),
    );
  }

  Widget studentAttendance() {
    final active = meetings.entries
        .where((e) => e.value['dibuka'] == true)
        .toList();

    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Presensi',
            'Lakukan presensi saat pertemuan dibuka',
          ),
          const SizedBox(height: 20),
          if (!registered)
            emptyCard('Wallet belum terdaftar sebagai mahasiswa.'),
          if (active.isEmpty)
            emptyCard('Belum ada pertemuan aktif.'),
          ...active.map((e) {
            final already = myAttendance[e.key] == true;

            return whiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pertemuan #${e.key}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  statusPill(
                    already ? 'Sudah Hadir' : 'Belum Presensi',
                    already ? green : orange,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: !registered ||
                              already ||
                              transactionInProgress
                          ? null
                          : attend,
                      child: Text(
                        already
                            ? 'Presensi Sudah Tercatat'
                            : 'Kirim Presensi',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget studentHistory() {
    final history = myAttendance.entries
        .where((e) => e.value)
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Riwayat Presensi',
            'Riwayat kehadiran wallet mahasiswa',
          ),
          const SizedBox(height: 18),
          if (!registered)
            emptyCard('Wallet belum terdaftar.')
          else ...[
            if (history.isEmpty) emptyCard('Belum ada riwayat presensi.')
            else ...history.map((entry) {
              final data = myAttendanceData[entry.key];

              return whiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: primaryLight,
                          child: Icon(
                            Icons.check_circle,
                            color: green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pertemuan #${entry.key}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        statusPill('Hadir', green),
                      ],
                    ),
                    const Divider(height: 25),
                    infoRow(
                      'NIM Hash',
                      data == null ? '-' : formatNimHash(data['nimHash']),
                    ),
                    infoRow(
                      'Waktu hadir',
                      data == null
                          ? '-'
                          : formatTimestamp(
                              data['waktuPresensi'],
                            ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget walletPage() {
    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Wallet',
            'Informasi koneksi blockchain',
          ),
          const SizedBox(height: 20),
          whiteCard(
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: primary,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alamat Wallet',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  address ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 30),
                infoRow('Jaringan', network),
                infoRow('Chain ID', '11155111'),
                infoRow(
                  'Role',
                  isAdmin
                      ? 'Dosen (Admin)'
                      : 'Mahasiswa',
                ),
                infoRow(
                  'Status pendaftaran',
                  isAdmin
                      ? 'Administrator kontrak'
                      : registered
                          ? 'Terverifikasi'
                          : 'Belum terdaftar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profilePage() {
    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading('Profil', 'Informasi akun mahasiswa'),
          const SizedBox(height: 20),
          whiteCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: primaryLight,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mahasiswa Presensi Praktikum',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  address ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: mutedText,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: disconnectWallet,
                    icon: const Icon(Icons.logout),
                    label: const Text('Putuskan Wallet'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
