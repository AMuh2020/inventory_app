import 'package:intl/intl.dart';

String formatDateTime(String dateTime) {
  DateTime parsedDateTime = DateTime.parse(dateTime);
  return DateFormat('yyyy-MM-dd HH:mm').format(parsedDateTime);
}

String formatDate(String date) {
  DateTime parsedDateTime = DateTime.parse(date);
  return DateFormat('yyyy-MM-dd').format(parsedDateTime);
}

String formatTime(String time) {
  DateTime parsedDateTime = DateTime.parse(time);
  return DateFormat('HH:mm').format(parsedDateTime);
}

String dateToDescrptiveString(String date) {
  DateTime parsedDateTime = DateTime.parse(date);
  return DateFormat('EEEE, MMMM d, y').format(parsedDateTime);
}

// date to today, yesterday, last week, last month, or older
String dateToHumanReadableString(String date) {
  DateTime parsedDateTime = DateTime.parse(date);
  DateTime now = DateTime.now();
  Duration difference = now.difference(parsedDateTime);
  if (difference.inDays == 0) {
    return 'Today, ${formatTime(date)}';
  } else if (difference.inDays == 1) {
    return 'Yesterday, ${formatTime(date)}';
  } else if (difference.inDays < 7) {
    // day of the week and time
    return '${DateFormat('EEEE').format(parsedDateTime)}, ${formatTime(date)}';
  } else if (difference.inDays > 7 && difference.inDays < 30) {
    return 'Last week';
  } else if (difference.inDays > 30 && difference.inDays < 60) {
    return 'Last month';
  } else {
    return 'Older';
  }
}