class MTQueue {
  String queueNum;
  String queueName;
  String queueDisplay;
  int maxWaitTime;

  MTQueue({
    required this.queueNum,
    required this.queueName,
    required this.queueDisplay,
    required this.maxWaitTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "queue_num": queueNum,
      "queue_name": queueName,
      "queue_display": queueDisplay,
      "max_wait_time": maxWaitTime,
    };
  }

  factory MTQueue.fromJson(Map<String, dynamic> json) {
    return MTQueue(
      queueNum: json["queue_num"],
      queueName: json["queue_name"],
      queueDisplay: json["queue_display"],
      maxWaitTime: int.parse(json["max_wait_time"]),
    );
  }
}
