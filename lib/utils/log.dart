class MTLog {
  static const String _prefix = "[MITEK-VIDEO-CALL]";

  static void logI({required String message}) {
    print("$_prefix $message");
  }
}
