import 'package:intl/intl.dart';

/// App-wide formatting utilities for Indian locale.
class AppFormatters {
  static final _currencyFmt = NumberFormat('#,##,##0.00', 'en_IN');
  static final _currencyCompactFmt = NumberFormat('#,##,##0', 'en_IN');
  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _dateTimeFmt = DateFormat('dd MMM yyyy, hh:mm a');
  static final _monthFmt = DateFormat('MMM yyyy');

  static String currency(double amount) => '₹${_currencyFmt.format(amount)}';
  static String currencyCompact(double amount) =>
      '₹${_currencyCompactFmt.format(amount)}';
  static String date(DateTime dt) => _dateFmt.format(dt);
  static String dateTime(DateTime dt) => _dateTimeFmt.format(dt);
  static String month(DateTime dt) => _monthFmt.format(dt);

  static String expiryLabel(DateTime expiry) {
    final now = DateTime.now();
    final diff = expiry.difference(now).inDays;
    if (diff < 0) return 'EXPIRED';
    if (diff == 0) return 'Expires today';
    if (diff <= 30) return 'Expires in $diff days';
    return _dateFmt.format(expiry);
  }

  static String stockLabel(int stock) {
    if (stock == 0) return 'Out of stock';
    if (stock < 10) return '$stock units (low)';
    return '$stock units';
  }
}
