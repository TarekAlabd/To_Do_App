import 'package:intl/intl.dart';

String dateFormatted() {
  var now = DateTime.now();
  var formatter = DateFormat("EEE, MMM d, ''yy");
  var formatted = formatter.format(now);
  return formatted;
}