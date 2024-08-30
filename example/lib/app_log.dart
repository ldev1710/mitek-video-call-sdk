class AppLog {
  static const String _prefix = "[App-Debug]";

  static logI(String message) {
    print("$_prefix $message");
  }
}
