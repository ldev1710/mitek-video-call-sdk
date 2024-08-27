library mitek_video_call_sdk;

class MTVideoCallPlugin {
  static final MTVideoCallPlugin _instance = MTVideoCallPlugin._internal();
  static MTVideoCallPlugin get instance => _instance;
  MTVideoCallPlugin._internal();
  factory MTVideoCallPlugin() {
    return _instance;
  }

  // Các phương thức và thuộc tính của class.
  void triggerMethod() {
    print("MTVideoCallPlugin method called");
  }
}
