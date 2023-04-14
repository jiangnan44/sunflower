import 'package:logger/logger.dart';

class VLog {
  static final _logger = Logger(
    printer: PrefixPrinter(PrettyPrinter(
      colors: false,
      printEmojis: false,
      printTime: false,
      methodCount: 0,
      errorMethodCount: 2,
    )),
  );

  static d(String? msg) {
    if (msg == null || msg.isEmpty) return;
    _logger.d(msg);
  }

  static w(String? msg) {
    if (msg == null || msg.isEmpty) return;
    _logger.w(msg);
  }

  static e(String? msg) {
    if (msg == null || msg.isEmpty) return;
    _logger.e(msg);
  }

  static err(String? msg, dynamic error) {
    if (msg == null || msg.isEmpty) return;
    _logger.e(msg, error);
  }
}
