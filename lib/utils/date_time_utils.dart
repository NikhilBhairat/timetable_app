import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(String time) {
    // time is already in format "hh:mm a"
    return time;
  }

  static DateTime parseDate(String dateStr) {
    return DateFormat('dd MMM yyyy').parse(dateStr);
  }
}
