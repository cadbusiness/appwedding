import 'package:intl/intl.dart';

class AppFormatters {
  static String currency(num amount) {
    return NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0)
        .format(amount);
  }

  static String date(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }

  static String daysRemaining(DateTime target) {
    final diff = target.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Passé';
    if (diff == 0) return "Aujourd'hui !";
    if (diff == 1) return '1 jour';
    return '$diff jours';
  }

  static int daysRemainingCount(DateTime target) {
    return target.difference(DateTime.now()).inDays;
  }
}
