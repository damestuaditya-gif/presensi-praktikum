part of '../main.dart';

extension _AdminPages on _ChainAttendHomeState {

  Widget adminDesktop() {
    final pages = [
      adminDashboard(),
      studentManagement(),
      meetingManagement(),
      attendancePage(),
      walletPage(),
    ];

    const labels = [
      'Dashboard',
      'Mahasiswa',
      'Pertemuan',
      'Presensi',
      'Wallet',
    ];

    const icons = [
      Icons.dashboard_rounded,
      Icons.people_alt_rounded,
      Icons.calendar_month_rounded,
      Icons.fact_check_rounded,
      Icons.account_balance_wallet_rounded,
    ];

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 245,
            color: primaryDark,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(
                  Icons.hexagon_rounded,
                  size: 43,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Presensi Praktikum',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'LECTURER DASHBOARD',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 35),
                for (int i = 0; i < labels.length; i++)
                  sidebarItem(labels[i], icons[i], i),
                const Spacer(),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  title: const Text(
                    'Dosen',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Administrator kontrak',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Keluar Wallet',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: disconnectWallet,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                desktopTopBar(),
                Expanded(
                  child: pages[selectedPage < pages.length ? selectedPage : 0],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(String label, IconData icon, int index) {
    final selected = selectedPage == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => updateSelectedPage(index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF167C72) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 21),
              const SizedBox(width: 13),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget desktopTopBar() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Panel Dosen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const Spacer(),
          networkBadge(),
          const SizedBox(width: 15),
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh),
          ),
          const CircleAvatar(
            backgroundColor: primaryLight,
            child: Icon(Icons.school, color: primary),
          ),
        ],
      ),
    );
  }

  Widget adminMobile() {
    final pages = [
      adminDashboard(),
      studentManagement(),
      meetingManagement(),
      attendancePage(),
      walletPage(),
    ];

    const labels = [
      'Beranda',
      'Mahasiswa',
      'Pertemuan',
      'Presensi',
      'Wallet',
    ];

    const icons = [
      Icons.dashboard_rounded,
      Icons.people_alt_rounded,
      Icons.calendar_month_rounded,
      Icons.fact_check_rounded,
      Icons.account_balance_wallet_rounded,
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') disconnectWallet();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('Keluar Wallet'),
              ),
            ],
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

  Widget adminDashboard() {
    final totalAttendance = attendanceCounts.values.fold<BigInt>(
      BigInt.zero,
      (a, b) => a + b,
    );

    final openCount = meetings.values
        .where((e) => e['dibuka'] == true)
        .length;

    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Dashboard Dosen',
            'Ringkasan aktivitas presensi mahasiswa',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 800
                  ? (constraints.maxWidth - 36) / 4
                  : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: statCard(
                      'Total Pertemuan',
                      meetingCount.toString(),
                      Icons.calendar_month,
                      primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: statCard(
                      'Total Presensi',
                      totalAttendance.toString(),
                      Icons.fact_check,
                      green,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: statCard(
                      'Pertemuan Aktif',
                      openCount.toString(),
                      Icons.event_available,
                      orange,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: statCard(
                      'Jaringan',
                      onSepolia ? 'Online' : 'Offline',
                      Icons.hub,
                      onSepolia ? green : red,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 25),
          sectionTitle('Kontrol Pertemuan'),
          whiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola sesi perkuliahan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Buka pertemuan agar mahasiswa dapat melakukan presensi melalui wallet.',
                  style: TextStyle(color: mutedText),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: openMeeting,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Buka Pertemuan Baru'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          sectionTitle('Pertemuan Terbaru'),
          if (meetings.isEmpty)
            emptyCard('Belum ada pertemuan yang tercatat.')
          else
            ...meetings.entries.toList().reversed.take(3).map(
              (e) => meetingCard(e.key, e.value),
            ),
          if (error != null) errorCard(error!),
        ],
      ),
    );
  }

  Widget studentManagement() {
    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Data Mahasiswa',
            'Pendaftaran wallet mahasiswa ke smart contract',
          ),
          const SizedBox(height: 20),
          whiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  color: primary,
                  size: 35,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Daftarkan Mahasiswa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan NIM dan alamat wallet mahasiswa. NIM akan diubah menjadi hash Keccak-256 sebelum dikirim ke smart contract.',
                  style: TextStyle(color: mutedText),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: registerStudent,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Mahasiswa'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          sectionTitle('Informasi Pendaftaran'),
          whiteCard(
            child: Column(
              children: [
                infoRow('Jaringan', network),
                infoRow('Alamat Admin', adminAddress ?? '-'),
                infoRow('Total pertemuan', meetingCount.toString()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Catatan: smart contract saat ini belum menyediakan fungsi untuk mengambil seluruh daftar mahasiswa terdaftar. Karena itu, halaman ini menyediakan proses pendaftaran, bukan daftar mahasiswa fiktif.',
            style: TextStyle(
              fontSize: 12,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget meetingManagement() {
    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Manajemen Pertemuan',
            'Buka dan tutup sesi presensi melalui blockchain',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: openMeeting,
              icon: const Icon(Icons.add),
              label: const Text('Buka Pertemuan Baru'),
            ),
          ),
          const SizedBox(height: 20),
          if (meetings.isEmpty)
            emptyCard('Belum ada pertemuan.')
          else
            ...meetings.entries.toList().reversed.map(
              (e) => meetingCard(e.key, e.value),
            ),
        ],
      ),
    );
  }

  Widget attendancePage() {
    return pageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeading(
            'Rekap Presensi',
            'Data kehadiran mahasiswa yang tersimpan di Sepolia',
          ),
          const SizedBox(height: 20),
          if (meetings.isEmpty)
            emptyCard('Belum ada pertemuan.')
          else
            ...meetings.entries.toList().reversed.map((entry) {
              final id = entry.key;
              final records = attendanceRecords[id] ?? [];
              final opened = entry.value['dibuka'] == true;
              return whiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pertemuan #$id',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        statusPill(opened ? 'Dibuka' : 'Ditutup',
                            opened ? green : red),
                      ],
                    ),
                    const SizedBox(height: 8),
                    infoRow('Jumlah hadir', '${attendanceCounts[id] ?? BigInt.zero}'),
                    infoRow('Waktu dibuka', formatTimestamp(entry.value['waktuDibuka'])),
                    const Divider(height: 24),
                    if (records.isEmpty)
                      const Text(
                        'Belum ada mahasiswa yang melakukan presensi.',
                        style: TextStyle(color: mutedText),
                      )
                    else
                      ...records.asMap().entries.map((recordEntry) {
                        final record = recordEntry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mahasiswa ${recordEntry.key + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              SelectableText(
                                record['wallet']?.toString() ?? '-',
                                style: const TextStyle(fontSize: 12, color: primary),
                              ),
                              infoRow(
                                'NIM Hash',
                                formatNimHash(record['nimHash']),
                              ),
                              infoRow('Waktu hadir', formatTimestamp(record['waktuPresensi'])),
                            ],
                          ),
                        );
                      }),
                    if (opened) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => closeMeeting(id),
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Tutup Pertemuan'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

}
