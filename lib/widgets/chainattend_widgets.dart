part of '../main.dart';

extension _ChainAttendWidgets on _ChainAttendHomeState {

  Widget pageContainer({required Widget child}) {
    return Container(
      color: pageBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget pageHeading(String title, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123D3A), Color(0xFF167C72), Color(0xFF35A395)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.16), blurRadius: 22, offset: const Offset(0, 9)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -22, top: -42, child: _headerBubble(150, 0.10)),
          Positioned(right: 72, bottom: -54, child: _headerBubble(112, 0.09)),
          Positioned(right: 150, top: 18, child: _headerBubble(30, 0.12)),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 23, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha: 0.18))),
                  child: const Text('PRESENSI PRAKTIKUM • BLOCKCHAIN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 15),
                Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.7, color: Colors.white)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 12.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBubble(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        border: Border.all(color: Colors.white.withValues(alpha: opacity + 0.05), width: 1),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 3),
      child: Row(
        children: [
          Container(width: 4, height: 19, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 9),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: darkText)),
        ],
      ),
    );
  }

  Widget whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3ECE8)),
        boxShadow: [BoxShadow(color: const Color(0xFF123D3A).withValues(alpha: 0.035), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }

  Widget statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
        ),
      ),
    );
  }

  Widget networkBadge() {
    return statusPill(
      onSepolia ? 'Sepolia Connected' : 'Disconnected',
      onSepolia ? green : red,
    );
  }

  Widget meetingCard(int id, Map<String, dynamic> data) {
    final opened = data['dibuka'] == true;
    final count = attendanceCounts[id] ?? BigInt.zero;

    return whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pertemuan #$id',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              statusPill(
                opened ? 'Dibuka' : 'Ditutup',
                opened ? green : red,
              ),
            ],
          ),
          const Divider(height: 25),
          infoRow('Jumlah hadir', count.toString()),
          infoRow(
            'Waktu dibuka',
            formatTimestamp(data['waktuDibuka']),
          ),
          if (isAdmin && opened) ...[
            const SizedBox(height: 12),
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
  }

  Widget emptyCard(String message) {
    return whiteCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              color: mutedText,
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: mutedText),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorCard(String message) {
    return whiteCard(
      child: Text(
        message,
        style: const TextStyle(color: red),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

}
