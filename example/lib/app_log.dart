class AppLog {
  static const String _prefix = "[App-Debug]";

  static void logI(String message) {
    print("$_prefix $message");
  }
}
