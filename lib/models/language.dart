class MTLanguageSp {
  int id;
  String language;

  factory MTLanguageSp.fromJson(Map<String, dynamic> json) {
    return MTLanguageSp(
      id: int.parse(json["id"]),
      language: json["language"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "language": language,
    };
  }

  MTLanguageSp({
    required this.id,
    required this.language,
  });
}
