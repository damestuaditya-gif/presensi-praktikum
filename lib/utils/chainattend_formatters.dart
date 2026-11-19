part of '../main.dart';

extension _ChainAttendFormatters on _ChainAttendHomeState {

  String normalizeAddress(String? value) {
  if (value == null) return '';

  return value
      .trim()
      .toLowerCase()
      .replaceFirst(RegExp(r'^0x'), '');
}

  String formatNimHash(dynamic value) {
    if (value == null) return '-';

    try {
      if (value is String) {
        final cleaned = value.trim();
        if (cleaned.isEmpty) return '-';
        return cleaned.startsWith('0x') ? cleaned : '0x$cleaned';
      }

      if (value is List) {
        final bytes = value.map((item) => (item as num).toInt()).toList();
        return '0x${bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
      }

      return value.toString();
    } catch (_) {
      return value.toString();
    }
  }

  String formatTimestamp(dynamic value) {
    if (value == null) return '-';

    try {
      final timestamp = value is BigInt
          ? value.toInt()
          : int.parse(value.toString());

      if (timestamp <= 0) return '-';

      final date = DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
        isUtc: true,
      ).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return '-';
    }
  }

  String shortAddress(String? value) {
    if (value == null || value.length < 12) {
      return value ?? '-';
    }

    return '${value.substring(0, 8)}...${value.substring(value.length - 6)}';
  }

}
