import 'package:intl/intl.dart';

class AppFormatters {
  static String currency(num amount) {
    return NumberFormat.currency(locale: 'es_MX', symbol: r'$', decimalDigits: 0)
        .format(amount);
  }

  static String date(DateTime date) {
    return DateFormat('d MMMM yyyy', 'es_MX').format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_MX').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('HH:mm', 'es_MX').format(date);
  }

  static String daysRemaining(DateTime target) {
    final diff = target.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Pasado';
    if (diff == 0) return '¡Hoy es el día!';
    if (diff == 1) return '1 día';
    return '$diff días';
  }

  static int daysRemainingCount(DateTime target) {
    return target.difference(DateTime.now()).inDays;
  }
}
